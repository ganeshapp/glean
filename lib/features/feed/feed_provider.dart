import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/hn_api_service.dart';
import '../../data/models/hn_story.dart';
import '../../data/repositories/story_repository.dart';
import 'feed_screen.dart';

final hnApiServiceProvider = Provider<HnApiService>((ref) => HnApiService());

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(api: ref.watch(hnApiServiceProvider));
});

final storyIdsProvider =
    FutureProvider.family<List<int>, FeedCategory>((ref, category) {
  return ref.watch(storyRepositoryProvider).getStoryIds(category);
});

class FeedState {
  final List<HnStory> stories;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const FeedState({
    this.stories = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  FeedState copyWith({
    List<HnStory>? stories,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return FeedState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final StoryRepository _repository;
  List<int> _allIds = [];
  FeedCategory _category = FeedCategory.top;

  FeedNotifier(this._repository) : super(const FeedState());

  Future<void> loadCategory(FeedCategory category) async {
    if (_category == category && state.stories.isNotEmpty) return;
    _category = category;
    state = const FeedState(isLoading: true);
    try {
      _allIds = await _repository.getStoryIds(category);
      final stories = await _repository.getStoriesPage(_allIds, page: 0);
      state = FeedState(
        stories: stories,
        currentPage: 0,
        hasMore: stories.length < _allIds.length,
      );
    } catch (e) {
      state = FeedState(error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final moreStories =
          await _repository.getStoriesPage(_allIds, page: nextPage);
      final allStories = [...state.stories, ...moreStories];
      state = state.copyWith(
        stories: allStories,
        currentPage: nextPage,
        isLoading: false,
        hasMore: allStories.length < _allIds.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const FeedState(isLoading: true);
    try {
      _allIds = await _repository.getStoryIds(_category);
      final stories = await _repository.getStoriesPage(_allIds, page: 0);
      state = FeedState(
        stories: stories,
        currentPage: 0,
        hasMore: stories.length < _allIds.length,
      );
    } catch (e) {
      state = FeedState(error: e.toString());
    }
  }
}

final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repo = ref.watch(storyRepositoryProvider);
  return FeedNotifier(repo);
});
