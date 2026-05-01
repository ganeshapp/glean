import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../comment_provider.dart';

class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.node,
    required this.onToggleCollapse,
    required this.onLongPress,
    this.isBookmarked = false,
  });

  final CommentNode node;
  final VoidCallback onToggleCollapse;
  final VoidCallback onLongPress;
  final bool isBookmarked;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  Color _depthColor(int depth) {
    return AppColors.commentDepthColors[depth % AppColors.commentDepthColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final comment = node.comment;
    final spans = _buildSpans(comment.text ?? '');

    return GestureDetector(
      onTap: widget.onToggleCollapse,
      onLongPress: widget.onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isBookmarked
              ? AppColors.primary.withValues(alpha: 0.06)
              : null,
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
                if (widget.isBookmarked) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.bookmark,
                    size: 14,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ],
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
              Text.rich(
                TextSpan(children: spans),
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

  static final _linkRegex = RegExp(
    r'<a\s+[^>]*?href="([^"]+)"[^>]*?>(.*?)</a>',
    caseSensitive: false,
    dotAll: true,
  );

  List<InlineSpan> _buildSpans(String html) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];
    int last = 0;
    for (final match in _linkRegex.allMatches(html)) {
      if (match.start > last) {
        final text = _stripHtml(html.substring(last, match.start));
        if (text.isNotEmpty) spans.add(TextSpan(text: text));
      }
      final href = _decodeEntities(match.group(1)!);
      final linkText = _stripHtml(match.group(2)!);
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _openUrl(href);
      _recognizers.add(recognizer);
      spans.add(TextSpan(
        text: linkText.isEmpty ? href : linkText,
        style: const TextStyle(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
        recognizer: recognizer,
      ));
      last = match.end;
    }
    if (last < html.length) {
      final text = _stripHtml(html.substring(last));
      if (text.isNotEmpty) spans.add(TextSpan(text: text));
    }
    return spans;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _stripHtml(String html) {
    return _decodeEntities(
      html
          .replaceAll(RegExp(r'<p>'), '\n\n')
          .replaceAll(RegExp(r'<br\s*/?>'), '\n')
          .replaceAll(RegExp(r'<pre><code>'), '\n')
          .replaceAll(RegExp(r'</code></pre>'), '\n')
          .replaceAll(RegExp(r'<code>'), '')
          .replaceAll(RegExp(r'</code>'), '')
          .replaceAll(RegExp(r'<i>'), '')
          .replaceAll(RegExp(r'</i>'), '')
          .replaceAll(RegExp(r'<b>'), '')
          .replaceAll(RegExp(r'</b>'), '')
          .replaceAll(RegExp(r'<[^>]+>'), ''),
    );
  }

  String _decodeEntities(String s) {
    return s
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&amp;', '&');
  }
}
