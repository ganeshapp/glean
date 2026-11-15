import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import '../../core/utils/photo_paths.dart';
import '../database/app_database.dart';

class BackupRepository {
  static const maxBytes = 200 * 1024 * 1024;
  final AppDatabase db;
  BackupRepository(this.db);
  Future<String> export() => db.transaction(
    () async => const JsonEncoder.withIndent('  ').convert({
      'format': 'glean-backup',
      'version': 2,
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
      'photos':
          (await db.select(db.roundupPhotos).get())
              .map(
                (p) => {
                  'id': p.id,
                  'bytes': base64Encode(p.bytes),
                  'width': p.width,
                  'height': p.height,
                },
              )
              .toList(),
      'exports':
          (await db.select(db.commentExports).get())
              .where((e) => e.status == 'ready')
              .map((e) => e.toJson())
              .toList(),
    }),
  );

  BackupData validate(String raw) {
    if (utf8.encode(raw).length > maxBytes) {
      throw const FormatException('Backup is too large.');
    }
    final json = jsonDecode(raw);
    if (json is! Map ||
        json['format'] != 'glean-backup' ||
        ![1, 2].contains(json['version'])) {
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
      json['version'] == 1
          ? []
          : read('photos', (p) {
            final bytes = base64Decode(p['bytes'] as String);
            final id = p['id'] as String;
            final width = p['width'] as int, height = p['height'] as int;
            if (!PhotoPaths.validId(id) ||
                bytes.length > 8 * 1024 * 1024 ||
                sha256.convert(bytes).toString() != id ||
                width <= 0 ||
                height <= 0 ||
                width > 2400 ||
                height > 2400) {
              throw const FormatException('Backup contains an invalid photo.');
            }
            final info = img.JpegDecoder().startDecode(bytes);
            if (info == null || info.width != width || info.height != height) {
              throw const FormatException('Backup contains an invalid photo.');
            }
            return RoundupPhoto(
              id: id,
              bytes: bytes,
              width: width,
              height: height,
            );
          }),
    );
    final photoIds = data.photos.map((p) => p.id).toSet();
    final issueIds = data.issues.map((i) => i.id).toSet();
    if (photoIds.length != data.photos.length ||
        issueIds.length != data.issues.length ||
        data.bookmarks.map((b) => b.id).toSet().length !=
            data.bookmarks.length ||
        data.cards.map((c) => c.id).toSet().length != data.cards.length ||
        data.exports.map((e) => e.id).toSet().length != data.exports.length) {
      throw const FormatException('Backup contains duplicate records.');
    }
    if (data.bookmarks.any((b) => b.id <= 0) ||
        data.cards.any(
          (c) =>
              c.id <= 0 ||
              !issueIds.contains(c.issueId) ||
              c.position < 0 ||
              (c.type == 'photo'
                  ? !photoIds.contains(c.photoId)
                  : c.photoId != null),
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
    await db.delete(db.roundupPhotos).go();
    await db.delete(db.roundupIssues).go();
    await db.delete(db.bookmarksTable).go();
    await db.delete(db.commentExports).go();
    for (final b in data.bookmarks) {
      await db.into(db.bookmarksTable).insert(b);
    }
    for (final i in data.issues) {
      await db.into(db.roundupIssues).insert(i);
    }
    for (final p in data.photos) {
      await db.into(db.roundupPhotos).insert(p);
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
  final List<RoundupPhoto> photos;
  const BackupData(
    this.bookmarks,
    this.issues,
    this.cards,
    this.exports, [
    this.photos = const [],
  ]);
}
