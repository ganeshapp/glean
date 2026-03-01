class HnComment {
  final int id;
  final String? text;
  final String by;
  final int time;
  final int parent;
  final List<int> kids;
  final bool dead;
  final bool deleted;

  HnComment({
    required this.id,
    this.text,
    required this.by,
    required this.time,
    required this.parent,
    this.kids = const [],
    this.dead = false,
    this.deleted = false,
  });

  factory HnComment.fromJson(Map<String, dynamic> json) {
    return HnComment(
      id: json['id'] as int,
      text: json['text'] as String?,
      by: (json['by'] as String?) ?? '[deleted]',
      time: (json['time'] as int?) ?? 0,
      parent: (json['parent'] as int?) ?? 0,
      kids: (json['kids'] as List<dynamic>?)?.cast<int>() ?? const [],
      dead: (json['dead'] as bool?) ?? false,
      deleted: (json['deleted'] as bool?) ?? false,
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(time * 1000);
}
