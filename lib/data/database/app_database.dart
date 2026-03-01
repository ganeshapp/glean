import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class BookmarksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get title => text().nullable()();
  TextColumn get contentText => text().nullable()();
  TextColumn get contentUrl => text().nullable()();
  TextColumn get hnUrl => text().nullable()();
  IntColumn get hnItemId => integer().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get domain => text().nullable()();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  TextColumn get publishedWeek => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [BookmarksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Bookmarks DAO methods

  Future<List<BookmarksTableData>> getAllBookmarks() {
    return (select(bookmarksTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<BookmarksTableData>> getUnpublishedBookmarks() {
    return (select(bookmarksTable)
          ..where((t) => t.isPublished.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<BookmarksTableData>> getBookmarksByType(String type) {
    return (select(bookmarksTable)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<int> insertBookmark(BookmarksTableCompanion entry) {
    return into(bookmarksTable).insert(entry);
  }

  Future<bool> updateBookmark(BookmarksTableCompanion entry, int id) {
    return (update(bookmarksTable)..where((t) => t.id.equals(id)))
        .write(entry)
        .then((rows) => rows > 0);
  }

  Future<int> deleteBookmark(int id) {
    return (delete(bookmarksTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markAsPublished(List<int> ids, String weekLabel) {
    return (update(bookmarksTable)..where((t) => t.id.isIn(ids))).write(
      BookmarksTableCompanion(
        isPublished: const Value(true),
        publishedWeek: Value(weekLabel),
      ),
    );
  }

  Future<int> clearAllBookmarks() {
    return delete(bookmarksTable).go();
  }

  Stream<List<BookmarksTableData>> watchAllBookmarks() {
    return (select(bookmarksTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<BookmarksTableData>> watchUnpublishedBookmarks() {
    return (select(bookmarksTable)
          ..where((t) => t.isPublished.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'glean.db'));
    return NativeDatabase.createInBackground(file);
  });
}
