import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/hn_story.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.fontSize = 16.0,
    this.lineHeight = 1.3,
    this.isRead = false,
    this.onRead,
  });

  final HnStory story;
  final double fontSize;
  final double lineHeight;
  final bool isRead;
  final VoidCallback? onRead;

  Future<void> _openArticle() async {
    final url = story.url;
    if (url != null && url.isNotEmpty) {
      onRead?.call();
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openArticle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMeta(),
                  const SizedBox(height: 4),
                  Text(
                    story.title ?? '(no title)',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      height: lineHeight,
                    ),
                  ),
                  if (story.domain != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      story.domain!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildCommentButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Text(
          '+ ${story.score}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppDateUtils.timeAgo(story.dateTime),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return InkWell(
      onTap: () {
        onRead?.call();
        context.push('/comments/${story.id}');
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              '${story.descendants}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
