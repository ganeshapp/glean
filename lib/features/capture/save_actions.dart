import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/hn_story.dart';
import '../bookmarks/bookmark_provider.dart';
import '../publish/roundup_provider.dart';

class SaveActions {
  static Future<void> story(
    BuildContext context,
    WidgetRef ref,
    HnStory story,
  ) => save(
    context,
    ref,
    Bookmark(
      type: BookmarkType.hnArticle,
      title: story.title,
      contentUrl: story.url,
      hnUrl: 'https://news.ycombinator.com/item?id=${story.id}',
      hnItemId: story.id,
      domain: story.domain,
    ),
  );
  static Future<void> save(
    BuildContext context,
    WidgetRef ref,
    Bookmark bookmark,
  ) async {
    try {
      final id = await ref
          .read(bookmarkRepositoryProvider)
          .addBookmark(bookmark);
      if (context.mounted) receipt(context, ref, id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    }
  }

  static void receipt(BuildContext context, WidgetRef ref, int id) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved to your library'),
        action: SnackBarAction(
          label: 'Add thought',
          onPressed: () => context.push('/saved/$id'),
        ),
      ),
    );
  }

  static Future<void> includeThisWeek(WidgetRef ref, int id) async {
    final b = await ref.read(bookmarkRepositoryProvider).get(id);
    if (b == null) return;
    final issue = await ref.read(roundupRepositoryProvider).ensureWeek();
    await ref.read(roundupRepositoryProvider).include(issue.id, b);
  }
}
