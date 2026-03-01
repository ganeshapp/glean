import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/algolia_service.dart';
import '../../data/models/search_result.dart';

final algoliaServiceProvider = Provider<AlgoliaService>((ref) => AlgoliaService());

class SearchState {
  final List<SearchHit> results;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String query;
  final SearchTimeRange timeRange;
  final SearchSortOrder sortOrder;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.error,
    this.query = '',
    this.timeRange = SearchTimeRange.lastYear,
    this.sortOrder = SearchSortOrder.popularity,
  });

  SearchState copyWith({
    List<SearchHit>? results,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    String? query,
    SearchTimeRange? timeRange,
    SearchSortOrder? sortOrder,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      query: query ?? this.query,
      timeRange: timeRange ?? this.timeRange,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final AlgoliaService _algolia;

  SearchNotifier(this._algolia) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    state = SearchState(
      isLoading: true,
      query: query,
      timeRange: state.timeRange,
      sortOrder: state.sortOrder,
    );
    try {
      final response = await _algolia.search(
        query: query,
        timeRange: state.timeRange,
        sort: state.sortOrder,
        page: 0,
      );
      state = state.copyWith(
        results: response.hits,
        isLoading: false,
        hasMore: response.page < response.nbPages - 1,
        currentPage: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _algolia.search(
        query: state.query,
        timeRange: state.timeRange,
        sort: state.sortOrder,
        page: nextPage,
      );
      state = state.copyWith(
        results: [...state.results, ...response.hits],
        isLoading: false,
        hasMore: nextPage < response.nbPages - 1,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setTimeRange(SearchTimeRange range) {
    state = state.copyWith(timeRange: range);
    if (state.query.isNotEmpty) search(state.query);
  }

  void setSortOrder(SearchSortOrder order) {
    state = state.copyWith(sortOrder: order);
    if (state.query.isNotEmpty) search(state.query);
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(algoliaServiceProvider));
});
