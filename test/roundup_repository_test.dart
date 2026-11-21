import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/core/utils/markdown_generator.dart';
import 'package:glean/core/utils/week_utils.dart';
import 'package:glean/data/database/app_database.dart';
import 'package:glean/data/models/bookmark.dart';
import 'package:glean/data/repositories/bookmark_repository.dart';
import 'package:glean/data/repositories/roundup_repository.dart';
import 'package:glean/data/repositories/backup_repository.dart';
import 'package:glean/features/exports/export_jobs.dart';
import 'package:glean/data/api/comment_export_service.dart';
import 'dart:convert';

void main() {
  late AppDatabase db;
  late BookmarkRepository saved;
  late RoundupRepository issues;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    saved = BookmarkRepository(db);
    issues = RoundupRepository(db);
  });
  tearDown(() => db.close());
  test(
    'mixed order, private notes, and snapshots survive library edits',
    () async {
      final issue = await issues.ensureWeek(DateTime(2026, 11, 14));
      final ids = <int>[];
      for (final type in [
        BookmarkType.hnArticle,
        BookmarkType.hnComment,
        BookmarkType.website,
      ]) {
        ids.add(
          await saved.addBookmark(
            Bookmark(
              type: type,
              title: type.name,
              contentUrl: 'https://example.com/${type.name}',
              hnItemId: type == BookmarkType.hnComment ? 2 : null,
              contentText: 'A source excerpt',
              summary: 'PRIVATE NOTE',
            ),
          ),
        );
      }
      for (final id in ids) {
        await issues.include(issue.id, (await saved.get(id))!);
      }
      await issues.include(issue.id, (await saved.get(ids.first))!);
      var cards = await issues.cards(issue.id);
      expect(cards.length, 3);
      expect(cards.every((c) => c.blurb.isEmpty), isTrue);
      await issues.editCard(cards.first.copyWith(blurb: 'My public angle'));
      await issues.reorder(issue.id, [cards[2].id, cards[0].id, cards[1].id]);
      await saved.updateSummary(ids.first, 'NEW PRIVATE NOTE');
      await saved.deleteBookmark(ids.first);
      cards = await issues.cards(issue.id);
      final markdown = MarkdownGenerator.document(
        await issues.getIssue(issue.id),
        cards,
      );
      expect(cards.map((c) => c.type), ['website', 'hnArticle', 'hnComment']);
      expect(markdown, contains('My public angle'));
      expect(markdown, isNot(contains('PRIVATE NOTE')));
      expect(markdown, isNot(contains('## Articles')));
      expect(
        markdown.indexOf('website'),
        lessThan(markdown.indexOf('hnArticle')),
      );
      expect(markdown, contains('> A source excerpt'));
      expect(markdown, contains('permalink: /roundup/2026-W46/'));
      final fixture = Platform.environment['GLEAN_SITE_FIXTURE'];
      if (fixture != null) await File(fixture).writeAsString(markdown);
    },
  );
  test(
    'metadata fills early draft cards without replacing edits or published cards',
    () async {
      final issue = await issues.ensureWeek(DateTime(2026, 11, 14));
      final id = await saved.addBookmark(
        Bookmark(
          type: BookmarkType.website,
          contentUrl: 'https://news.ycombinator.com/item?id=42',
          hnItemId: 42,
          summary: 'Private',
        ),
      );
      await issues.include(issue.id, (await saved.get(id))!);
      var card = (await issues.cards(issue.id)).single;
      await issues.editCard(
        card.copyWith(title: 'My edited heading', blurb: 'My public angle'),
      );
      await saved.enrich(
        id,
        capturedUrl: 'https://news.ycombinator.com/item?id=42',
        title: 'Fetched title',
        excerpt: 'Fetched excerpt',
        type: 'hnArticle',
        sourceUrl: 'https://example.com/story',
        discussionUrl: 'https://news.ycombinator.com/item?id=42',
      );
      card = (await issues.cards(issue.id)).single;
      expect(card.title, 'My edited heading');
      expect(card.excerpt, 'Fetched excerpt');
      expect(card.url, 'https://example.com/story');
      expect(card.blurb, 'My public angle');
      expect(card.type, 'hnArticle');
      expect((await saved.get(id))!.summary, 'Private');
      final snap = await issues.snapshot(issue.id);
      await issues.recordPublication(snap.issue, snap.cards, 'published-sha');
      await saved.enrich(
        id,
        capturedUrl: 'https://example.com/story',
        author: 'New author',
      );
      expect((await issues.cards(issue.id)).single.author, isEmpty);
      expect((await saved.get(id))!.author, 'New author');
    },
  );
  test(
    'canonical duplicate capture restores an archived item and preserves its note',
    () async {
      final id = await saved.addBookmark(
        Bookmark(
          type: BookmarkType.website,
          contentUrl: 'https://www.example.com/article?utm_source=hn',
          summary: 'Keep me',
        ),
      );
      await saved.archive(id, true);
      final again = await saved.addBookmark(
        Bookmark(
          type: BookmarkType.hnArticle,
          contentUrl: 'https://example.com/article',
          hnItemId: 42,
          hnUrl: 'https://news.ycombinator.com/item?id=42',
        ),
      );
      expect(again, id);
      final item = (await saved.get(id))!;
      expect(item.summary, 'Keep me');
      expect(item.archived, isFalse);
      expect(item.hnItemId, 42);
    },
  );
  test(
    'atomic backup round trip preserves draft order and publication revision',
    () async {
      final issue = await issues.ensureWeek(DateTime(2026, 11, 14));
      final id = await saved.addBookmark(
        Bookmark(
          type: BookmarkType.website,
          contentUrl: 'https://example.com',
          summary: 'Private',
        ),
      );
      await issues.include(issue.id, (await saved.get(id))!);
      await issues.bindDestination(
        issue.id,
        repo: 'owner/site',
        path: '_roundup/${issue.id}.md',
        branch: 'main',
        publicUrl: 'https://example.com/roundup/${issue.id}/',
      );
      final snap = await issues.getIssue(issue.id);
      await issues.recordPublication(snap, await issues.cards(issue.id), 'abc');
      final backups = BackupRepository(db);
      final json = await backups.export();
      final restored = backups.validate(json);
      await saved.clearAll();
      await backups.restore(restored);
      expect((await saved.get(id))!.summary, 'Private');
      expect((await issues.getIssue(issue.id)).remoteSha, 'abc');
      expect((await issues.cards(issue.id)).length, 1);
      expect(json, isNot(contains('access_token')));
      expect(
        () => backups.validate('{"format":"glean-backup","version":9}'),
        throwsFormatException,
      );
    },
  );
  test(
    'content cannot inject HTML, YAML frontmatter, or Liquid tags',
    () async {
      final issue = (await issues.ensureWeek()).copyWith(
        title: 'Title: "quoted"\nlayout: unsafe',
        introduction: '{% include secret %}<script>alert(1)</script>',
      );
      final md = MarkdownGenerator.document(issue, []);
      expect(md, contains('&#123;% include secret %&#125;'));
      expect(md, isNot(contains('<script>')));
      expect(md, contains('\\nlayout: unsafe'));
    },
  );
  test(
    'export jobs retry failures, persist complete JSON, and skip deleted work',
    () async {
      final jobs = ExportJobs(db);
      final id = await jobs.enqueue(42, 'Discussion', 3, 10);
      final failed = CommentExportService(
        fetch: (_) async => throw StateError('offline'),
      );
      expect(await jobs.perform(id, service: failed), isFalse);
      expect((await jobs.list()).single.status, 'retrying');
      final available = CommentExportService(
        fetch:
            (id) async =>
                id == 42
                    ? {
                      'id': 42,
                      'title': 'Discussion',
                      'kids': [43],
                    }
                    : {'id': 43, 'parent': 42, 'text': 'An interesting angle'},
      );
      expect(await jobs.perform(id, service: available), isTrue);
      final ready = (await jobs.list()).single;
      expect(ready.status, 'ready');
      expect(
        jsonDecode(ready.jsonContent!)['comments'][0]['text'],
        'An interesting angle',
      );
      expect(await jobs.perform(id, service: failed), isTrue);
      final backups = BackupRepository(db);
      backups.validate(await backups.export());
      await jobs.delete(id);
      expect(await jobs.perform(id, service: failed), isTrue);
      expect(await jobs.list(), isEmpty);
    },
  );
  test('ISO week boundaries and daylight saving safe date math', () {
    expect(WeekUtils.weekLabel(DateTime(2026, 11, 14)), '2026-W46');
    expect(WeekUtils.weekLabel(DateTime(2026, 1, 5)), '2026-W02');
    expect(WeekUtils.weekLabel(DateTime(2026, 12, 31)), '2026-W53');
    expect(WeekUtils.weekLabel(DateTime(2021, 1, 1)), '2020-W53');
    expect(WeekUtils.weekLabel(DateTime(2019, 12, 30)), '2020-W01');
  });
  test('v1 migration keeps bookmarks, notes and published history', () async {
    await db.close();
    final legacy = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (sql) {
          sql.execute(
            'CREATE TABLE bookmarks_table (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, title TEXT, content_text TEXT, content_url TEXT, hn_url TEXT, hn_item_id INTEGER, author TEXT, summary TEXT, domain TEXT, is_published INTEGER NOT NULL DEFAULT 0, published_week TEXT, created_at INTEGER NOT NULL DEFAULT 0)',
          );
          sql.execute(
            "INSERT INTO bookmarks_table(type, summary, is_published, published_week) VALUES ('website', 'Existing note', 1, '202645')",
          );
          sql.execute('PRAGMA user_version = 1');
        },
      ),
    );
    try {
      final existing = await legacy.getAllBookmarks();
      expect(existing.single.summary, 'Existing note');
      expect(existing.single.publishedWeek, '202645');
      expect(existing.single.archived, isTrue);
      final draft = await RoundupRepository(legacy).ensureWeek();
      expect(draft.publishedAt, isNull);
    } finally {
      await legacy.close();
    }
  });
  test(
    'only successfully published snapshot saves are archived; notes and drafts survive',
    () async {
      final issue = await issues.ensureWeek();
      final ids = <int>[];
      for (var i = 0; i < 3; i++) {
        ids.add(
          await saved.addBookmark(
            Bookmark(
              type: BookmarkType.website,
              title: 'Item $i',
              contentUrl: 'https://example.com/$i',
              summary: 'Private note $i',
            ),
          ),
        );
      }
      for (final id in ids.take(2)) {
        await issues.include(issue.id, (await saved.get(id))!);
      }
      final snapshot = await issues.snapshot(issue.id);
      // A failed upload never calls recordPublication and leaves all saves active.
      expect(
        (await saved.getAll()).every((b) => !b.archived && !b.isPublished),
        true,
      );
      await issues.include(issue.id, (await saved.get(ids.last))!);
      await issues.recordPublication(
        snapshot.issue,
        snapshot.cards,
        'uploaded',
      );
      for (final id in ids.take(2)) {
        final b = (await saved.get(id))!;
        expect(b.archived, true);
        expect(b.isPublished, true);
        expect(b.publishedWeek, issue.id);
        expect(b.summary, startsWith('Private note'));
      }
      expect((await saved.get(ids.last))!.archived, false);
      expect((await saved.get(ids.last))!.isPublished, false);
      expect((await issues.cards(issue.id)).length, 3);
      expect(
        (await issues.getIssue(issue.id)).publishedRevision,
        snapshot.issue.revision,
      );
      await issues.recordPublication(
        snapshot.issue,
        snapshot.cards,
        'uploaded',
      );
      await saved.archive(ids.first, false);
      expect((await saved.get(ids.first))!.archived, false);
      expect((await saved.get(ids.first))!.isPublished, true);
    },
  );
  test(
    'v3 upgrade archives old published saves without changing notes or roundups',
    () async {
      final temp = await Directory.systemTemp.createTemp('glean-v3-upgrade');
      addTearDown(() => temp.delete(recursive: true));
      await db.close();
      db = AppDatabase.forTesting(
        NativeDatabase(File('${temp.path}/library.db')),
      );
      final oldSaved = BookmarkRepository(db),
          oldIssues = RoundupRepository(db);
      final issue = await oldIssues.ensureWeek();
      final published = await oldSaved.addBookmark(
        Bookmark(
          type: BookmarkType.website,
          contentUrl: 'https://example.com/published',
          summary: 'Keep this note',
        ),
      );
      final pending = await oldSaved.addBookmark(
        Bookmark(
          type: BookmarkType.website,
          contentUrl: 'https://example.com/pending',
        ),
      );
      await oldIssues.include(issue.id, (await oldSaved.get(published))!);
      final snap = await oldIssues.snapshot(issue.id);
      await oldIssues.recordPublication(snap.issue, snap.cards, 'remote-sha');
      await oldSaved.archive(
        published,
        false,
      ); // v1.2.0 left published saves here.
      await db.customStatement('PRAGMA user_version = 3');
      await db.close();
      db = AppDatabase.forTesting(
        NativeDatabase(File('${temp.path}/library.db')),
      );
      final upgraded = BookmarkRepository(db);
      expect((await upgraded.get(published))!.archived, true);
      expect((await upgraded.get(published))!.summary, 'Keep this note');
      expect((await upgraded.get(pending))!.archived, false);
      expect(
        (await RoundupRepository(db).getIssue(issue.id)).remoteSha,
        'remote-sha',
      );
      expect(
        (await RoundupRepository(db).cards(issue.id)).single.bookmarkId,
        published,
      );
    },
  );
}
