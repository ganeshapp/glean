import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/core/utils/markdown_generator.dart';
import 'package:glean/core/utils/photo_paths.dart';
import 'package:glean/core/utils/youtube_video.dart';
import 'package:glean/data/database/app_database.dart';
import 'package:glean/data/repositories/backup_repository.dart';
import 'package:glean/data/repositories/roundup_repository.dart';
import 'package:glean/features/photos/photo_import_service.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Gallery extends ImagePicker {
  final List<XFile> files;
  Gallery(this.files);
  @override
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async => files;
}

Uint8List photoInput([int red = 80]) {
  final image = img.Image(width: 40, height: 30);
  img.fill(image, color: img.ColorRgb8(red, 120, 180));
  image.exif.imageIfd.imageDescription = 'Private camera metadata';
  return Uint8List.fromList(img.encodeJpg(image));
}

RoundupPhoto fixturePhoto([int red = 80]) {
  final n = normalizePhoto(photoInput(red));
  return RoundupPhoto(
    id: n.id,
    bytes: n.bytes,
    width: n.width,
    height: n.height,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late RoundupRepository repo;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = RoundupRepository(db);
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() => db.close());
  test(
    'photos survive reorder, backup and removal without losing shared assets',
    () async {
      final issue = await repo.ensureWeek(DateTime(2026, 11, 14));
      final one = fixturePhoto(), two = fixturePhoto(200);
      await repo.addPhoto(issue.id, one);
      await db
          .into(db.roundupCards)
          .insert(
            RoundupCardsCompanion.insert(
              issueId: issue.id,
              position: 1,
              type: 'website',
              title: const Value('Article'),
              url: const Value('https://example.com'),
            ),
          );
      await repo.addPhoto(issue.id, two);
      expect(await repo.addPhoto(issue.id, one), false);
      var cards = await repo.cards(issue.id);
      await repo.editCard(
        cards.last.copyWith(title: 'A caption', blurb: 'Why this matters'),
      );
      await repo.reorder(issue.id, [
        cards.last.id,
        cards[1].id,
        cards.first.id,
      ]);
      final backup = BackupRepository(db);
      final data = backup.validate(await backup.export());
      await backup.restore(data);
      cards = await repo.cards(issue.id);
      expect(cards.map((c) => c.type), ['photo', 'website', 'photo']);
      expect(cards.first.title, 'A caption');
      expect(cards.first.blurb, 'Why this matters');
      expect((await repo.snapshot(issue.id)).photos.map((p) => p.id).toSet(), {
        one.id,
        two.id,
      });
      final other = await repo.ensureWeek(DateTime(2026, 11, 21));
      await repo.addPhoto(other.id, one);
      await repo.removeCard(cards.last);
      expect((await repo.snapshot(other.id)).photos.single.bytes, one.bytes);
      await repo.removeCard((await repo.cards(other.id)).single);
      expect(await repo.watchPhoto(one.id).first, isNull);
      final corrupted =
          jsonDecode(await backup.export()) as Map<String, dynamic>;
      corrupted['photos'][0]['bytes'] = base64Encode([1, 2, 3]);
      expect(
        () => backup.validate(jsonEncode(corrupted)),
        throwsFormatException,
      );
    },
  );
  test(
    'gallery imports multiple independent cards, persists copies and recovers idempotently',
    () async {
      final temp = await Directory.systemTemp.createTemp('glean-photos');
      addTearDown(() => temp.delete(recursive: true));
      final a = File('${temp.path}/a.jpg')..writeAsBytesSync(photoInput());
      final b = File('${temp.path}/b.jpg')..writeAsBytesSync(photoInput(200));
      final invalid = File('${temp.path}/bad.jpg')
        ..writeAsStringSync('not an image');
      final issue = await repo.ensureWeek();
      final service = PhotoImportService(
        db,
        picker: Gallery([XFile(a.path), XFile(b.path), XFile(invalid.path)]),
      );
      final result = await service.pick(issue.id);
      expect(result!.added, 2);
      expect(result.failed, 1);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        PhotoImportService.pendingKey,
        jsonEncode({
          'issueId': issue.id,
          'paths': [a.path, b.path],
        }),
      );
      final recovered = await PhotoImportService(db).recover();
      expect(recovered!.existing, 2);
      expect((await repo.cards(issue.id)).length, 2);
      await a.delete();
      await b.delete();
      expect((await repo.snapshot(issue.id)).photos.length, 2);
      expect(prefs.containsKey(PhotoImportService.pendingKey), false);
      expect(
        await PhotoImportService(db, picker: Gallery([])).pick(issue.id),
        isNull,
      );
    },
  );
  test('normalization strips source metadata, orients and bounds images', () {
    final source = img.Image(width: 3000, height: 30);
    source.exif.imageIfd.orientation = 6;
    source.exif.imageIfd.imageDescription = 'Private';
    final output = normalizePhoto(Uint8List.fromList(img.encodeJpg(source)));
    expect(output.width, 24);
    expect(output.height, 2400);
    expect(img.decodeJpg(output.bytes)!.exif.imageIfd.imageDescription, isNull);
    expect(normalizePhoto(photoInput()).id, fixturePhoto().id);
    expect(
      () => normalizePhoto(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });
  test(
    'photo and video Markdown preserves order, public paths, escaping and links',
    () async {
      final issue = (await repo.ensureWeek(DateTime(2026, 11, 14))).copyWith(
        filePath: const Value('_roundup/2026-W46.md'),
        publicUrl: const Value('https://www.gapp.in/roundup/2026-W46/'),
      );
      final photo = fixturePhoto();
      await repo.addPhoto(issue.id, photo);
      final card = (await repo.cards(issue.id)).single.copyWith(
        title: 'Photo <script> & caption',
        blurb: 'See https://example.com/more.',
      );
      final video = card.copyWith(
        id: 42,
        type: 'youtube',
        photoId: const Value(null),
        title: 'Watch this',
        url: 'https://youtu.be/dQw4w9WgXcQ?t=1m2s',
        blurb: '',
      );
      final md = MarkdownGenerator.document(issue, [card, video]);
      expect(
        md,
        contains('https://www.gapp.in/roundup/assets/${photo.id}.jpg'),
      );
      expect(
        md,
        contains(
          '<iframe src="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?start=62"',
        ),
      );
      expect(md, isNot(contains('<script>')));
      expect(
        md,
        contains('[https://example.com/more](<https://example.com/more>)'),
      );
      expect(md.indexOf('.jpg'), lessThan(md.indexOf('<iframe')));
      expect(
        MarkdownGenerator.body(issue, [card], forPreview: true),
        contains('glean-photo:${photo.id}'),
      );
      expect(
        PhotoPaths.publicUrl(
          issue.copyWith(
            publicUrl: const Value(
              'https://owner.github.io/project/roundup/2026-W46/',
            ),
          ),
          photo.id,
        ),
        'https://owner.github.io/project/roundup/assets/${photo.id}.jpg',
      );
      final fixture = Platform.environment['GLEAN_MEDIA_FIXTURE'];
      if (fixture != null) {
        await Directory('$fixture/_roundup/assets').create(recursive: true);
        await File('$fixture/_roundup/2026-W46.md').writeAsString(md);
        await File(
          '$fixture/_roundup/assets/${photo.id}.jpg',
        ).writeAsBytes(photo.bytes);
      }
    },
  );
  test(
    'YouTube formats are recognized without embedding hostile hosts or IDs',
    () {
      for (final url in [
        'https://youtube.com/watch?v=dQw4w9WgXcQ',
        'https://m.youtube.com/shorts/dQw4w9WgXcQ',
        'https://www.youtube.com/live/dQw4w9WgXcQ',
        'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
      ]) {
        expect(YouTubeVideo.parse(url)!.id, 'dQw4w9WgXcQ');
      }
      for (final url in [
        'https://youtube.com.evil.com/watch?v=dQw4w9WgXcQ',
        'https://youtu.be/%22%3E%3Cscript%3E',
        'javascript:alert(1)',
        'https://example.com/video',
      ]) {
        expect(YouTubeVideo.parse(url), isNull);
      }
      expect(
        MarkdownGenerator.paragraph('Try (https://example.com/a_(b)).'),
        'Try ([https://example.com/a\\_(b)](<https://example.com/a_(b)>)).',
      );
    },
  );
  test('v2 database upgrades in place and v1 backups still restore', () async {
    final dir = await Directory.systemTemp.createTemp('glean-v2');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/library.db');
    final old = AppDatabase.forTesting(NativeDatabase(file));
    final issue = await RoundupRepository(old).ensureWeek();
    await old.customStatement('ALTER TABLE roundup_cards DROP COLUMN photo_id');
    await old.customStatement('DROP TABLE roundup_photos');
    await old.customStatement('PRAGMA user_version = 2');
    await old.close();
    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    try {
      final repo = RoundupRepository(upgraded);
      expect((await repo.getIssue(issue.id)).title, issue.title);
      await repo.addPhoto(issue.id, fixturePhoto());
      expect((await repo.snapshot(issue.id)).photos.length, 1);
    } finally {
      await upgraded.close();
    }
    final legacy = jsonDecode(await BackupRepository(db).export()) as Map;
    legacy['version'] = 1;
    legacy.remove('photos');
    await BackupRepository(
      db,
    ).restore(BackupRepository(db).validate(jsonEncode(legacy)));
  });
}
