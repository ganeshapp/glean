import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/bookmark.dart';

class BookmarkRepository {
  final AppDatabase _db;

  BookmarkRepository(this._db);

  Stream<List<BookmarksTableData>> watchAll() => _db.watchAllBookmarks();
  Stream<List<BookmarksTableData>> watchUnpublished() => _db.watchUnpublishedBookmarks();

  Future<List<BookmarksTableData>> getAll() => _db.getAllBookmarks();
  Future<List<BookmarksTableData>> getUnpublished() => _db.getUnpublishedBookmarks();
  Future<List<BookmarksTableData>> getByType(String type) => _db.getBookmarksByType(type);

  Future<int> addBookmark(Bookmark bookmark) {
    return _db.insertBookmark(BookmarksTableCompanion.insert(
      type: bookmark.type.name,
      title: Value(bookmark.title),
      contentText: Value(bookmark.contentText),
      contentUrl: Value(bookmark.contentUrl),
      hnUrl: Value(bookmark.hnUrl),
      hnItemId: Value(bookmark.hnItemId),
      author: Value(bookmark.author),
      summary: Value(bookmark.summary),
      domain: Value(bookmark.domain),
    ));
  }

  Future<bool> updateSummary(int id, String summary) {
    return _db.updateBookmark(
      BookmarksTableCompanion(summary: Value(summary)),
      id,
    );
  }

  Future<int> deleteBookmark(int id) => _db.deleteBookmark(id);

  Future<void> markAsPublished(List<int> ids, String weekLabel) {
    return _db.markAsPublished(ids, weekLabel);
  }

  Future<int> clearAll() => _db.clearAllBookmarks();
}
