import 'package:go_router/go_router.dart';
import '../../features/app_shell.dart';
import '../../features/bookmarks/bookmark_detail_screen.dart';
import '../../features/exports/exports_screen.dart';

import '../../features/feed/feed_screen.dart';
import '../../features/comments/comments_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/publish/publish_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigation: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const FeedScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookmarks',
                builder: (_, _) => const BookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/publish',
                builder: (_, _) => const PublishScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/saved/:id',
        builder:
            (_, state) => BookmarkDetailScreen(
              id: int.parse(state.pathParameters['id']!),
            ),
      ),
      GoRoute(
        path: '/issue/:id',
        builder:
            (_, state) => PublishScreen(issueId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/exports', builder: (_, _) => const ExportsScreen()),
      GoRoute(
        path: '/comments/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CommentsScreen(storyId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
