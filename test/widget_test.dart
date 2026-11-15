import 'dart:io';
import 'dart:ui' as ui;
import 'photos_test.dart' show fixturePhoto;
import 'package:glean/features/photos/roundup_photo_view.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/core/theme/app_theme.dart';
import 'package:glean/data/database/app_database.dart';
import 'package:glean/data/models/bookmark.dart';
import 'package:glean/data/repositories/bookmark_repository.dart';
import 'package:glean/data/repositories/roundup_repository.dart';
import 'package:glean/data/api/github_service.dart';
import 'package:glean/features/bookmarks/bookmark_provider.dart';
import 'package:glean/features/bookmarks/bookmark_detail_screen.dart';
import 'package:glean/features/publish/publish_screen.dart';
import 'package:glean/features/publish/publish_provider.dart';
import 'package:glean/features/publish/roundup_provider.dart';
import 'package:glean/features/settings/settings_screen.dart';
import 'package:glean/features/share_receiver/share_handler.dart';

class SavedGitHub extends Fake implements GitHubService {
  @override
  Future<Map<String, dynamic>?> session() async => {'login': 'example'};
  @override
  Future<bool> isConnected() async => true;
  @override
  Future<String?> getRepo() async => 'example/site';
  @override
  Future<String?> getFolder() async => '_roundup';
  @override
  Future<String?> getBranch() async => 'main';
  @override
  Future<String?> getSiteUrl() async => 'https://example.com';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = Platform.environment['GLEAN_TEST_FONT_DIR'];
    if (dir != null) {
      for (final weight in ['Regular', 'Medium', 'Bold', 'Italic']) {
        await ui.loadFontFromList(
          await File('$dir/Roboto-$weight.ttf').readAsBytes(),
          fontFamily: 'Roboto',
        );
      }
      await ui.loadFontFromList(
        await File('$dir/MaterialIcons-Regular.otf').readAsBytes(),
        fontFamily: 'MaterialIcons',
      );
    }
  });
  late AppDatabase db;
  late RoundupIssue issue;
  late List<RoundupCard> cards;
  late int bookmarkId;
  final boundary = GlobalKey();
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final saved = BookmarkRepository(db), repo = RoundupRepository(db);
    issue = await repo.ensureWeek(DateTime(2026, 11, 14));
    bookmarkId = await saved.addBookmark(
      Bookmark(
        type: BookmarkType.hnArticle,
        title: 'Small tools, lasting ideas',
        contentUrl: 'https://example.com/article',
        summary: 'A private working note',
      ),
    );
    await repo.include(issue.id, (await saved.get(bookmarkId))!);
    final quote = await saved.addBookmark(
      Bookmark(
        type: BookmarkType.hnComment,
        hnItemId: 42,
        author: 'reader',
        contentUrl: 'https://news.ycombinator.com/item?id=42',
        contentText: 'A useful tool makes the next action obvious.',
      ),
    );
    await repo.include(issue.id, (await saved.get(quote))!);
    cards = await repo.cards(issue.id);
    await repo.editCard(
      cards.first.copyWith(
        blurb: 'This is the idea I want to try in my own projects.',
      ),
    );
    cards = await repo.cards(issue.id);
  });
  tearDown(() => db.close());
  Widget host(Widget child) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      currentIssueProvider.overrideWith((ref) async => issue),
      githubServiceProvider.overrideWithValue(SavedGitHub()),
    ],
    child: RepaintBoundary(
      key: boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: child,
      ),
    ),
  );
  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
  }

  Future<void> settle(WidgetTester t) async {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await t.pumpAndSettle();
  }

  Future<void> capture(WidgetTester t, String name) async {
    final dir = Platform.environment['GLEAN_TEST_SCREENSHOTS'];
    if (dir == null) return;
    await t.runAsync(() async {
      await Directory(dir).create(recursive: true);
      final image = await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$dir/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets(
    'mixed cards render, reorder persists, and preview renders without raw Markdown',
    (t) async {
      phone(t);
      await t.pumpWidget(host(PublishScreen(issueId: issue.id)));
      await settle(t);
      expect(find.text('Small tools, lasting ideas'), findsOneWidget);
      expect(find.text('A private working note'), findsNothing);
      await capture(t, 'roundup-editor');
      await t.tap(find.byType(PopupMenuButton<String>).first);
      await t.pumpAndSettle();
      await t.tap(find.text('Move down'));
      await settle(t);
      final reordered = await t.runAsync(
        () => RoundupRepository(db).cards(issue.id),
      );
      expect(reordered!.first.type, 'hnComment');
      await t.tap(find.text('Preview'));
      await t.pumpAndSettle();
      expect(find.text('Reader preview'), findsOneWidget);
      expect(find.textContaining('## Articles'), findsNothing);
      await capture(t, 'roundup-preview');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 10));
      await t.runAsync(() => db.close());
    },
  );
  testWidgets(
    'card edits autosave and personal notes require an explicit copy action',
    (t) async {
      phone(t);
      await t.pumpWidget(host(RoundupCardEditor(card: cards.first)));
      await settle(t);
      expect(find.text('A private working note'), findsNothing);
      await t.enterText(find.byType(TextField).at(1), 'A fresh public angle');
      await settle(t);
      var saved = await t.runAsync(() => RoundupRepository(db).cards(issue.id));
      expect(saved!.first.blurb, 'A fresh public angle');
      await t.runAsync(
        () => RoundupRepository(
          db,
        ).editCard(saved!.first.copyWith(author: 'Fetched attribution')),
      );

      await t.ensureVisible(find.text('Use my saved thought as public text'));
      await t.tap(find.text('Use my saved thought as public text'));
      await settle(t);
      saved = await t.runAsync(() => RoundupRepository(db).cards(issue.id));
      expect(saved!.first.blurb, 'A private working note');
      expect(saved.first.author, 'Fetched attribution');
      await capture(t, 'card-editor');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 10));
      await t.runAsync(() => db.close());
    },
  );
  testWidgets('saved-item editor exposes a private thought and saves changes', (
    t,
  ) async {
    phone(t);
    await t.pumpWidget(host(BookmarkDetailScreen(id: bookmarkId)));
    await settle(t);
    expect(find.text('Why did this catch your attention?'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(1), 'My new private note');
    await settle(t);
    final saved = await t.runAsync(
      () => BookmarkRepository(db).get(bookmarkId),
    );
    expect(saved!.summary, 'My new private note');
    await t.enterText(find.byType(TextField).at(1), 'Quick edit');
    await t.enterText(find.byType(TextField).at(1), 'A private working note');
    await settle(t);
    final reverted = await t.runAsync(
      () => BookmarkRepository(db).get(bookmarkId),
    );
    expect(reverted!.summary, 'A private working note');
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 10));
    await t.runAsync(() => db.close());
  });
  testWidgets(
    'rapid capture actions close the sheet once and keep the app route',
    (t) async {
      phone(t);
      ShareHandler? handler;
      await t.pumpWidget(
        host(
          Consumer(
            builder:
                (context, ref, _) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () {
                        handler = ShareHandler(ref, context);
                        handler!.capture('A selected excerpt without a URL');
                      },
                      child: const Text('Capture test item'),
                    ),
                  ),
                ),
          ),
        ),
      );
      await t.tap(find.text('Capture test item'));
      await settle(t);
      final action =
          t
              .widget<OutlinedButton>(
                find.ancestor(
                  of: find.text('Include this week'),
                  matching: find.byWidgetPredicate((w) => w is OutlinedButton),
                ),
              )
              .onPressed!;
      action();
      action();
      await settle(t);
      expect(find.text('Capture test item'), findsOneWidget);
      expect(find.text('Include this week'), findsNothing);
      expect(t.takeException(), isNull);
      final saved = await t.runAsync(() => BookmarkRepository(db).getAll());
      expect(
        saved!
            .where((b) => b.contentText == 'A selected excerpt without a URL')
            .length,
        1,
      );
      handler!.dispose();
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 10));
      await t.runAsync(() => db.close());
    },
  );
  testWidgets('settings reopen with a stored repository and folder', (t) async {
    phone(t);
    await t.pumpWidget(host(const SettingsScreen()));
    await settle(t);
    expect(find.text('_roundup'), findsOneWidget);
    expect(find.text('example/site'), findsOneWidget);
    expect(find.text('GitHub PAT Token'), findsNothing);
    expect(t.takeException(), isNull);
    await capture(t, 'github-settings');
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 10));
    await t.runAsync(() => db.close());
  });
  testWidgets(
    'photo cards reorder, edit caption and explanation, and render locally in preview',
    (t) async {
      phone(t);
      final repo = RoundupRepository(db);
      final photo = fixturePhoto();
      await repo.addPhoto(issue.id, photo);
      var list = await repo.cards(issue.id);
      await repo.reorder(issue.id, [list.last.id, list.first.id, list[1].id]);
      await t.pumpWidget(host(PublishScreen(issueId: issue.id)));
      await settle(t);
      expect(find.byType(RoundupPhotoView), findsOneWidget);
      await t.tap(find.text('Add a caption'));
      await settle(t);
      expect(find.byType(TextField), findsNWidgets(2));
      await t.enterText(find.byType(TextField).first, 'Morning light');
      await t.enterText(
        find.byType(TextField).last,
        'A useful reminder to look up.',
      );
      await settle(t);
      list = (await t.runAsync(() => repo.cards(issue.id)))!;
      expect(list.first.title, 'Morning light');
      expect(list.first.blurb, 'A useful reminder to look up.');
      await capture(t, 'photo-editor');
      await t.pageBack();
      await settle(t);
      await t.tap(find.byType(PopupMenuButton<String>).first);
      await t.pumpAndSettle();
      await t.tap(find.text('Move down'));
      await settle(t);
      list = (await t.runAsync(() => repo.cards(issue.id)))!;
      expect(list[1].photoId, photo.id);
      await capture(t, 'photos-in-roundup');
      await t.tap(find.text('Preview'));
      await settle(t);
      expect(find.byType(RoundupPhotoView), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await capture(t, 'photo-preview');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 10));
      await t.runAsync(() => db.close());
    },
  );
}
