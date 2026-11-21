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
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get canonicalKey => text().nullable()();
}

@DataClassName('RoundupIssue')
class RoundupIssues extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get introduction => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  IntColumn get publishedRevision => integer().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get repository => text().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get branch => text().nullable()();
  TextColumn get remoteSha => text().nullable()();
  TextColumn get publicUrl => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoundupCard')
class RoundupCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get issueId => text().references(RoundupIssues, #id)();
  IntColumn get bookmarkId => integer().nullable()();
  IntColumn get position => integer()();
  TextColumn get type => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get discussionUrl => text().withDefault(const Constant(''))();
  TextColumn get excerpt => text().withDefault(const Constant(''))();
  TextColumn get author => text().withDefault(const Constant(''))();
  TextColumn get blurb => text().withDefault(const Constant(''))();
  TextColumn get photoId => text().nullable().references(RoundupPhotos, #id)();
}

@DataClassName('RoundupPhoto')
class RoundupPhotos extends Table {
  TextColumn get id => text()();
  BlobColumn get bytes => blob()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CommentExport')
class CommentExports extends Table {
  TextColumn get id => text()();
  IntColumn get storyId => integer()();
  TextColumn get title => text()();
  IntColumn get depth => integer().withDefault(const Constant(3))();
  IntColumn get rootLimit => integer().withDefault(const Constant(30))();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  TextColumn get error => text().nullable()();
  TextColumn get jsonContent => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    BookmarksTable,
    RoundupIssues,
    RoundupCards,
    CommentExports,
    RoundupPhotos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(bookmarksTable, bookmarksTable.archived);
        await m.addColumn(bookmarksTable, bookmarksTable.canonicalKey);
        await m.createTable(roundupIssues);
        await m.createTable(roundupCards);
        await m.createTable(commentExports);
      }
      if (from < 3) {
        await m.createTable(roundupPhotos);
        // A v1 upgrade creates the current cards table above, including photoId.
        if (from >= 2) await m.addColumn(roundupCards, roundupCards.photoId);
      }
      if (from < 4) {
        // Already-published saves move out of the inbox on upgrade, while
        // private notes and the editable roundup snapshots remain intact.
        await customStatement(
          'UPDATE bookmarks_table SET archived = 1 WHERE is_published = 1',
        );
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  // Bookmarks DAO methods

  Future<List<BookmarksTableData>> getAllBookmarks() {
    return (select(bookmarksTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
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
    return (update(bookmarksTable)
      ..where((t) => t.id.equals(id))).write(entry).then((rows) => rows > 0);
  }

  Future<int> deleteBookmark(int id) {
    return (delete(bookmarksTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markAsPublished(List<int> ids, String weekLabel) {
    return (update(bookmarksTable)..where((t) => t.id.isIn(ids))).write(
      BookmarksTableCompanion(
        isPublished: const Value(true),
        archived: const Value(true),
        publishedWeek: Value(weekLabel),
      ),
    );
  }

  Future<int> clearAllBookmarks() {
    return delete(bookmarksTable).go();
  }

  Future<bool> isBookmarked(int hnItemId) async {
    final result =
        await (select(bookmarksTable)
              ..where(
                (t) => t.hnItemId.equals(hnItemId) & t.archived.equals(false),
              )
              ..limit(1))
            .get();
    return result.isNotEmpty;
  }

  Future<int> deleteByHnItemId(int hnItemId) {
    return (delete(bookmarksTable)
      ..where((t) => t.hnItemId.equals(hnItemId))).go();
  }

  Stream<List<BookmarksTableData>> watchAllBookmarks() {
    return (select(bookmarksTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
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
