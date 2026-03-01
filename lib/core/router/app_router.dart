import 'package:go_router/go_router.dart';

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
      GoRoute(
        path: '/',
        builder: (context, state) => const FeedScreen(),
      ),
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
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/publish',
        builder: (context, state) => const PublishScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
