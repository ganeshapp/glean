import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/bookmark.dart';
import '../../core/utils/content_utils.dart';

class BookmarkRepository {
  final AppDatabase _db;

  BookmarkRepository(this._db);

  Stream<List<BookmarksTableData>> watchAll() => _db.watchAllBookmarks();
  Stream<List<BookmarksTableData>> watchUnpublished() =>
      _db.watchUnpublishedBookmarks();

  Future<List<BookmarksTableData>> getAll() => _db.getAllBookmarks();
  Future<List<BookmarksTableData>> getUnpublished() =>
      _db.getUnpublishedBookmarks();
  Future<List<BookmarksTableData>> getByType(String type) =>
      _db.getBookmarksByType(type);

  Future<bool> isBookmarked(int hnItemId) => _db.isBookmarked(hnItemId);

  Future<BookmarksTableData?> get(int id) =>
      (_db.select(_db.bookmarksTable)
        ..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> archive(int id, bool archived) async {
    await _db.updateBookmark(
      BookmarksTableCompanion(archived: Value(archived)),
      id,
    );
  }

  Future<int> addBookmark(Bookmark bookmark) => _db.transaction(() async {
    final key =
        bookmark.type == BookmarkType.hnComment
            ? 'comment:${bookmark.hnItemId}'
            : canonicalUrl(bookmark.contentUrl ?? bookmark.hnUrl);
    final all = await getAll();
    for (final old in all) {
      final oldKey =
          old.type == 'hnComment'
              ? 'comment:${old.hnItemId}'
              : canonicalUrl(old.contentUrl ?? old.hnUrl);
      if ((bookmark.hnItemId != null && old.hnItemId == bookmark.hnItemId) ||
          (key != null && oldKey == key)) {
        await _db.updateBookmark(
          BookmarksTableCompanion(
            archived: const Value(false),
            canonicalKey: Value(key),
            hnItemId:
                old.hnItemId == null
                    ? Value(bookmark.hnItemId)
                    : const Value.absent(),
            hnUrl:
                old.hnUrl == null
                    ? Value(bookmark.hnUrl)
                    : const Value.absent(),
          ),
          old.id,
        );
        return old.id;
      }
    }
    return _db.insertBookmark(
      BookmarksTableCompanion.insert(
        type: bookmark.type.name,
        title: Value(bookmark.title),
        contentText: Value(bookmark.contentText),
        contentUrl: Value(bookmark.contentUrl),
        hnUrl: Value(bookmark.hnUrl),
        hnItemId: Value(bookmark.hnItemId),
        author: Value(bookmark.author),
        summary: Value(bookmark.summary),
        domain: Value(bookmark.domain),
        canonicalKey: Value(key),
      ),
    );
  });

  Future<void> updateDetails(
    int id, {
    String? title,
    String? url,
    String? text,
    String? note,
  }) async {
    if (title == null && url == null && text == null && note == null) return;
    await _db.updateBookmark(
      BookmarksTableCompanion(
        title: title == null ? const Value.absent() : Value(title),
        contentUrl: url == null ? const Value.absent() : Value(url),
        contentText: text == null ? const Value.absent() : Value(text),
        summary: note == null ? const Value.absent() : Value(note),
        canonicalKey:
            url == null ? const Value.absent() : Value(canonicalUrl(url)),
      ),
      id,
    );
  }

  /// Fill metadata without replacing the user's text or a published snapshot.
  /// Draft cards included before the request finished receive the same metadata.
  Future<void> enrich(
    int id, {
    required String? capturedUrl,
    String? title,
    String? excerpt,
    String? author,
    String? type,
    String? discussionUrl,
    String? sourceUrl,
  }) => _db.transaction(() async {
    final before = await get(id);
    if (before == null || before.contentUrl != capturedUrl) return;
    String fill(String? current, String? incoming) =>
        current?.isNotEmpty == true ? current! : incoming ?? current ?? '';
    final nextTitle = fill(before.title, title);
    final nextText = fill(before.contentText, excerpt);
    final nextAuthor = fill(before.author, author);
    final nextUrl = safeWebUrl(sourceUrl) ?? before.contentUrl ?? '';
    final nextDiscussion = safeWebUrl(discussionUrl) ?? before.hnUrl ?? '';
    await _db.updateBookmark(
      BookmarksTableCompanion(
        title: Value(nextTitle),
        contentText: Value(nextText),
        author: Value(nextAuthor),
        type: Value(type ?? before.type),
        contentUrl: Value(nextUrl),
        hnUrl: Value(nextDiscussion),
        canonicalKey: Value(canonicalUrl(nextUrl)),
      ),
      id,
    );
    final cards =
        await (_db.select(_db.roundupCards)
          ..where((t) => t.bookmarkId.equals(id))).get();
    final changedIssues = <String>{};
    for (final card in cards) {
      final issue =
          await (_db.select(_db.roundupIssues)
            ..where((t) => t.id.equals(card.issueId))).getSingle();
      if (issue.publishedAt != null) continue;
      final updated = card.copyWith(
        title: card.title == (before.title ?? '') ? nextTitle : card.title,
        excerpt:
            card.excerpt == (before.contentText ?? '')
                ? nextText
                : card.excerpt,
        author: card.author == (before.author ?? '') ? nextAuthor : card.author,
        type: card.type == before.type ? type ?? before.type : card.type,
        url:
            card.url == (before.contentUrl ?? before.hnUrl ?? '')
                ? nextUrl
                : card.url,
        discussionUrl:
            card.discussionUrl == (before.hnUrl ?? '')
                ? nextDiscussion
                : card.discussionUrl,
      );
      if (updated == card) continue;
      await _db.update(_db.roundupCards).replace(updated);
      changedIssues.add(card.issueId);
    }
    for (final issueId in changedIssues) {
      await _db.customUpdate(
        'UPDATE roundup_issues SET revision = revision + 1 WHERE id = ?',
        variables: [Variable(issueId)],
        updates: {_db.roundupIssues},
      );
    }
  });

  Future<bool> updateSummary(int id, String summary) {
    return _db.updateBookmark(
      BookmarksTableCompanion(summary: Value(summary)),
      id,
    );
  }

  Future<int> deleteBookmark(int id) => _db.deleteBookmark(id);

  Future<int> deleteByHnItemId(int hnItemId) => _db.deleteByHnItemId(hnItemId);

  Future<void> markAsPublished(List<int> ids, String weekLabel) {
    return _db.markAsPublished(ids, weekLabel);
  }

  Future<int> clearAll() => _db.clearAllBookmarks();
}
