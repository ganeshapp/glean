import 'package:dio/dio.dart';

import '../../core/constants/hn_constants.dart';
import '../models/search_result.dart';

enum SearchTimeRange {
  last24h('Last 24h', Duration(hours: 24)),
  pastWeek('Past week', Duration(days: 7)),
  pastMonth('Past month', Duration(days: 30)),
  lastYear('Last year', Duration(days: 365)),
  allTime('All time', null);

  const SearchTimeRange(this.label, this.duration);
  final String label;
  final Duration? duration;
}

enum SearchSortOrder {
  popularity('Popularity'),
  date('Date');

  const SearchSortOrder(this.label);
  final String label;
}

class AlgoliaService {
  final Dio _dio;

  AlgoliaService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: HnConstants.algoliaBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<SearchResponse> search({
    required String query,
    SearchTimeRange timeRange = SearchTimeRange.lastYear,
    SearchSortOrder sort = SearchSortOrder.popularity,
    int page = 0,
    int hitsPerPage = 20,
  }) async {
    final endpoint =
        sort == SearchSortOrder.date ? '/search_by_date' : '/search';

    final params = <String, dynamic>{
      'query': query,
      'tags': 'story',
      'page': page,
      'hitsPerPage': hitsPerPage,
    };

    if (timeRange.duration != null) {
      final cutoff = DateTime.now().subtract(timeRange.duration!);
      final cutoffSec = cutoff.millisecondsSinceEpoch ~/ 1000;
      params['numericFilters'] = ['created_at_i>$cutoffSec'];
    }

    final response = await _dio.get(endpoint, queryParameters: params);
    return SearchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
