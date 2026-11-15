import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/hn_comment.dart';

class CommentActionsSheet extends StatelessWidget {
  const CommentActionsSheet({
    super.key,
    required this.comment,
    required this.onAction,
    this.isBookmarked = false,
  });

  final HnComment comment;
  final void Function(CommentAction action) onAction;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _buildAction(
              context,
              isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
              isBookmarked ? 'Remove saved comment' : 'Save comment',
              CommentAction.bookmark,
            ),
            _buildAction(
              context,
              Icons.copy,
              'Copy text',
              CommentAction.copyText,
            ),
            _buildAction(
              context,
              Icons.text_fields,
              'Select text…',
              CommentAction.selectText,
            ),
            _buildAction(
              context,
              Icons.arrow_upward,
              'Upvote',
              CommentAction.upvote,
            ),
            _buildAction(
              context,
              Icons.arrow_downward,
              'Downvote',
              CommentAction.downvote,
            ),
            _buildAction(context, Icons.reply, 'Reply', CommentAction.reply),
            _buildAction(
              context,
              Icons.person,
              'Author profile',
              CommentAction.authorProfile,
            ),
            _buildAction(
              context,
              Icons.share,
              'Share link to...',
              CommentAction.shareLink,
            ),
            _buildAction(
              context,
              Icons.send,
              'Send comment text to...',
              CommentAction.sendText,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    CommentAction action,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onAction(action);
      },
    );
  }
}

enum CommentAction {
  copyText,
  selectText,
  upvote,
  downvote,
  reply,
  authorProfile,
  shareLink,
  sendText,
  bookmark,
}
