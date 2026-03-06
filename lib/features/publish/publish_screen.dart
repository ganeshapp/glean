import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/markdown_generator.dart';
import '../../core/utils/week_utils.dart';
import '../../data/database/app_database.dart';
import '../bookmarks/bookmark_provider.dart';
import 'publish_provider.dart';



class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key});

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  final Set<int> _selectedIds = {};
  bool _isPublishing = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final unpublished = ref.watch(unpublishedBookmarksStreamProvider);
    final weekLabel = WeekUtils.weekLabel();
    final weekRange = WeekUtils.weekDateRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish to GitHub'),
      ),
      body: unpublished.when(
        data: (list) {
          if (!_initialized) {
            _selectedIds.addAll(list.map((b) => b.id));
            _initialized = true;
          }
          return _buildContent(list, weekLabel, weekRange);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildContent(
      List<BookmarksTableData> list, String weekLabel, String weekRange) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No unpublished bookmarks',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                weekRange,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedIds.length} of ${list.length} bookmarks selected',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final b = list[index];
              return CheckboxListTile(
                value: _selectedIds.contains(b.id),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedIds.add(b.id);
                    } else {
                      _selectedIds.remove(b.id);
                    }
                  });
                },
                title: Text(
                  b.title ?? b.contentText ?? b.contentUrl ?? 'Bookmark',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  _typeLabel(b.type),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                activeColor: AppColors.primary,
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _previewMarkdown(list, weekLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Preview'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed:
                      _selectedIds.isEmpty || _isPublishing
                          ? null
                          : () => _publish(list, weekLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _previewMarkdown(List<BookmarksTableData> allBookmarks, String weekLabel) {
    final selected =
        allBookmarks.where((b) => _selectedIds.contains(b.id)).toList();
    final md = MarkdownGenerator.generate(weekLabel, selected);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Markdown Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  md,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publish(
      List<BookmarksTableData> allBookmarks, String weekLabel) async {
    setState(() => _isPublishing = true);

    final selected =
        allBookmarks.where((b) => _selectedIds.contains(b.id)).toList();
    final md = MarkdownGenerator.generate(weekLabel, selected);
    final frontmatter =
        MarkdownGenerator.generateFrontmatter(weekLabel, DateTime.now());

    final github = ref.read(githubServiceProvider);
    final ok = await github.publishFile(
      content: md,
      weekLabel: weekLabel,
      frontmatter: frontmatter,
    );

    if (ok) {
      final ids = selected.map((b) => b.id).toList();
      await ref
          .read(bookmarkRepositoryProvider)
          .markAsPublished(ids, weekLabel);
    }

    if (mounted) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Published $weekLabel successfully!'
            : 'Failed to publish. Check your GitHub settings.'),
      ));
      if (ok) Navigator.pop(context);
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'hnArticle':
        return 'Article';
      case 'hnComment':
        return 'Comment';
      case 'tweet':
        return 'Tweet';
      case 'website':
        return 'Web';
      default:
        return type;
    }
  }
}
