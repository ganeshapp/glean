import 'dart:convert';
import '../database/app_database.dart';

class BackupRepository {
  final AppDatabase db;
  BackupRepository(this.db);
  Future<String> export() => db.transaction(
    () async => const JsonEncoder.withIndent('  ').convert({
      'format': 'glean-backup',
      'version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'bookmarks':
          (await db.select(db.bookmarksTable).get())
              .map((b) => b.toJson())
              .toList(),
      'issues':
          (await db.select(db.roundupIssues).get())
              .map((i) => i.toJson())
              .toList(),
      'cards':
          (await db.select(db.roundupCards).get())
              .map((c) => c.toJson())
              .toList(),
      'exports':
          (await db.select(db.commentExports).get())
              .where((e) => e.status == 'ready')
              .map((e) => e.toJson())
              .toList(),
    }),
  );

  BackupData validate(String raw) {
    if (raw.length > 50 * 1024 * 1024) {
      throw const FormatException('Backup is too large.');
    }
    final json = jsonDecode(raw);
    if (json is! Map ||
        json['format'] != 'glean-backup' ||
        json['version'] != 1) {
      throw const FormatException('This is not a supported Glean backup.');
    }
    List<T> read<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List)
            .map((row) => parse(Map<String, dynamic>.from(row as Map)))
            .toList();
    final data = BackupData(
      read('bookmarks', BookmarksTableData.fromJson),
      read('issues', RoundupIssue.fromJson),
      read('cards', RoundupCard.fromJson),
      read('exports', CommentExport.fromJson),
    );
    final issueIds = data.issues.map((i) => i.id).toSet();
    if (issueIds.length != data.issues.length ||
        data.bookmarks.map((b) => b.id).toSet().length !=
            data.bookmarks.length ||
        data.cards.map((c) => c.id).toSet().length != data.cards.length ||
        data.exports.map((e) => e.id).toSet().length != data.exports.length) {
      throw const FormatException('Backup contains duplicate records.');
    }
    if (data.bookmarks.any((b) => b.id <= 0) ||
        data.cards.any(
          (c) => c.id <= 0 || !issueIds.contains(c.issueId) || c.position < 0,
        )) {
      throw const FormatException('Backup contains invalid references.');
    }
    for (final issue in data.issues) {
      if (!RegExp(r'^\d{4}-W\d{2}$').hasMatch(issue.id) ||
          issue.revision < 0 ||
          issue.filePath?.split('/').any((p) => p == '..' || p == '.') ==
              true) {
        throw const FormatException('Backup contains an invalid issue.');
      }
    }
    for (final export in data.exports) {
      if (!RegExp(r'^\d+-\d+$').hasMatch(export.id) ||
          export.storyId <= 0 ||
          ![2, 3].contains(export.depth) ||
          ![10, 30, 50].contains(export.rootLimit) ||
          export.status != 'ready' ||
          export.jsonContent == null) {
        throw const FormatException(
          'Backup contains an invalid comment export.',
        );
      }
      final content = jsonDecode(export.jsonContent!);
      if (content is! Map ||
          content['schema_version'] != 1 ||
          content['selection'] is! Map ||
          content['comments'] is! List) {
        throw const FormatException(
          'Backup contains an invalid comment export.',
        );
      }
    }
    return data;
  }

  Future<void> restore(BackupData data) => db.transaction(() async {
    await db.delete(db.roundupCards).go();
    await db.delete(db.roundupIssues).go();
    await db.delete(db.bookmarksTable).go();
    await db.delete(db.commentExports).go();
    for (final b in data.bookmarks) {
      await db.into(db.bookmarksTable).insert(b);
    }
    for (final i in data.issues) {
      await db.into(db.roundupIssues).insert(i);
    }
    for (final c in data.cards) {
      await db.into(db.roundupCards).insert(c);
    }
    for (final e in data.exports) {
      await db.into(db.commentExports).insert(e);
    }
  });
}

class BackupData {
  final List<BookmarksTableData> bookmarks;
  final List<RoundupIssue> issues;
  final List<RoundupCard> cards;
  final List<CommentExport> exports;
  const BackupData(this.bookmarks, this.issues, this.cards, this.exports);
}
