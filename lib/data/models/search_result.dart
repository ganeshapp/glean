class SearchHit {
  final int objectId;
  final String title;
  final String? url;
  final String author;
  final int points;
  final int numComments;
  final int createdAtI;

  SearchHit({
    required this.objectId,
    required this.title,
    this.url,
    required this.author,
    this.points = 0,
    this.numComments = 0,
    required this.createdAtI,
  });

  factory SearchHit.fromJson(Map<String, dynamic> json) {
    return SearchHit(
      objectId: int.tryParse(json['objectID']?.toString() ?? '') ?? 0,
      title: (json['title'] as String?) ?? '',
      url: json['url'] as String?,
      author: (json['author'] as String?) ?? '',
      points: (json['points'] as int?) ?? 0,
      numComments: (json['num_comments'] as int?) ?? 0,
      createdAtI: (json['created_at_i'] as int?) ?? 0,
    );
  }

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAtI * 1000);

  String? get domain {
    if (url == null || url!.isEmpty) return null;
    try {
      final uri = Uri.parse(url!);
      var host = uri.host;
      if (host.startsWith('www.')) host = host.substring(4);
      return host;
    } catch (_) {
      return null;
    }
  }
}

class SearchResponse {
  final List<SearchHit> hits;
  final int nbHits;
  final int page;
  final int nbPages;

  SearchResponse({
    required this.hits,
    required this.nbHits,
    required this.page,
    required this.nbPages,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      hits: (json['hits'] as List<dynamic>)
          .map((h) => SearchHit.fromJson(h as Map<String, dynamic>))
          .toList(),
      nbHits: (json['nbHits'] as int?) ?? 0,
      page: (json['page'] as int?) ?? 0,
      nbPages: (json['nbPages'] as int?) ?? 0,
    );
  }
}
