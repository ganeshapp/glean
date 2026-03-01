import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../comment_provider.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.node,
    required this.onToggleCollapse,
    required this.onLongPress,
  });

  final CommentNode node;
  final VoidCallback onToggleCollapse;
  final VoidCallback onLongPress;

  Color _depthColor(int depth) {
    return AppColors.commentDepthColors[depth % AppColors.commentDepthColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final comment = node.comment;
    final cleaned = _stripHtml(comment.text ?? '');

    return GestureDetector(
      onTap: onToggleCollapse,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: node.depth > 0
                ? BorderSide(
                    color: _depthColor(node.depth - 1),
                    width: 3,
                  )
                : BorderSide.none,
          ),
        ),
        margin: EdgeInsets.only(left: node.depth * 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.by,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _depthColor(node.depth > 0 ? node.depth - 1 : 0),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppDateUtils.timeAgo(comment.dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (node.isCollapsed) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${node.totalChildCount} collapsed',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (!node.isCollapsed) ...[
              const SizedBox(height: 4),
              Text(
                cleaned,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<p>'), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<a[^>]*>'), '')
        .replaceAll(RegExp(r'</a>'), '')
        .replaceAll(RegExp(r'<pre><code>'), '\n')
        .replaceAll(RegExp(r'</code></pre>'), '\n')
        .replaceAll(RegExp(r'<code>'), '')
        .replaceAll(RegExp(r'</code>'), '')
        .replaceAll(RegExp(r'<i>'), '')
        .replaceAll(RegExp(r'</i>'), '')
        .replaceAll(RegExp(r'<b>'), '')
        .replaceAll(RegExp(r'</b>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .trim();
  }
}
