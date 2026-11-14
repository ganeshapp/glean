import 'package:drift/drift.dart';
import '../../core/utils/week_utils.dart';
import '../database/app_database.dart';

class RoundupRepository {
  final AppDatabase db;
  RoundupRepository(this.db);

  Future<RoundupIssue> ensureWeek([DateTime? date]) async {
    final now = date ?? DateTime.now();
    final id = WeekUtils.weekLabel(now);
    await db
        .into(db.roundupIssues)
        .insert(
          RoundupIssuesCompanion.insert(
            id: id,
            title: 'Roundup · ${WeekUtils.weekDateRange(now)}',
            date: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return getIssue(id);
  }

  Future<RoundupIssue> getIssue(String id) =>
      (db.select(db.roundupIssues)..where((t) => t.id.equals(id))).getSingle();
  Future<({RoundupIssue issue, List<RoundupCard> cards})> snapshot(String id) =>
      db.transaction(
        () async => (issue: await getIssue(id), cards: await cards(id)),
      );
  Stream<RoundupIssue> watchIssue(String id) =>
      (db.select(db.roundupIssues)
        ..where((t) => t.id.equals(id))).watchSingle();
  Stream<List<RoundupIssue>> watchIssues() =>
      (db.select(db.roundupIssues)
        ..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  Future<List<RoundupCard>> cards(String id) =>
      (db.select(db.roundupCards)
            ..where((t) => t.issueId.equals(id))
            ..orderBy([
              (t) => OrderingTerm.asc(t.position),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();
  Stream<List<RoundupCard>> watchCards(String id) =>
      (db.select(db.roundupCards)
            ..where((t) => t.issueId.equals(id))
            ..orderBy([
              (t) => OrderingTerm.asc(t.position),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .watch();

  Future<void> _touch(String id) => db.customUpdate(
    'UPDATE roundup_issues SET revision = revision + 1 WHERE id = ?',
    variables: [Variable(id)],
    updates: {db.roundupIssues},
  );

  Future<void> editIssue(String id, String title, String introduction) =>
      db.transaction(() async {
        await (db.update(db.roundupIssues)
          ..where((t) => t.id.equals(id))).write(
          RoundupIssuesCompanion(
            title: Value(title.trim()),
            introduction: Value(introduction.trim()),
          ),
        );
        await _touch(id);
      });

  Future<int> include(
    String issueId,
    BookmarksTableData bookmark,
  ) => db.transaction(() async {
    final existing =
        await (db.select(db.roundupCards)..where(
          (t) => t.issueId.equals(issueId) & t.bookmarkId.equals(bookmark.id),
        )).getSingleOrNull();
    if (existing != null) return existing.id;
    final list = await cards(issueId);
    final id = await db
        .into(db.roundupCards)
        .insert(
          RoundupCardsCompanion.insert(
            issueId: issueId,
            bookmarkId: Value(bookmark.id),
            position: list.length,
            type: bookmark.type,
            title: Value(bookmark.title ?? ''),
            url: Value(bookmark.contentUrl ?? bookmark.hnUrl ?? ''),
            discussionUrl: Value(bookmark.hnUrl ?? ''),
            excerpt: Value(bookmark.contentText ?? ''),
            author: Value(bookmark.author ?? ''),
            // Personal notes never become public without an explicit editor action.
          ),
        );
    await _touch(issueId);
    return id;
  });

  Future<void> editCard(RoundupCard card, {RoundupCard? previous}) =>
      db.transaction(() async {
        if (previous == card) return;
        if (previous == null) {
          await db.update(db.roundupCards).replace(card);
        } else {
          // Only write the fields edited on screen. Metadata may have arrived
          // while the editor was open, so its untouched fields can be newer.
          Value<String> edited(String before, String after) =>
              before == after ? const Value.absent() : Value(after);
          await (db.update(db.roundupCards)
            ..where((t) => t.id.equals(card.id))).write(
            RoundupCardsCompanion(
              title: edited(previous.title, card.title),
              url: edited(previous.url, card.url),
              excerpt: edited(previous.excerpt, card.excerpt),
              author: edited(previous.author, card.author),
              blurb: edited(previous.blurb, card.blurb),
              type: edited(previous.type, card.type),
              discussionUrl: edited(previous.discussionUrl, card.discussionUrl),
            ),
          );
        }
        await _touch(card.issueId);
      });

  Future<void> removeCard(RoundupCard card) => db.transaction(() async {
    await (db.delete(db.roundupCards)..where((t) => t.id.equals(card.id))).go();
    final remaining = await cards(card.issueId);
    for (var i = 0; i < remaining.length; i++) {
      await (db.update(db.roundupCards)..where(
        (t) => t.id.equals(remaining[i].id),
      )).write(RoundupCardsCompanion(position: Value(i)));
    }
    await _touch(card.issueId);
  });

  Future<void> reorder(String issueId, List<int> orderedIds) =>
      db.transaction(() async {
        final current = await cards(issueId);
        if (orderedIds.length != current.length ||
            orderedIds.toSet().length != current.length ||
            !current.every((c) => orderedIds.contains(c.id))) {
          throw StateError('The draft changed. Please try reordering again.');
        }
        for (var i = 0; i < orderedIds.length; i++) {
          await (db.update(db.roundupCards)..where(
            (t) => t.id.equals(orderedIds[i]),
          )).write(RoundupCardsCompanion(position: Value(i)));
        }
        await _touch(issueId);
      });

  Future<void> bindDestination(
    String id, {
    required String repo,
    required String path,
    required String branch,
    required String publicUrl,
  }) async {
    await (db.update(db.roundupIssues)
      ..where((t) => t.id.equals(id) & t.remoteSha.isNull())).write(
      RoundupIssuesCompanion(
        repository: Value(repo),
        filePath: Value(path),
        branch: Value(branch),
        publicUrl: Value(publicUrl),
      ),
    );
  }

  Future<void> recordPublication(
    RoundupIssue snapshot,
    List<RoundupCard> entries,
    String sha,
  ) => db.transaction(() async {
    await (db.update(db.roundupIssues)
      ..where((t) => t.id.equals(snapshot.id))).write(
      RoundupIssuesCompanion(
        remoteSha: Value(sha),
        publishedAt: Value(DateTime.now()),
        publishedRevision: Value(snapshot.revision),
      ),
    );
    await db.markAsPublished(
      entries.map((c) => c.bookmarkId).whereType<int>().toList(),
      snapshot.id,
    );
  });
}
