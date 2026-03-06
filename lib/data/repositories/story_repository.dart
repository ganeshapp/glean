import '../api/hn_api_service.dart';
import '../models/hn_story.dart';
import '../../features/feed/feed_screen.dart';

class StoryRepository {
  final HnApiService _api;

  StoryRepository({HnApiService? api}) : _api = api ?? HnApiService();

  Future<List<int>> getStoryIds(FeedCategory category) {
    switch (category) {
      case FeedCategory.top:
        return _api.getTopStoryIds();
      case FeedCategory.newest:
        return _api.getNewStoryIds();
      case FeedCategory.ask:
        return _api.getAskStoryIds();
      case FeedCategory.show:
        return _api.getShowStoryIds();
    }
  }

  Future<List<HnStory>> getStoriesPage(
    List<int> ids, {
    required int page,
    int pageSize = 20,
  }) {
    return _api.getStoriesPage(ids, page: page, pageSize: pageSize);
  }

  Future<HnStory?> getStory(int id) => _api.getStory(id);
}
