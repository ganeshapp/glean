enum BookmarkType {
  hnArticle,
  hnComment,
  tweet,
  website,
}

class Bookmark {
  final int? id;
  final BookmarkType type;
  final String? title;
  final String? contentText;
  final String? contentUrl;
  final String? hnUrl;
  final int? hnItemId;
  final String? author;
  final String? summary;
  final String? domain;
  final bool isPublished;
  final String? publishedWeek;
  final DateTime createdAt;

  Bookmark({
    this.id,
    required this.type,
    this.title,
    this.contentText,
    this.contentUrl,
    this.hnUrl,
    this.hnItemId,
    this.author,
    this.summary,
    this.domain,
    this.isPublished = false,
    this.publishedWeek,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Bookmark copyWith({
    int? id,
    BookmarkType? type,
    String? title,
    String? contentText,
    String? contentUrl,
    String? hnUrl,
    int? hnItemId,
    String? author,
    String? summary,
    String? domain,
    bool? isPublished,
    String? publishedWeek,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      contentText: contentText ?? this.contentText,
      contentUrl: contentUrl ?? this.contentUrl,
      hnUrl: hnUrl ?? this.hnUrl,
      hnItemId: hnItemId ?? this.hnItemId,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      domain: domain ?? this.domain,
      isPublished: isPublished ?? this.isPublished,
      publishedWeek: publishedWeek ?? this.publishedWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
