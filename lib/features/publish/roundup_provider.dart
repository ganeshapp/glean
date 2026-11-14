import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/roundup_repository.dart';
import '../bookmarks/bookmark_provider.dart';

final roundupRepositoryProvider = Provider(
  (ref) => RoundupRepository(ref.watch(appDatabaseProvider)),
);
final currentIssueProvider = FutureProvider(
  (ref) => ref.watch(roundupRepositoryProvider).ensureWeek(),
);
final issueProvider = StreamProvider.family<RoundupIssue, String>(
  (ref, id) => ref.watch(roundupRepositoryProvider).watchIssue(id),
);
final issueCardsProvider = StreamProvider.family<List<RoundupCard>, String>(
  (ref, id) => ref.watch(roundupRepositoryProvider).watchCards(id),
);
final issuesProvider = StreamProvider(
  (ref) => ref.watch(roundupRepositoryProvider).watchIssues(),
);
