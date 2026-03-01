import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/models/bookmark.dart';
import '../../data/repositories/bookmark_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository(ref.watch(appDatabaseProvider));
});

final bookmarksStreamProvider =
    StreamProvider<List<BookmarksTableData>>((ref) {
  return ref.watch(bookmarkRepositoryProvider).watchAll();
});

final unpublishedBookmarksStreamProvider =
    StreamProvider<List<BookmarksTableData>>((ref) {
  return ref.watch(bookmarkRepositoryProvider).watchUnpublished();
});

enum BookmarkFilter { all, articles, comments, external }

final bookmarkFilterProvider = StateProvider<BookmarkFilter>((ref) => BookmarkFilter.all);

final filteredBookmarksProvider = Provider<AsyncValue<List<BookmarksTableData>>>((ref) {
  final filter = ref.watch(bookmarkFilterProvider);
  final bookmarks = ref.watch(bookmarksStreamProvider);

  return bookmarks.whenData((list) {
    switch (filter) {
      case BookmarkFilter.all:
        return list;
      case BookmarkFilter.articles:
        return list.where((b) => b.type == BookmarkType.hnArticle.name).toList();
      case BookmarkFilter.comments:
        return list.where((b) => b.type == BookmarkType.hnComment.name).toList();
      case BookmarkFilter.external:
        return list
            .where((b) =>
                b.type == BookmarkType.tweet.name ||
                b.type == BookmarkType.website.name)
            .toList();
    }
  });
});
