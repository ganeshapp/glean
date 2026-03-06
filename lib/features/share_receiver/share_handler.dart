import 'dart:async';

import 'package:dio/dio.dart';
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
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

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

  void _handleShared(SharedMediaFile media) async {
    final text = media.path;
    if (text.isEmpty) return;

    var parsed = _parseSharedContent(text);

    if (parsed.type == BookmarkType.tweet && parsed.url != null) {
      final tweetData = await _fetchTweetOembed(parsed.url!);
      if (tweetData != null) {
        parsed = _ParsedShare(
          type: BookmarkType.tweet,
          text: parsed.text ?? tweetData['text'],
          url: parsed.url,
          author: parsed.author ?? tweetData['author'],
          title: null,
        );
      }
    } else if (parsed.type == BookmarkType.website && parsed.url != null) {
      if (parsed.title == null || parsed.title!.isEmpty) {
        final title = await _fetchPageTitle(parsed.url!);
        if (title != null) {
          parsed = _ParsedShare(
            type: BookmarkType.website,
            text: parsed.text,
            url: parsed.url,
            author: parsed.author,
            title: title,
          );
        }
      }
    }

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
          RegExp(r'(?:twitter\.com|x\.com)/(\w+)/status/').firstMatch(url);
      String? author;
      if (authorMatch != null && authorMatch.group(1) != 'i') {
        author = '@${authorMatch.group(1)}';
      }
      return _ParsedShare(
        type: BookmarkType.tweet,
        text: cleanText.isNotEmpty ? cleanText : null,
        url: url,
        author: author,
      );
    }

    return _ParsedShare(
      type: BookmarkType.website,
      text: cleanText.isNotEmpty ? cleanText : null,
      url: url,
    );
  }

  Future<Map<String, String>?> _fetchTweetOembed(String tweetUrl) async {
    try {
      final response = await _dio.get(
        'https://publish.twitter.com/oembed',
        queryParameters: {'url': tweetUrl, 'omit_script': 'true'},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final authorUrl = data['author_url'] as String?;
        final html = data['html'] as String?;

        String? author;
        if (authorUrl != null) {
          final handleMatch =
              RegExp(r'(?:twitter\.com|x\.com)/(\w+)').firstMatch(authorUrl);
          if (handleMatch != null) {
            author = '@${handleMatch.group(1)}';
          }
        }
        author ??= data['author_name'] as String?;

        String? tweetText;
        if (html != null) {
          final pMatch =
              RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).firstMatch(html);
          if (pMatch != null) {
            tweetText = pMatch
                .group(1)!
                .replaceAll(RegExp(r'<[^>]+>'), '')
                .replaceAll('&mdash;', '\u2014')
                .replaceAll('&amp;', '&')
                .replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>')
                .replaceAll('&quot;', '"')
                .replaceAll('&#39;', "'")
                .trim();
          }
        }

        final result = <String, String>{};
        if (author != null) result['author'] = author;
        if (tweetText != null && tweetText.isNotEmpty) {
          result['text'] = tweetText;
        }
        return result.isNotEmpty ? result : null;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _fetchPageTitle(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
          },
          responseType: ResponseType.plain,
        ),
      );
      if (response.statusCode == 200) {
        final body = response.data.toString();
        final titleMatch =
            RegExp(r'<title[^>]*>([^<]+)</title>', caseSensitive: false)
                .firstMatch(body);
        return titleMatch?.group(1)?.trim();
      }
    } catch (_) {}
    return null;
  }

  void _showSaveSheet(_ParsedShare parsed) {
    if (!_context.mounted) return;
    final summaryController = TextEditingController();
    final titleController =
        TextEditingController(text: parsed.title ?? '');

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
            if (parsed.author != null)
              Text(
                parsed.author!,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            if (parsed.url != null) ...[
              const SizedBox(height: 4),
              Text(
                parsed.url!,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: parsed.type == BookmarkType.tweet
                    ? 'Author handle (optional)'
                    : 'Title (optional)',
                isDense: true,
              ),
            ),
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
                  final authorOrTitle =
                      titleController.text.trim().isNotEmpty
                          ? titleController.text.trim()
                          : null;

                  final bookmark = Bookmark(
                    type: parsed.type,
                    title: parsed.type == BookmarkType.website
                        ? (authorOrTitle ?? parsed.title)
                        : null,
                    contentText: parsed.text,
                    contentUrl: parsed.url,
                    author: parsed.type == BookmarkType.tweet
                        ? (authorOrTitle ?? parsed.author)
                        : null,
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
  final String? title;

  _ParsedShare({
    required this.type,
    this.text,
    this.url,
    this.author,
    this.title,
  });
}
