import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/hn_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/bookmark.dart';
import '../auth/auth_provider.dart';
import '../auth/login_dialog.dart';
import '../bookmarks/bookmark_provider.dart';
import '../bookmarks/widgets/bookmark_summary_dialog.dart';
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
        _openUrl(url);
      case CommentAction.authorProfile:
        final url = HnConstants.userUrl(node.comment.by);
        _openUrl(url);
      case CommentAction.sendText:
        // Will be wired to share functionality
        break;
      case CommentAction.bookmark:
        _bookmarkComment(node);
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

  Future<void> _bookmarkArticle() async {
    final state = ref.read(commentsNotifierProvider(widget.storyId));
    final story = state.story;
    if (story == null) return;

    final summary = await BookmarkSummaryDialog.show(context);

    final bookmark = Bookmark(
      type: BookmarkType.hnArticle,
      title: story.title,
      contentUrl: story.url,
      hnUrl: HnConstants.itemUrl(story.id),
      hnItemId: story.id,
      domain: story.domain,
      summary: (summary != null && summary.isNotEmpty) ? summary : null,
    );

    await ref.read(bookmarkRepositoryProvider).addBookmark(bookmark);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article bookmarked')),
      );
    }
  }

  void _bookmarkComment(CommentNode node) async {
    final stripped = _stripHtml(node.comment.text ?? '');
    final bookmark = Bookmark(
      type: BookmarkType.hnComment,
      contentText: stripped,
      contentUrl: HnConstants.itemUrl(node.comment.id),
      hnItemId: node.comment.id,
      author: node.comment.by,
    );

    await ref.read(bookmarkRepositoryProvider).addBookmark(bookmark);
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
        _openUrl(HnConstants.itemUrl(widget.storyId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsNotifierProvider(widget.storyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _openUrl(HnConstants.itemUrl(widget.storyId)),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _bookmarkArticle,
          ),
          PopupMenuButton<String>(
            onSelected: _handleOverflowAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              PopupMenuItem(value: 'upvote', child: Text('Upvote')),
              PopupMenuItem(value: 'reply', child: Text('Reply')),
              PopupMenuItem(value: 'share', child: Text('Share link')),
              PopupMenuItem(value: 'typography', child: Text('Typography')),
            ],
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CommentsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
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
      );
    }

    final flatList = _flattenTree(state.commentTree);

    return ListView.builder(
      itemCount: flatList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          if (state.story == null) return const SizedBox.shrink();
          return OpHeader(story: state.story!);
        }
        final node = flatList[index - 1];
        return CommentTile(
          node: node,
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
                onAction: (action) => _onCommentAction(action, node),
              ),
            );
          },
        );
      },
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
