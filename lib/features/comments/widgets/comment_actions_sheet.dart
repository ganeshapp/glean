import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/hn_comment.dart';

class CommentActionsSheet extends StatelessWidget {
  const CommentActionsSheet({
    super.key,
    required this.comment,
    required this.onAction,
  });

  final HnComment comment;
  final void Function(CommentAction action) onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          _buildAction(context, Icons.arrow_upward, 'Upvote', CommentAction.upvote),
          _buildAction(context, Icons.arrow_downward, 'Downvote', CommentAction.downvote),
          _buildAction(context, Icons.reply, 'Reply', CommentAction.reply),
          _buildAction(context, Icons.person, 'Author profile', CommentAction.authorProfile),
          _buildAction(context, Icons.share, 'Share link to...', CommentAction.shareLink),
          _buildAction(context, Icons.send, 'Send comment text to...', CommentAction.sendText),
          _buildAction(context, Icons.bookmark_add, 'Bookmark comment', CommentAction.bookmark),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAction(
      BuildContext context, IconData icon, String label, CommentAction action) {
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
  upvote,
  downvote,
  reply,
  authorProfile,
  shareLink,
  sendText,
  bookmark,
}
