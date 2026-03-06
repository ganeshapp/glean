import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/hn_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/bookmark.dart';
import '../auth/auth_provider.dart';
import '../auth/login_dialog.dart';
import '../bookmarks/bookmark_provider.dart';
import '../feed/widgets/typography_bar.dart';
import 'comment_provider.dart';
import 'widgets/comment_actions_sheet.dart';
import 'widgets/comment_tile.dart';
import 'widgets/op_header.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.storyId});

  final int storyId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  bool _showTypography = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(commentsNotifierProvider(widget.storyId).notifier).load();
    });
  }

  Future<void> _requireAuth(Future<void> Function() action) async {
    final isLoggedIn = ref.read(authNotifierProvider).isLoggedIn;
    if (!isLoggedIn) {
      final result = await LoginDialog.show(context);
      if (result != true) return;
    }
    await action();
  }

  void _onCommentAction(CommentAction action, CommentNode node) {
    switch (action) {
      case CommentAction.upvote:
        _requireAuth(() async {
          final repo = ref.read(authRepositoryProvider);
          final ok = await repo.upvote(node.comment.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? 'Upvoted' : 'Failed to upvote'),
            ));
          }
        });
      case CommentAction.downvote:
        _requireAuth(() async {
          final repo = ref.read(authRepositoryProvider);
          final ok = await repo.downvote(node.comment.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? 'Downvoted' : 'Failed to downvote'),
            ));
          }
        });
      case CommentAction.reply:
        _requireAuth(() async {
          await _showReplyDialog(node.comment.id);
        });
      case CommentAction.shareLink:
        final url = HnConstants.itemUrl(node.comment.id);
        Share.share(url);
      case CommentAction.authorProfile:
        final url = HnConstants.userUrl(node.comment.by);
        _openUrl(url);
      case CommentAction.sendText:
        final text = _stripHtml(node.comment.text ?? '');
        if (text.isNotEmpty) {
          Share.share(
            '$text\n\n-- ${node.comment.by}\n${HnConstants.itemUrl(node.comment.id)}',
          );
        }
      case CommentAction.bookmark:
        _toggleCommentBookmark(node);
    }
  }

  Future<void> _showReplyDialog(int parentId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('SEND'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && result.trim().isNotEmpty) {
      final repo = ref.read(authRepositoryProvider);
      final ok = await repo.reply(parentId, result.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Reply sent' : 'Failed to send reply'),
        ));
        if (ok) {
          ref
              .read(commentsNotifierProvider(widget.storyId).notifier)
              .load();
        }
      }
    }
  }

  Future<void> _toggleArticleBookmark() async {
    final repo = ref.read(bookmarkRepositoryProvider);
    final isAlready = ref.read(isItemBookmarkedProvider(widget.storyId));

    if (isAlready) {
      await repo.deleteByHnItemId(widget.storyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
      }
      return;
    }

    final state = ref.read(commentsNotifierProvider(widget.storyId));
    final story = state.story;
    if (story == null) return;

    final bookmark = Bookmark(
      type: BookmarkType.hnArticle,
      title: story.title,
      contentUrl: story.url,
      hnUrl: HnConstants.itemUrl(story.id),
      hnItemId: story.id,
      domain: story.domain,
    );

    await repo.addBookmark(bookmark);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article bookmarked')),
      );
    }
  }

  void _toggleCommentBookmark(CommentNode node) async {
    final repo = ref.read(bookmarkRepositoryProvider);
    final isAlready = ref.read(isItemBookmarkedProvider(node.comment.id));

    if (isAlready) {
      await repo.deleteByHnItemId(node.comment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
      }
      return;
    }

    final stripped = _stripHtml(node.comment.text ?? '');
    final bookmark = Bookmark(
      type: BookmarkType.hnComment,
      contentText: stripped,
      contentUrl: HnConstants.itemUrl(node.comment.id),
      hnItemId: node.comment.id,
      hnUrl: HnConstants.itemUrl(widget.storyId),
      author: node.comment.by,
    );

    await repo.addBookmark(bookmark);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment bookmarked')),
      );
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<p>'), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .trim();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleOverflowAction(String value) {
    switch (value) {
      case 'refresh':
        ref
            .read(commentsNotifierProvider(widget.storyId).notifier)
            .load();
      case 'upvote':
        _requireAuth(() async {
          final repo = ref.read(authRepositoryProvider);
          final ok = await repo.upvote(widget.storyId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? 'Upvoted' : 'Failed to upvote'),
            ));
          }
        });
      case 'reply':
        _requireAuth(() => _showReplyDialog(widget.storyId));
      case 'share':
        final url = HnConstants.itemUrl(widget.storyId);
        Share.share(url);
      case 'typography':
        setState(() => _showTypography = !_showTypography);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsNotifierProvider(widget.storyId));
    final isBookmarked = ref.watch(isItemBookmarkedProvider(widget.storyId));

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('Comments'),
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () =>
                    _openUrl(HnConstants.itemUrl(widget.storyId)),
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: _toggleArticleBookmark,
              ),
              PopupMenuButton<String>(
                onSelected: _handleOverflowAction,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'refresh', child: Text('Refresh')),
                  PopupMenuItem(value: 'upvote', child: Text('Upvote')),
                  PopupMenuItem(value: 'reply', child: Text('Reply')),
                  PopupMenuItem(value: 'share', child: Text('Share link')),
                  PopupMenuItem(
                      value: 'typography', child: Text('Typography')),
                ],
              ),
            ],
          ),
          if (_showTypography)
            SliverToBoxAdapter(
              child: TypographyBar(
                onDone: () => setState(() => _showTypography = false),
              ),
            ),
          _buildSliverBody(state),
        ],
      ),
    );
  }

  Widget _buildSliverBody(CommentsState state) {
    if (state.isLoading && state.commentTree.isEmpty && state.story == null) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.error != null && state.story == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(state.error!,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(commentsNotifierProvider(widget.storyId).notifier)
                    .load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final flatList = _flattenTree(state.commentTree);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            if (state.story == null) return const SizedBox.shrink();
            return OpHeader(story: state.story!);
          }
          if (state.isLoading && flatList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final nodeIndex = index - 1;
          if (nodeIndex >= flatList.length) return const SizedBox.shrink();
          final node = flatList[nodeIndex];
          final bookmarkedIds = ref.watch(bookmarkedItemIdsProvider);
          final isCommentBookmarked =
              bookmarkedIds.contains(node.comment.id);
          return CommentTile(
            node: node,
            isBookmarked: isCommentBookmarked,
            onToggleCollapse: () {
              ref
                  .read(commentsNotifierProvider(widget.storyId).notifier)
                  .toggleCollapse(node.comment.id);
            },
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => CommentActionsSheet(
                  comment: node.comment,
                  isBookmarked: isCommentBookmarked,
                  onAction: (action) => _onCommentAction(action, node),
                ),
              );
            },
          );
        },
        childCount: (state.story != null ? 1 : 0) +
            (state.isLoading && flatList.isEmpty ? 1 : flatList.length),
      ),
    );
  }

  List<CommentNode> _flattenTree(List<CommentNode> nodes) {
    final result = <CommentNode>[];
    for (final node in nodes) {
      result.add(node);
      if (!node.isCollapsed) {
        result.addAll(_flattenTree(node.children));
      }
    }
    return result;
  }
}
