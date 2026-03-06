import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/database/app_database.dart';
import 'bookmark_provider.dart';
import 'widgets/bookmark_summary_dialog.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(bookmarkFilterProvider);
    final bookmarks = ref.watch(filteredBookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: Column(
        children: [
          _buildFilterTabs(ref, filter),
          const Divider(height: 1),
          Expanded(
            child: bookmarks.when(
              data: (list) => _buildList(context, ref, list),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(WidgetRef ref, BookmarkFilter active) {
    return Container(
      color: AppColors.surface,
      child: Row(
        children: BookmarkFilter.values.map((f) {
          final isActive = f == active;
          return Expanded(
            child: InkWell(
              onTap: () => ref.read(bookmarkFilterProvider.notifier).state = f,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  f.name[0].toUpperCase() + f.name.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List<BookmarksTableData> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No bookmarks yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final b = list[index];
        return _BookmarkCard(
          bookmark: b,
          onDelete: () async {
            await ref.read(bookmarkRepositoryProvider).deleteBookmark(b.id);
          },
          onTap: () => _navigateToBookmark(context, b),
          onLongPress: () async {
            final summary = await BookmarkSummaryDialog.show(
              context,
              initialSummary: b.summary,
            );
            if (summary != null) {
              await ref
                  .read(bookmarkRepositoryProvider)
                  .updateSummary(b.id, summary);
            }
          },
        );
      },
    );
  }

  void _navigateToBookmark(BuildContext context, BookmarksTableData b) {
    if (b.type == 'hnArticle' && b.hnItemId != null) {
      context.push('/comments/${b.hnItemId}');
    } else if (b.type == 'hnComment') {
      if (b.hnUrl != null) {
        final storyIdMatch =
            RegExp(r'id=(\d+)').firstMatch(b.hnUrl!);
        if (storyIdMatch != null) {
          context.push('/comments/${storyIdMatch.group(1)}');
          return;
        }
      }
      if (b.hnItemId != null) {
        context.push('/comments/${b.hnItemId}');
      } else if (b.contentUrl != null) {
        _openUrl(b.contentUrl!);
      }
    } else if (b.contentUrl != null) {
      _openUrl(b.contentUrl!);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.bookmark,
    required this.onDelete,
    required this.onTap,
    required this.onLongPress,
  });

  final BookmarksTableData bookmark;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  IconData get _typeIcon {
    switch (bookmark.type) {
      case 'hnArticle':
        return Icons.article;
      case 'hnComment':
        return Icons.chat;
      case 'tweet':
        return Icons.alternate_email;
      case 'website':
        return Icons.language;
      default:
        return Icons.bookmark;
    }
  }

  String get _typeLabel {
    switch (bookmark.type) {
      case 'hnArticle':
        return 'Article';
      case 'hnComment':
        return 'Comment';
      case 'tweet':
        return 'Tweet';
      case 'website':
        return 'Web';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(bookmark.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_typeIcon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _typeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppDateUtils.timeAgo(bookmark.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (bookmark.isPublished) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              bookmark.publishedWeek ?? 'Published',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookmark.title ??
                          bookmark.contentText ??
                          bookmark.contentUrl ??
                          'No content',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (bookmark.domain != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        bookmark.domain!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (bookmark.summary != null &&
                        bookmark.summary!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bookmark.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
