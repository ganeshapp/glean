class HnStory {
  final int id;
  final String? title;
  final String? url;
  final String? text;
  final String by;
  final int time;
  final int score;
  final int descendants;
  final List<int> kids;
  final String type;

  HnStory({
    required this.id,
    this.title,
    this.url,
    this.text,
    required this.by,
    required this.time,
    this.score = 0,
    this.descendants = 0,
    this.kids = const [],
    this.type = 'story',
  });

  factory HnStory.fromJson(Map<String, dynamic> json) {
    return HnStory(
      id: json['id'] as int,
      title: json['title'] as String?,
      url: json['url'] as String?,
      text: json['text'] as String?,
      by: (json['by'] as String?) ?? '',
      time: (json['time'] as int?) ?? 0,
      score: (json['score'] as int?) ?? 0,
      descendants: (json['descendants'] as int?) ?? 0,
      kids: (json['kids'] as List<dynamic>?)?.cast<int>() ?? const [],
      type: (json['type'] as String?) ?? 'story',
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(time * 1000);

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
