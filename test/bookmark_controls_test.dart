import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/core/theme/app_theme.dart';
import 'package:glean/data/api/hn_api_service.dart';
import 'package:glean/data/database/app_database.dart';
import 'package:glean/data/models/hn_comment.dart';
import 'package:glean/data/models/bookmark.dart';
import 'package:glean/data/models/hn_story.dart';
import 'package:glean/data/repositories/bookmark_repository.dart';
import 'package:glean/data/repositories/roundup_repository.dart';
import 'package:glean/features/bookmarks/bookmark_provider.dart';
import 'package:glean/features/comments/comments_screen.dart';
import 'package:glean/features/comments/widgets/comment_tile.dart';
import 'package:glean/features/comments/widgets/comment_actions_sheet.dart';
import 'package:glean/features/feed/feed_provider.dart';
import 'package:glean/features/feed/widgets/story_card.dart';

final story = HnStory(
  id: 100,
  title: 'An article',
  url: 'https://example.com/article',
  by: 'writer',
  time: 1794700000,
  kids: [101],
  descendants: 2,
);
final parent = HnComment(
  id: 101,
  text: 'Parent comment',
  by: 'reader',
  time: 1794700000,
  parent: 100,
  kids: [102],
);
final reply = HnComment(
  id: 102,
  text: 'A useful nested reply',
  by: 'other',
  time: 1794700000,
  parent: 101,
);

class DiscussionApi extends Fake implements HnApiService {
  @override
  Future<HnStory?> getStory(int id) async => story;
  @override
  Future<HnComment?> getComment(int id) async => id == 101 ? parent : reply;
}

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.getAllBookmarks();
  });
  tearDown(() => db.close());

  Future<void> mount(
    WidgetTester t,
    Widget screen, {
    Size size = const Size(360, 640),
    double textScale = 1,
  }) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          hnApiServiceProvider.overrideWithValue(DiscussionApi()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
          home: screen,
        ),
      ),
    );
    await settle(t);
  }

  Future<void> cleanup(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 10));
    await t.runAsync(() => db.close());
  }

  testWidgets(
    'feed bookmark toggles save and unsave, with undo preserving notes and draft cards',
    (t) async {
      try {
        final repo = BookmarkRepository(db);
        await t.runAsync(() async {
          final id = await repo.addBookmark(
            Bookmark(
              type: BookmarkType.hnArticle,
              hnItemId: story.id,
              contentUrl: story.url,
              summary: 'My private thought',
            ),
          );
          final issues = RoundupRepository(db);
          final issue = await issues.ensureWeek();
          await issues.include(issue.id, (await repo.get(id))!);
          await repo.archive(id, true);
        });
        await mount(t, Scaffold(body: StoryCard(story: story)));
        await t.tap(find.byIcon(Icons.bookmark_border));
        await settle(t);
        await t.tap(find.byIcon(Icons.bookmark));
        await settle(t);
        final removed = (await t.runAsync(repo.getAll))!.single;
        expect(removed.archived, isTrue);
        expect(removed.summary, 'My private thought');
        expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
        expect(await t.runAsync(() => repo.isBookmarked(story.id)), isFalse);
        expect(
          (await t.runAsync(() => db.select(db.roundupCards).get()))!.length,
          1,
        );
        await t.tap(find.text('Undo'));
        await settle(t);
        expect((await t.runAsync(repo.getAll))!.single.archived, isFalse);
        expect(find.byIcon(Icons.bookmark), findsOneWidget);
        expect(t.takeException(), isNull);
      } finally {
        await cleanup(t);
      }
    },
  );

  testWidgets(
    'article toolbar toggles save, remove, and save again without duplicates',
    (t) async {
      try {
        await mount(t, const CommentsScreen(storyId: 100));
        await t.tap(find.byIcon(Icons.bookmark_border));
        await settle(t);
        await t.tap(find.byIcon(Icons.bookmark));
        await settle(t);
        expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
        await t.tap(find.byIcon(Icons.bookmark_border));
        await settle(t);
        final saved =
            (await t.runAsync(() => BookmarkRepository(db).getAll()))!;
        expect(saved.length, 1);
        expect(saved.single.archived, isFalse);
        expect(t.takeException(), isNull);
      } finally {
        await cleanup(t);
      }
    },
  );

  testWidgets(
    'long-press a nested comment exposes save and remove on a small phone',
    (t) async {
      try {
        await mount(t, const CommentsScreen(storyId: 100));
        final tile = find.byWidgetPredicate(
          (w) => w is CommentTile && w.node.comment.id == 102,
        );
        await t.longPress(tile);
        await t.pumpAndSettle();
        expect(find.text('Save comment').hitTestable(), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.tap(find.text('Save comment'));
        await settle(t);
        final saved =
            (await t.runAsync(() => BookmarkRepository(db).getAll()))!.single;
        expect(saved.hnItemId, 102);
        expect(saved.type, 'hnComment');
        expect(saved.contentText, 'A useful nested reply');
        expect(saved.hnUrl, 'https://news.ycombinator.com/item?id=100');
        expect(t.widget<CommentTile>(tile).isBookmarked, isTrue);
        await t.longPress(tile);
        await t.pumpAndSettle();
        await t.tap(find.text('Remove saved comment'));
        await settle(t);
        expect(t.widget<CommentTile>(tile).isBookmarked, isFalse);
        expect(
          (await t.runAsync(
            () => BookmarkRepository(db).getAll(),
          ))!.single.archived,
          isTrue,
        );
        expect(t.takeException(), isNull);
      } finally {
        await cleanup(t);
      }
    },
  );

  testWidgets('comment actions stay reachable in landscape with large text', (
    t,
  ) async {
    try {
      CommentAction? chosen;
      await mount(
        t,
        Builder(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed:
                        () => showModalBottomSheet<void>(
                          context: context,
                          builder:
                              (_) => CommentActionsSheet(
                                comment: reply,
                                onAction: (action) => chosen = action,
                              ),
                        ),
                    child: const Text('Actions'),
                  ),
                ),
              ),
        ),
        size: const Size(640, 360),
        textScale: 1.5,
      );
      await t.tap(find.text('Actions'));
      await t.pumpAndSettle();
      expect(find.text('Save comment').hitTestable(), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.scrollUntilVisible(
        find.text('Send comment text to...'),
        100,
        scrollable: find.descendant(
          of: find.byType(CommentActionsSheet),
          matching: find.byType(Scrollable),
        ),
      );
      await t.tap(find.text('Send comment text to...'));
      await t.pumpAndSettle();
      expect(chosen, CommentAction.sendText);
      expect(t.takeException(), isNull);
    } finally {
      await cleanup(t);
    }
  });
}

Future<void> settle(WidgetTester t) async {
  await t.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 80)),
  );
  await t.pumpAndSettle();
}
