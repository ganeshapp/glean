import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/bookmark.dart';
import '../bookmarks/bookmark_provider.dart';

class ShareHandler {
  StreamSubscription? _subscription;
  final WidgetRef _ref;
  final BuildContext _context;

  ShareHandler(this._ref, this._context);

  void init() {
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _handleShared(value.first);
      }
    });

    _subscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleShared(value.first);
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _handleShared(SharedMediaFile media) {
    final text = media.path;
    if (text.isEmpty) return;

    final parsed = _parseSharedContent(text);
    _showSaveSheet(parsed);
  }

  _ParsedShare _parseSharedContent(String text) {
    final urlRegex = RegExp(r'https?://\S+');
    final match = urlRegex.firstMatch(text);
    final url = match?.group(0);
    final cleanText = text.replaceAll(urlRegex, '').trim();

    if (url != null &&
        (url.contains('twitter.com') ||
            url.contains('x.com') ||
            url.contains('nitter.'))) {
      final authorMatch =
          RegExp(r'(?:twitter\.com|x\.com)/(\w+)').firstMatch(url);
      return _ParsedShare(
        type: BookmarkType.tweet,
        text: cleanText.isNotEmpty ? cleanText : null,
        url: url,
        author: authorMatch != null ? '@${authorMatch.group(1)}' : null,
      );
    }

    return _ParsedShare(
      type: BookmarkType.website,
      text: cleanText.isNotEmpty ? cleanText : null,
      url: url,
    );
  }

  void _showSaveSheet(_ParsedShare parsed) {
    if (!_context.mounted) return;
    final summaryController = TextEditingController();
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: _context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  parsed.type == BookmarkType.tweet
                      ? Icons.alternate_email
                      : Icons.language,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  parsed.type == BookmarkType.tweet
                      ? 'Save Tweet'
                      : 'Save Web Snippet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (parsed.url != null)
              Text(
                parsed.url!,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (parsed.text != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  parsed.text!,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
            ],
            if (parsed.type == BookmarkType.website) ...[
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  isDense: true,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary (optional)',
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final bookmark = Bookmark(
                    type: parsed.type,
                    title: titleController.text.trim().isNotEmpty
                        ? titleController.text.trim()
                        : null,
                    contentText: parsed.text,
                    contentUrl: parsed.url,
                    author: parsed.author,
                    summary: summaryController.text.trim().isNotEmpty
                        ? summaryController.text.trim()
                        : null,
                    domain: parsed.url != null
                        ? Uri.tryParse(parsed.url!)?.host
                        : null,
                  );
                  await _ref
                      .read(bookmarkRepositoryProvider)
                      .addBookmark(bookmark);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(_context).showSnackBar(
                      const SnackBar(content: Text('Saved to bookmarks')),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ParsedShare {
  final BookmarkType type;
  final String? text;
  final String? url;
  final String? author;

  _ParsedShare({
    required this.type,
    this.text,
    this.url,
    this.author,
  });
}
