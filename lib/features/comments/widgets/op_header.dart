import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/hn_story.dart';

class OpHeader extends StatelessWidget {
  const OpHeader({super.key, required this.story});

  final HnStory story;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.title ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          if (story.url != null && story.url!.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                await launchUrl(Uri.parse(story.url!),
                    mode: LaunchMode.externalApplication);
              },
              child: Text(
                story.url!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '+${story.score}  ${story.descendants} comments  '
            '${AppDateUtils.timeAgo(story.dateTime)}  by: ${story.by}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (story.text != null && story.text!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _HtmlText(html: story.text!),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class _HtmlText extends StatelessWidget {
  const _HtmlText({required this.html});
  final String html;

  @override
  Widget build(BuildContext context) {
    final cleaned = html
        .replaceAll(RegExp(r'<p>'), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<i>'), '')
        .replaceAll(RegExp(r'</i>'), '')
        .replaceAll(RegExp(r'<b>'), '')
        .replaceAll(RegExp(r'</b>'), '')
        .replaceAll(RegExp(r'<a[^>]*>'), '')
        .replaceAll(RegExp(r'</a>'), '')
        .replaceAll(RegExp(r'<pre><code>'), '\n')
        .replaceAll(RegExp(r'</code></pre>'), '\n')
        .replaceAll(RegExp(r'<code>'), '')
        .replaceAll(RegExp(r'</code>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .trim();

    return Text(
      cleaned,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    );
  }
}
