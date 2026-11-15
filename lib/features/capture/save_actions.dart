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
  ) => toggle(
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
  static Future<void> toggle(
    BuildContext context,
    WidgetRef ref,
    Bookmark bookmark,
  ) async {
    try {
      final repo = ref.read(bookmarkRepositoryProvider);
      final result = await repo.toggleHnBookmark(bookmark);
      if (!context.mounted) return;
      if (result.isSaved) {
        receipt(context, ref, result.id);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from saved'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await repo.archive(result.id, false);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not restore. Please try again.'),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update saved item. Please try again.'),
          ),
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
