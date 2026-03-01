import 'package:dio/dio.dart';

import '../../core/constants/hn_constants.dart';
import '../models/hn_story.dart';
import '../models/hn_comment.dart';

class HnApiService {
  final Dio _dio;

  HnApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: HnConstants.firebaseBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<List<int>> getStoryIds(String endpoint) async {
    final response = await _dio.get('/$endpoint.json');
    return (response.data as List<dynamic>).cast<int>();
  }

  Future<List<int>> getTopStoryIds() => getStoryIds('topstories');
  Future<List<int>> getNewStoryIds() => getStoryIds('newstories');
  Future<List<int>> getBestStoryIds() => getStoryIds('beststories');
  Future<List<int>> getAskStoryIds() => getStoryIds('askstories');
  Future<List<int>> getShowStoryIds() => getStoryIds('showstories');
  Future<List<int>> getJobStoryIds() => getStoryIds('jobstories');

  Future<HnStory?> getStory(int id) async {
    try {
      final response = await _dio.get('/item/$id.json');
      if (response.data == null) return null;
      return HnStory.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<HnComment?> getComment(int id) async {
    try {
      final response = await _dio.get('/item/$id.json');
      if (response.data == null) return null;
      return HnComment.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<HnStory>> getStoriesPage(
    List<int> allIds, {
    required int page,
    int pageSize = 20,
  }) async {
    final start = page * pageSize;
    if (start >= allIds.length) return [];
    final end = (start + pageSize).clamp(0, allIds.length);
    final pageIds = allIds.sublist(start, end);

    final futures = pageIds.map((id) => getStory(id));
    final results = await Future.wait(futures);
    return results.whereType<HnStory>().toList();
  }
}
