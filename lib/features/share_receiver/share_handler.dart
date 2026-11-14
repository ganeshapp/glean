import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart' as html;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../core/utils/content_utils.dart';
import '../../data/database/app_database.dart';
import '../../data/models/bookmark.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../bookmarks/bookmark_provider.dart';
import '../capture/save_actions.dart';

class SharedCapture {
  final String? url, text, author;
  final BookmarkType type;
  final int? hnId;
  const SharedCapture({
    this.url,
    this.text,
    this.author,
    required this.type,
    this.hnId,
  });
  static SharedCapture parse(String shared) {
    final match = RegExp(r'https?://[^\s<>]+').firstMatch(shared);
    final raw = match?.group(0)?.replaceAll(RegExp(r'[.,;!]+$'), '');
    final url = safeWebUrl(raw);
    final uri = Uri.tryParse(url ?? '');
    final host =
        uri?.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '') ?? '';
    final text =
        match == null
            ? shared.trim()
            : shared.replaceRange(match.start, match.end, '').trim();
    final tweet = [
      'twitter.com',
      'x.com',
      'mobile.twitter.com',
      'mobile.x.com',
    ].contains(host);
    final video = ['youtube.com', 'm.youtube.com', 'youtu.be'].contains(host);
    final author =
        tweet &&
                (uri?.pathSegments.length ?? 0) >= 3 &&
                uri!.pathSegments[1] == 'status' &&
                uri.pathSegments.first != 'i'
            ? '@${uri.pathSegments.first}'
            : null;
    return SharedCapture(
      url: url,
      text: text.isEmpty ? null : text,
      author: author,
      hnId:
          host == 'news.ycombinator.com'
              ? int.tryParse(uri?.queryParameters['id'] ?? '')
              : null,
      type:
          tweet
              ? BookmarkType.tweet
              : video
              ? BookmarkType.video
              : BookmarkType.website,
    );
  }
}

class ShareHandler {
  StreamSubscription? _subscription;
  final WidgetRef ref;
  final BuildContext context;
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
  Future<void> queue = Future.value();
  ShareHandler(this.ref, this.context);
  void init() {
    ReceiveSharingIntent.instance.getInitialMedia().then((items) {
      for (final item in items) {
        enqueue(item.path);
      }
      ReceiveSharingIntent.instance.reset();
    });
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen((
      items,
    ) {
      for (final item in items) {
        enqueue(item.path);
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    dio.close();
  }

  void enqueue(String text) {
    queue = queue.then((_) => capture(text)).catchError((Object _) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save the shared item. Please share it again.',
            ),
          ),
        );
      }
    });
  }

  Future<void> capture(String text) async {
    if (text.trim().isEmpty) return;
    final capture = SharedCapture.parse(text);
    final repo = ref.read(bookmarkRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final before = await repo.getAll();
    final id = await repo.addBookmark(
      Bookmark(
        type: capture.type,
        contentUrl: capture.url,
        contentText: capture.text,
        author: capture.author,
        hnItemId: capture.hnId,
        hnUrl: capture.hnId == null ? null : capture.url,
        domain: capture.url == null ? null : Uri.parse(capture.url!).host,
      ),
    );
    final isNew = !before.any((b) => b.id == id);
    // Persistence precedes all metadata requests and UI interactions.
    unawaited(enrich(db, id, capture));
    if (!context.mounted) return;
    var acting = false;
    await showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => StatefulBuilder(
            builder: (ctx, set) {
              Future<void> finish({
                Future<void> Function()? action,
                VoidCallback? after,
              }) async {
                if (acting) return;
                set(() => acting = true);
                try {
                  if (action != null) await action();
                  if (ctx.mounted && ModalRoute.of(ctx)?.isCurrent == true) {
                    Navigator.pop(ctx);
                    after?.call();
                  }
                } catch (_) {
                  if (ctx.mounted) {
                    set(() => acting = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not finish. Please try again.'),
                      ),
                    );
                  }
                }
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isNew ? 'Saved' : 'Already in your library',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        capture.url ?? capture.text ?? 'Saved excerpt',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Add a thought'),
                        onPressed:
                            acting
                                ? null
                                : () => finish(
                                  after: () => context.push('/saved/$id'),
                                ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('Include this week'),
                        onPressed:
                            acting
                                ? null
                                : () => finish(
                                  action: () async {
                                    await SaveActions.includeThisWeek(ref, id);
                                  },
                                ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isNew)
                            TextButton(
                              onPressed:
                                  acting
                                      ? null
                                      : () => finish(
                                        action: () => repo.archive(id, true),
                                      ),
                              child: const Text('Undo save'),
                            ),
                          TextButton(
                            onPressed: acting ? null : () => finish(),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> enrich(AppDatabase db, int id, SharedCapture capture) async {
    try {
      String? title, excerpt, author;
      String? type, hnUrl, sourceUrl;
      if (capture.hnId != null) {
        final response = await dio.get(
          'https://hacker-news.firebaseio.com/v0/item/${capture.hnId}.json',
        );
        final item = response.data as Map?;
        if (item == null || item['deleted'] == true || item['dead'] == true) {
          return;
        }
        type = item['type'] == 'comment' ? 'hnComment' : 'hnArticle';
        title = item['title'] as String?;
        excerpt = item['text'] is String ? plainText(item['text']) : null;
        author = item['by'] as String?;
        sourceUrl = item['url'] as String? ?? capture.url;
        hnUrl = capture.url;
        if (type == 'hnComment') {
          var parent = item['parent'] as int?;
          for (var i = 0; i < 20 && parent != null; i++) {
            final next =
                (await dio.get(
                      'https://hacker-news.firebaseio.com/v0/item/$parent.json',
                    )).data
                    as Map?;
            if (next == null) break;
            if (next['type'] != 'comment') {
              hnUrl = 'https://news.ycombinator.com/item?id=$parent';
              break;
            }
            parent = next['parent'] as int?;
          }
        }
      } else if (capture.url != null && capture.type == BookmarkType.tweet) {
        final response = await dio.get(
          'https://publish.twitter.com/oembed',
          queryParameters: {'url': capture.url, 'omit_script': true},
        );
        final data = response.data as Map;
        excerpt =
            html
                .parseFragment(data['html'] as String? ?? '')
                .querySelector('p')
                ?.text;
        author = capture.author ?? data['author_name'] as String?;
      } else if (capture.url != null && capture.type == BookmarkType.video) {
        final response = await dio.get(
          'https://www.youtube.com/oembed',
          queryParameters: {'url': capture.url, 'format': 'json'},
        );
        title = response.data['title'] as String?;
        author = response.data['author_name'] as String?;
      } else if (capture.url != null) {
        final response = await dio.get<String>(
          capture.url!,
          options: Options(responseType: ResponseType.plain),
        );
        title =
            html.parse(response.data ?? '').querySelector('title')?.text.trim();
      }
      await BookmarkRepository(db).enrich(
        id,
        capturedUrl: capture.url,
        title: title,
        excerpt: excerpt,
        author: author,
        type: type,
        discussionUrl: hnUrl,
        sourceUrl: sourceUrl,
      );
    } catch (_) {
      /* The saved URL/text remains usable offline or when metadata is unavailable. */
    }
  }
}
