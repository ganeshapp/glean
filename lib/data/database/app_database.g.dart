// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BookmarksTableTable extends BookmarksTable
    with TableInfo<$BookmarksTableTable, BookmarksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTextMeta = const VerificationMeta(
    'contentText',
  );
  @override
  late final GeneratedColumn<String> contentText = GeneratedColumn<String>(
    'content_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentUrlMeta = const VerificationMeta(
    'contentUrl',
  );
  @override
  late final GeneratedColumn<String> contentUrl = GeneratedColumn<String>(
    'content_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hnUrlMeta = const VerificationMeta('hnUrl');
  @override
  late final GeneratedColumn<String> hnUrl = GeneratedColumn<String>(
    'hn_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hnItemIdMeta = const VerificationMeta(
    'hnItemId',
  );
  @override
  late final GeneratedColumn<int> hnItemId = GeneratedColumn<int>(
    'hn_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _publishedWeekMeta = const VerificationMeta(
    'publishedWeek',
  );
  @override
  late final GeneratedColumn<String> publishedWeek = GeneratedColumn<String>(
    'published_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canonicalKeyMeta = const VerificationMeta(
    'canonicalKey',
  );
  @override
  late final GeneratedColumn<String> canonicalKey = GeneratedColumn<String>(
    'canonical_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    contentText,
    contentUrl,
    hnUrl,
    hnItemId,
    author,
    summary,
    domain,
    isPublished,
    publishedWeek,
    createdAt,
    archived,
    canonicalKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content_text')) {
      context.handle(
        _contentTextMeta,
        contentText.isAcceptableOrUnknown(
          data['content_text']!,
          _contentTextMeta,
        ),
      );
    }
    if (data.containsKey('content_url')) {
      context.handle(
        _contentUrlMeta,
        contentUrl.isAcceptableOrUnknown(data['content_url']!, _contentUrlMeta),
      );
    }
    if (data.containsKey('hn_url')) {
      context.handle(
        _hnUrlMeta,
        hnUrl.isAcceptableOrUnknown(data['hn_url']!, _hnUrlMeta),
      );
    }
    if (data.containsKey('hn_item_id')) {
      context.handle(
        _hnItemIdMeta,
        hnItemId.isAcceptableOrUnknown(data['hn_item_id']!, _hnItemIdMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('published_week')) {
      context.handle(
        _publishedWeekMeta,
        publishedWeek.isAcceptableOrUnknown(
          data['published_week']!,
          _publishedWeekMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('canonical_key')) {
      context.handle(
        _canonicalKeyMeta,
        canonicalKey.isAcceptableOrUnknown(
          data['canonical_key']!,
          _canonicalKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarksTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      contentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_text'],
      ),
      contentUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_url'],
      ),
      hnUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hn_url'],
      ),
      hnItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hn_item_id'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      ),
      isPublished:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_published'],
          )!,
      publishedWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_week'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      archived:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}archived'],
          )!,
      canonicalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_key'],
      ),
    );
  }

  @override
  $BookmarksTableTable createAlias(String alias) {
    return $BookmarksTableTable(attachedDatabase, alias);
  }
}

class BookmarksTableData extends DataClass
    implements Insertable<BookmarksTableData> {
  final int id;
  final String type;
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
  final bool archived;
  final String? canonicalKey;
  const BookmarksTableData({
    required this.id,
    required this.type,
    this.title,
    this.contentText,
    this.contentUrl,
    this.hnUrl,
    this.hnItemId,
    this.author,
    this.summary,
    this.domain,
    required this.isPublished,
    this.publishedWeek,
    required this.createdAt,
    required this.archived,
    this.canonicalKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || contentText != null) {
      map['content_text'] = Variable<String>(contentText);
    }
    if (!nullToAbsent || contentUrl != null) {
      map['content_url'] = Variable<String>(contentUrl);
    }
    if (!nullToAbsent || hnUrl != null) {
      map['hn_url'] = Variable<String>(hnUrl);
    }
    if (!nullToAbsent || hnItemId != null) {
      map['hn_item_id'] = Variable<int>(hnItemId);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || domain != null) {
      map['domain'] = Variable<String>(domain);
    }
    map['is_published'] = Variable<bool>(isPublished);
    if (!nullToAbsent || publishedWeek != null) {
      map['published_week'] = Variable<String>(publishedWeek);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || canonicalKey != null) {
      map['canonical_key'] = Variable<String>(canonicalKey);
    }
    return map;
  }

  BookmarksTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarksTableCompanion(
      id: Value(id),
      type: Value(type),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      contentText:
          contentText == null && nullToAbsent
              ? const Value.absent()
              : Value(contentText),
      contentUrl:
          contentUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(contentUrl),
      hnUrl:
          hnUrl == null && nullToAbsent ? const Value.absent() : Value(hnUrl),
      hnItemId:
          hnItemId == null && nullToAbsent
              ? const Value.absent()
              : Value(hnItemId),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      summary:
          summary == null && nullToAbsent
              ? const Value.absent()
              : Value(summary),
      domain:
          domain == null && nullToAbsent ? const Value.absent() : Value(domain),
      isPublished: Value(isPublished),
      publishedWeek:
          publishedWeek == null && nullToAbsent
              ? const Value.absent()
              : Value(publishedWeek),
      createdAt: Value(createdAt),
      archived: Value(archived),
      canonicalKey:
          canonicalKey == null && nullToAbsent
              ? const Value.absent()
              : Value(canonicalKey),
    );
  }

  factory BookmarksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarksTableData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      contentText: serializer.fromJson<String?>(json['contentText']),
      contentUrl: serializer.fromJson<String?>(json['contentUrl']),
      hnUrl: serializer.fromJson<String?>(json['hnUrl']),
      hnItemId: serializer.fromJson<int?>(json['hnItemId']),
      author: serializer.fromJson<String?>(json['author']),
      summary: serializer.fromJson<String?>(json['summary']),
      domain: serializer.fromJson<String?>(json['domain']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      publishedWeek: serializer.fromJson<String?>(json['publishedWeek']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archived: serializer.fromJson<bool>(json['archived']),
      canonicalKey: serializer.fromJson<String?>(json['canonicalKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'contentText': serializer.toJson<String?>(contentText),
      'contentUrl': serializer.toJson<String?>(contentUrl),
      'hnUrl': serializer.toJson<String?>(hnUrl),
      'hnItemId': serializer.toJson<int?>(hnItemId),
      'author': serializer.toJson<String?>(author),
      'summary': serializer.toJson<String?>(summary),
      'domain': serializer.toJson<String?>(domain),
      'isPublished': serializer.toJson<bool>(isPublished),
      'publishedWeek': serializer.toJson<String?>(publishedWeek),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archived': serializer.toJson<bool>(archived),
      'canonicalKey': serializer.toJson<String?>(canonicalKey),
    };
  }

  BookmarksTableData copyWith({
    int? id,
    String? type,
    Value<String?> title = const Value.absent(),
    Value<String?> contentText = const Value.absent(),
    Value<String?> contentUrl = const Value.absent(),
    Value<String?> hnUrl = const Value.absent(),
    Value<int?> hnItemId = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> domain = const Value.absent(),
    bool? isPublished,
    Value<String?> publishedWeek = const Value.absent(),
    DateTime? createdAt,
    bool? archived,
    Value<String?> canonicalKey = const Value.absent(),
  }) => BookmarksTableData(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    contentText: contentText.present ? contentText.value : this.contentText,
    contentUrl: contentUrl.present ? contentUrl.value : this.contentUrl,
    hnUrl: hnUrl.present ? hnUrl.value : this.hnUrl,
    hnItemId: hnItemId.present ? hnItemId.value : this.hnItemId,
    author: author.present ? author.value : this.author,
    summary: summary.present ? summary.value : this.summary,
    domain: domain.present ? domain.value : this.domain,
    isPublished: isPublished ?? this.isPublished,
    publishedWeek:
        publishedWeek.present ? publishedWeek.value : this.publishedWeek,
    createdAt: createdAt ?? this.createdAt,
    archived: archived ?? this.archived,
    canonicalKey: canonicalKey.present ? canonicalKey.value : this.canonicalKey,
  );
  BookmarksTableData copyWithCompanion(BookmarksTableCompanion data) {
    return BookmarksTableData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      contentText:
          data.contentText.present ? data.contentText.value : this.contentText,
      contentUrl:
          data.contentUrl.present ? data.contentUrl.value : this.contentUrl,
      hnUrl: data.hnUrl.present ? data.hnUrl.value : this.hnUrl,
      hnItemId: data.hnItemId.present ? data.hnItemId.value : this.hnItemId,
      author: data.author.present ? data.author.value : this.author,
      summary: data.summary.present ? data.summary.value : this.summary,
      domain: data.domain.present ? data.domain.value : this.domain,
      isPublished:
          data.isPublished.present ? data.isPublished.value : this.isPublished,
      publishedWeek:
          data.publishedWeek.present
              ? data.publishedWeek.value
              : this.publishedWeek,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archived: data.archived.present ? data.archived.value : this.archived,
      canonicalKey:
          data.canonicalKey.present
              ? data.canonicalKey.value
              : this.canonicalKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('contentText: $contentText, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('hnUrl: $hnUrl, ')
          ..write('hnItemId: $hnItemId, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('domain: $domain, ')
          ..write('isPublished: $isPublished, ')
          ..write('publishedWeek: $publishedWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('archived: $archived, ')
          ..write('canonicalKey: $canonicalKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    contentText,
    contentUrl,
    hnUrl,
    hnItemId,
    author,
    summary,
    domain,
    isPublished,
    publishedWeek,
    createdAt,
    archived,
    canonicalKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarksTableData &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.contentText == this.contentText &&
          other.contentUrl == this.contentUrl &&
          other.hnUrl == this.hnUrl &&
          other.hnItemId == this.hnItemId &&
          other.author == this.author &&
          other.summary == this.summary &&
          other.domain == this.domain &&
          other.isPublished == this.isPublished &&
          other.publishedWeek == this.publishedWeek &&
          other.createdAt == this.createdAt &&
          other.archived == this.archived &&
          other.canonicalKey == this.canonicalKey);
}

class BookmarksTableCompanion extends UpdateCompanion<BookmarksTableData> {
  final Value<int> id;
  final Value<String> type;
  final Value<String?> title;
  final Value<String?> contentText;
  final Value<String?> contentUrl;
  final Value<String?> hnUrl;
  final Value<int?> hnItemId;
  final Value<String?> author;
  final Value<String?> summary;
  final Value<String?> domain;
  final Value<bool> isPublished;
  final Value<String?> publishedWeek;
  final Value<DateTime> createdAt;
  final Value<bool> archived;
  final Value<String?> canonicalKey;
  const BookmarksTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.contentText = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.hnUrl = const Value.absent(),
    this.hnItemId = const Value.absent(),
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.domain = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.publishedWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.canonicalKey = const Value.absent(),
  });
  BookmarksTableCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.title = const Value.absent(),
    this.contentText = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.hnUrl = const Value.absent(),
    this.hnItemId = const Value.absent(),
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.domain = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.publishedWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.canonicalKey = const Value.absent(),
  }) : type = Value(type);
  static Insertable<BookmarksTableData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? contentText,
    Expression<String>? contentUrl,
    Expression<String>? hnUrl,
    Expression<int>? hnItemId,
    Expression<String>? author,
    Expression<String>? summary,
    Expression<String>? domain,
    Expression<bool>? isPublished,
    Expression<String>? publishedWeek,
    Expression<DateTime>? createdAt,
    Expression<bool>? archived,
    Expression<String>? canonicalKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (contentText != null) 'content_text': contentText,
      if (contentUrl != null) 'content_url': contentUrl,
      if (hnUrl != null) 'hn_url': hnUrl,
      if (hnItemId != null) 'hn_item_id': hnItemId,
      if (author != null) 'author': author,
      if (summary != null) 'summary': summary,
      if (domain != null) 'domain': domain,
      if (isPublished != null) 'is_published': isPublished,
      if (publishedWeek != null) 'published_week': publishedWeek,
      if (createdAt != null) 'created_at': createdAt,
      if (archived != null) 'archived': archived,
      if (canonicalKey != null) 'canonical_key': canonicalKey,
    });
  }

  BookmarksTableCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String?>? title,
    Value<String?>? contentText,
    Value<String?>? contentUrl,
    Value<String?>? hnUrl,
    Value<int?>? hnItemId,
    Value<String?>? author,
    Value<String?>? summary,
    Value<String?>? domain,
    Value<bool>? isPublished,
    Value<String?>? publishedWeek,
    Value<DateTime>? createdAt,
    Value<bool>? archived,
    Value<String?>? canonicalKey,
  }) {
    return BookmarksTableCompanion(
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
      archived: archived ?? this.archived,
      canonicalKey: canonicalKey ?? this.canonicalKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentText.present) {
      map['content_text'] = Variable<String>(contentText.value);
    }
    if (contentUrl.present) {
      map['content_url'] = Variable<String>(contentUrl.value);
    }
    if (hnUrl.present) {
      map['hn_url'] = Variable<String>(hnUrl.value);
    }
    if (hnItemId.present) {
      map['hn_item_id'] = Variable<int>(hnItemId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (publishedWeek.present) {
      map['published_week'] = Variable<String>(publishedWeek.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (canonicalKey.present) {
      map['canonical_key'] = Variable<String>(canonicalKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('contentText: $contentText, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('hnUrl: $hnUrl, ')
          ..write('hnItemId: $hnItemId, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('domain: $domain, ')
          ..write('isPublished: $isPublished, ')
          ..write('publishedWeek: $publishedWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('archived: $archived, ')
          ..write('canonicalKey: $canonicalKey')
          ..write(')'))
        .toString();
  }
}

class $RoundupIssuesTable extends RoundupIssues
    with TableInfo<$RoundupIssuesTable, RoundupIssue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundupIssuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _introductionMeta = const VerificationMeta(
    'introduction',
  );
  @override
  late final GeneratedColumn<String> introduction = GeneratedColumn<String>(
    'introduction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _publishedRevisionMeta = const VerificationMeta(
    'publishedRevision',
  );
  @override
  late final GeneratedColumn<int> publishedRevision = GeneratedColumn<int>(
    'published_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repositoryMeta = const VerificationMeta(
    'repository',
  );
  @override
  late final GeneratedColumn<String> repository = GeneratedColumn<String>(
    'repository',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
    'branch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteShaMeta = const VerificationMeta(
    'remoteSha',
  );
  @override
  late final GeneratedColumn<String> remoteSha = GeneratedColumn<String>(
    'remote_sha',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicUrlMeta = const VerificationMeta(
    'publicUrl',
  );
  @override
  late final GeneratedColumn<String> publicUrl = GeneratedColumn<String>(
    'public_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    introduction,
    date,
    revision,
    publishedRevision,
    publishedAt,
    repository,
    filePath,
    branch,
    remoteSha,
    publicUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roundup_issues';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoundupIssue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('introduction')) {
      context.handle(
        _introductionMeta,
        introduction.isAcceptableOrUnknown(
          data['introduction']!,
          _introductionMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('published_revision')) {
      context.handle(
        _publishedRevisionMeta,
        publishedRevision.isAcceptableOrUnknown(
          data['published_revision']!,
          _publishedRevisionMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('repository')) {
      context.handle(
        _repositoryMeta,
        repository.isAcceptableOrUnknown(data['repository']!, _repositoryMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('branch')) {
      context.handle(
        _branchMeta,
        branch.isAcceptableOrUnknown(data['branch']!, _branchMeta),
      );
    }
    if (data.containsKey('remote_sha')) {
      context.handle(
        _remoteShaMeta,
        remoteSha.isAcceptableOrUnknown(data['remote_sha']!, _remoteShaMeta),
      );
    }
    if (data.containsKey('public_url')) {
      context.handle(
        _publicUrlMeta,
        publicUrl.isAcceptableOrUnknown(data['public_url']!, _publicUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoundupIssue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundupIssue(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      introduction:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}introduction'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      revision:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}revision'],
          )!,
      publishedRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}published_revision'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      repository: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repository'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      branch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch'],
      ),
      remoteSha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_sha'],
      ),
      publicUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_url'],
      ),
    );
  }

  @override
  $RoundupIssuesTable createAlias(String alias) {
    return $RoundupIssuesTable(attachedDatabase, alias);
  }
}

class RoundupIssue extends DataClass implements Insertable<RoundupIssue> {
  final String id;
  final String title;
  final String introduction;
  final DateTime date;
  final int revision;
  final int? publishedRevision;
  final DateTime? publishedAt;
  final String? repository;
  final String? filePath;
  final String? branch;
  final String? remoteSha;
  final String? publicUrl;
  const RoundupIssue({
    required this.id,
    required this.title,
    required this.introduction,
    required this.date,
    required this.revision,
    this.publishedRevision,
    this.publishedAt,
    this.repository,
    this.filePath,
    this.branch,
    this.remoteSha,
    this.publicUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['introduction'] = Variable<String>(introduction);
    map['date'] = Variable<DateTime>(date);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || publishedRevision != null) {
      map['published_revision'] = Variable<int>(publishedRevision);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    if (!nullToAbsent || repository != null) {
      map['repository'] = Variable<String>(repository);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || branch != null) {
      map['branch'] = Variable<String>(branch);
    }
    if (!nullToAbsent || remoteSha != null) {
      map['remote_sha'] = Variable<String>(remoteSha);
    }
    if (!nullToAbsent || publicUrl != null) {
      map['public_url'] = Variable<String>(publicUrl);
    }
    return map;
  }

  RoundupIssuesCompanion toCompanion(bool nullToAbsent) {
    return RoundupIssuesCompanion(
      id: Value(id),
      title: Value(title),
      introduction: Value(introduction),
      date: Value(date),
      revision: Value(revision),
      publishedRevision:
          publishedRevision == null && nullToAbsent
              ? const Value.absent()
              : Value(publishedRevision),
      publishedAt:
          publishedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(publishedAt),
      repository:
          repository == null && nullToAbsent
              ? const Value.absent()
              : Value(repository),
      filePath:
          filePath == null && nullToAbsent
              ? const Value.absent()
              : Value(filePath),
      branch:
          branch == null && nullToAbsent ? const Value.absent() : Value(branch),
      remoteSha:
          remoteSha == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteSha),
      publicUrl:
          publicUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(publicUrl),
    );
  }

  factory RoundupIssue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundupIssue(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      introduction: serializer.fromJson<String>(json['introduction']),
      date: serializer.fromJson<DateTime>(json['date']),
      revision: serializer.fromJson<int>(json['revision']),
      publishedRevision: serializer.fromJson<int?>(json['publishedRevision']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      repository: serializer.fromJson<String?>(json['repository']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      branch: serializer.fromJson<String?>(json['branch']),
      remoteSha: serializer.fromJson<String?>(json['remoteSha']),
      publicUrl: serializer.fromJson<String?>(json['publicUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'introduction': serializer.toJson<String>(introduction),
      'date': serializer.toJson<DateTime>(date),
      'revision': serializer.toJson<int>(revision),
      'publishedRevision': serializer.toJson<int?>(publishedRevision),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'repository': serializer.toJson<String?>(repository),
      'filePath': serializer.toJson<String?>(filePath),
      'branch': serializer.toJson<String?>(branch),
      'remoteSha': serializer.toJson<String?>(remoteSha),
      'publicUrl': serializer.toJson<String?>(publicUrl),
    };
  }

  RoundupIssue copyWith({
    String? id,
    String? title,
    String? introduction,
    DateTime? date,
    int? revision,
    Value<int?> publishedRevision = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
    Value<String?> repository = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<String?> branch = const Value.absent(),
    Value<String?> remoteSha = const Value.absent(),
    Value<String?> publicUrl = const Value.absent(),
  }) => RoundupIssue(
    id: id ?? this.id,
    title: title ?? this.title,
    introduction: introduction ?? this.introduction,
    date: date ?? this.date,
    revision: revision ?? this.revision,
    publishedRevision:
        publishedRevision.present
            ? publishedRevision.value
            : this.publishedRevision,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    repository: repository.present ? repository.value : this.repository,
    filePath: filePath.present ? filePath.value : this.filePath,
    branch: branch.present ? branch.value : this.branch,
    remoteSha: remoteSha.present ? remoteSha.value : this.remoteSha,
    publicUrl: publicUrl.present ? publicUrl.value : this.publicUrl,
  );
  RoundupIssue copyWithCompanion(RoundupIssuesCompanion data) {
    return RoundupIssue(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      introduction:
          data.introduction.present
              ? data.introduction.value
              : this.introduction,
      date: data.date.present ? data.date.value : this.date,
      revision: data.revision.present ? data.revision.value : this.revision,
      publishedRevision:
          data.publishedRevision.present
              ? data.publishedRevision.value
              : this.publishedRevision,
      publishedAt:
          data.publishedAt.present ? data.publishedAt.value : this.publishedAt,
      repository:
          data.repository.present ? data.repository.value : this.repository,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      branch: data.branch.present ? data.branch.value : this.branch,
      remoteSha: data.remoteSha.present ? data.remoteSha.value : this.remoteSha,
      publicUrl: data.publicUrl.present ? data.publicUrl.value : this.publicUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundupIssue(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('introduction: $introduction, ')
          ..write('date: $date, ')
          ..write('revision: $revision, ')
          ..write('publishedRevision: $publishedRevision, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('repository: $repository, ')
          ..write('filePath: $filePath, ')
          ..write('branch: $branch, ')
          ..write('remoteSha: $remoteSha, ')
          ..write('publicUrl: $publicUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    introduction,
    date,
    revision,
    publishedRevision,
    publishedAt,
    repository,
    filePath,
    branch,
    remoteSha,
    publicUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundupIssue &&
          other.id == this.id &&
          other.title == this.title &&
          other.introduction == this.introduction &&
          other.date == this.date &&
          other.revision == this.revision &&
          other.publishedRevision == this.publishedRevision &&
          other.publishedAt == this.publishedAt &&
          other.repository == this.repository &&
          other.filePath == this.filePath &&
          other.branch == this.branch &&
          other.remoteSha == this.remoteSha &&
          other.publicUrl == this.publicUrl);
}

class RoundupIssuesCompanion extends UpdateCompanion<RoundupIssue> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> introduction;
  final Value<DateTime> date;
  final Value<int> revision;
  final Value<int?> publishedRevision;
  final Value<DateTime?> publishedAt;
  final Value<String?> repository;
  final Value<String?> filePath;
  final Value<String?> branch;
  final Value<String?> remoteSha;
  final Value<String?> publicUrl;
  final Value<int> rowid;
  const RoundupIssuesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.introduction = const Value.absent(),
    this.date = const Value.absent(),
    this.revision = const Value.absent(),
    this.publishedRevision = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.repository = const Value.absent(),
    this.filePath = const Value.absent(),
    this.branch = const Value.absent(),
    this.remoteSha = const Value.absent(),
    this.publicUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundupIssuesCompanion.insert({
    required String id,
    required String title,
    this.introduction = const Value.absent(),
    required DateTime date,
    this.revision = const Value.absent(),
    this.publishedRevision = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.repository = const Value.absent(),
    this.filePath = const Value.absent(),
    this.branch = const Value.absent(),
    this.remoteSha = const Value.absent(),
    this.publicUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       date = Value(date);
  static Insertable<RoundupIssue> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? introduction,
    Expression<DateTime>? date,
    Expression<int>? revision,
    Expression<int>? publishedRevision,
    Expression<DateTime>? publishedAt,
    Expression<String>? repository,
    Expression<String>? filePath,
    Expression<String>? branch,
    Expression<String>? remoteSha,
    Expression<String>? publicUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (introduction != null) 'introduction': introduction,
      if (date != null) 'date': date,
      if (revision != null) 'revision': revision,
      if (publishedRevision != null) 'published_revision': publishedRevision,
      if (publishedAt != null) 'published_at': publishedAt,
      if (repository != null) 'repository': repository,
      if (filePath != null) 'file_path': filePath,
      if (branch != null) 'branch': branch,
      if (remoteSha != null) 'remote_sha': remoteSha,
      if (publicUrl != null) 'public_url': publicUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundupIssuesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? introduction,
    Value<DateTime>? date,
    Value<int>? revision,
    Value<int?>? publishedRevision,
    Value<DateTime?>? publishedAt,
    Value<String?>? repository,
    Value<String?>? filePath,
    Value<String?>? branch,
    Value<String?>? remoteSha,
    Value<String?>? publicUrl,
    Value<int>? rowid,
  }) {
    return RoundupIssuesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      introduction: introduction ?? this.introduction,
      date: date ?? this.date,
      revision: revision ?? this.revision,
      publishedRevision: publishedRevision ?? this.publishedRevision,
      publishedAt: publishedAt ?? this.publishedAt,
      repository: repository ?? this.repository,
      filePath: filePath ?? this.filePath,
      branch: branch ?? this.branch,
      remoteSha: remoteSha ?? this.remoteSha,
      publicUrl: publicUrl ?? this.publicUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (introduction.present) {
      map['introduction'] = Variable<String>(introduction.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (publishedRevision.present) {
      map['published_revision'] = Variable<int>(publishedRevision.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (repository.present) {
      map['repository'] = Variable<String>(repository.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (remoteSha.present) {
      map['remote_sha'] = Variable<String>(remoteSha.value);
    }
    if (publicUrl.present) {
      map['public_url'] = Variable<String>(publicUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundupIssuesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('introduction: $introduction, ')
          ..write('date: $date, ')
          ..write('revision: $revision, ')
          ..write('publishedRevision: $publishedRevision, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('repository: $repository, ')
          ..write('filePath: $filePath, ')
          ..write('branch: $branch, ')
          ..write('remoteSha: $remoteSha, ')
          ..write('publicUrl: $publicUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundupCardsTable extends RoundupCards
    with TableInfo<$RoundupCardsTable, RoundupCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundupCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<String> issueId = GeneratedColumn<String>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roundup_issues (id)',
    ),
  );
  static const VerificationMeta _bookmarkIdMeta = const VerificationMeta(
    'bookmarkId',
  );
  @override
  late final GeneratedColumn<int> bookmarkId = GeneratedColumn<int>(
    'bookmark_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _discussionUrlMeta = const VerificationMeta(
    'discussionUrl',
  );
  @override
  late final GeneratedColumn<String> discussionUrl = GeneratedColumn<String>(
    'discussion_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _excerptMeta = const VerificationMeta(
    'excerpt',
  );
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
    'excerpt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _blurbMeta = const VerificationMeta('blurb');
  @override
  late final GeneratedColumn<String> blurb = GeneratedColumn<String>(
    'blurb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    issueId,
    bookmarkId,
    position,
    type,
    title,
    url,
    discussionUrl,
    excerpt,
    author,
    blurb,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roundup_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoundupCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('bookmark_id')) {
      context.handle(
        _bookmarkIdMeta,
        bookmarkId.isAcceptableOrUnknown(data['bookmark_id']!, _bookmarkIdMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('discussion_url')) {
      context.handle(
        _discussionUrlMeta,
        discussionUrl.isAcceptableOrUnknown(
          data['discussion_url']!,
          _discussionUrlMeta,
        ),
      );
    }
    if (data.containsKey('excerpt')) {
      context.handle(
        _excerptMeta,
        excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('blurb')) {
      context.handle(
        _blurbMeta,
        blurb.isAcceptableOrUnknown(data['blurb']!, _blurbMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoundupCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundupCard(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      issueId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}issue_id'],
          )!,
      bookmarkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmark_id'],
      ),
      position:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      url:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}url'],
          )!,
      discussionUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}discussion_url'],
          )!,
      excerpt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}excerpt'],
          )!,
      author:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}author'],
          )!,
      blurb:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}blurb'],
          )!,
    );
  }

  @override
  $RoundupCardsTable createAlias(String alias) {
    return $RoundupCardsTable(attachedDatabase, alias);
  }
}

class RoundupCard extends DataClass implements Insertable<RoundupCard> {
  final int id;
  final String issueId;
  final int? bookmarkId;
  final int position;
  final String type;
  final String title;
  final String url;
  final String discussionUrl;
  final String excerpt;
  final String author;
  final String blurb;
  const RoundupCard({
    required this.id,
    required this.issueId,
    this.bookmarkId,
    required this.position,
    required this.type,
    required this.title,
    required this.url,
    required this.discussionUrl,
    required this.excerpt,
    required this.author,
    required this.blurb,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['issue_id'] = Variable<String>(issueId);
    if (!nullToAbsent || bookmarkId != null) {
      map['bookmark_id'] = Variable<int>(bookmarkId);
    }
    map['position'] = Variable<int>(position);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['discussion_url'] = Variable<String>(discussionUrl);
    map['excerpt'] = Variable<String>(excerpt);
    map['author'] = Variable<String>(author);
    map['blurb'] = Variable<String>(blurb);
    return map;
  }

  RoundupCardsCompanion toCompanion(bool nullToAbsent) {
    return RoundupCardsCompanion(
      id: Value(id),
      issueId: Value(issueId),
      bookmarkId:
          bookmarkId == null && nullToAbsent
              ? const Value.absent()
              : Value(bookmarkId),
      position: Value(position),
      type: Value(type),
      title: Value(title),
      url: Value(url),
      discussionUrl: Value(discussionUrl),
      excerpt: Value(excerpt),
      author: Value(author),
      blurb: Value(blurb),
    );
  }

  factory RoundupCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundupCard(
      id: serializer.fromJson<int>(json['id']),
      issueId: serializer.fromJson<String>(json['issueId']),
      bookmarkId: serializer.fromJson<int?>(json['bookmarkId']),
      position: serializer.fromJson<int>(json['position']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      discussionUrl: serializer.fromJson<String>(json['discussionUrl']),
      excerpt: serializer.fromJson<String>(json['excerpt']),
      author: serializer.fromJson<String>(json['author']),
      blurb: serializer.fromJson<String>(json['blurb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'issueId': serializer.toJson<String>(issueId),
      'bookmarkId': serializer.toJson<int?>(bookmarkId),
      'position': serializer.toJson<int>(position),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'discussionUrl': serializer.toJson<String>(discussionUrl),
      'excerpt': serializer.toJson<String>(excerpt),
      'author': serializer.toJson<String>(author),
      'blurb': serializer.toJson<String>(blurb),
    };
  }

  RoundupCard copyWith({
    int? id,
    String? issueId,
    Value<int?> bookmarkId = const Value.absent(),
    int? position,
    String? type,
    String? title,
    String? url,
    String? discussionUrl,
    String? excerpt,
    String? author,
    String? blurb,
  }) => RoundupCard(
    id: id ?? this.id,
    issueId: issueId ?? this.issueId,
    bookmarkId: bookmarkId.present ? bookmarkId.value : this.bookmarkId,
    position: position ?? this.position,
    type: type ?? this.type,
    title: title ?? this.title,
    url: url ?? this.url,
    discussionUrl: discussionUrl ?? this.discussionUrl,
    excerpt: excerpt ?? this.excerpt,
    author: author ?? this.author,
    blurb: blurb ?? this.blurb,
  );
  RoundupCard copyWithCompanion(RoundupCardsCompanion data) {
    return RoundupCard(
      id: data.id.present ? data.id.value : this.id,
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      bookmarkId:
          data.bookmarkId.present ? data.bookmarkId.value : this.bookmarkId,
      position: data.position.present ? data.position.value : this.position,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      discussionUrl:
          data.discussionUrl.present
              ? data.discussionUrl.value
              : this.discussionUrl,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      author: data.author.present ? data.author.value : this.author,
      blurb: data.blurb.present ? data.blurb.value : this.blurb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundupCard(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('bookmarkId: $bookmarkId, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('discussionUrl: $discussionUrl, ')
          ..write('excerpt: $excerpt, ')
          ..write('author: $author, ')
          ..write('blurb: $blurb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    issueId,
    bookmarkId,
    position,
    type,
    title,
    url,
    discussionUrl,
    excerpt,
    author,
    blurb,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundupCard &&
          other.id == this.id &&
          other.issueId == this.issueId &&
          other.bookmarkId == this.bookmarkId &&
          other.position == this.position &&
          other.type == this.type &&
          other.title == this.title &&
          other.url == this.url &&
          other.discussionUrl == this.discussionUrl &&
          other.excerpt == this.excerpt &&
          other.author == this.author &&
          other.blurb == this.blurb);
}

class RoundupCardsCompanion extends UpdateCompanion<RoundupCard> {
  final Value<int> id;
  final Value<String> issueId;
  final Value<int?> bookmarkId;
  final Value<int> position;
  final Value<String> type;
  final Value<String> title;
  final Value<String> url;
  final Value<String> discussionUrl;
  final Value<String> excerpt;
  final Value<String> author;
  final Value<String> blurb;
  const RoundupCardsCompanion({
    this.id = const Value.absent(),
    this.issueId = const Value.absent(),
    this.bookmarkId = const Value.absent(),
    this.position = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.discussionUrl = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.author = const Value.absent(),
    this.blurb = const Value.absent(),
  });
  RoundupCardsCompanion.insert({
    this.id = const Value.absent(),
    required String issueId,
    this.bookmarkId = const Value.absent(),
    required int position,
    required String type,
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.discussionUrl = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.author = const Value.absent(),
    this.blurb = const Value.absent(),
  }) : issueId = Value(issueId),
       position = Value(position),
       type = Value(type);
  static Insertable<RoundupCard> custom({
    Expression<int>? id,
    Expression<String>? issueId,
    Expression<int>? bookmarkId,
    Expression<int>? position,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? discussionUrl,
    Expression<String>? excerpt,
    Expression<String>? author,
    Expression<String>? blurb,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (issueId != null) 'issue_id': issueId,
      if (bookmarkId != null) 'bookmark_id': bookmarkId,
      if (position != null) 'position': position,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (discussionUrl != null) 'discussion_url': discussionUrl,
      if (excerpt != null) 'excerpt': excerpt,
      if (author != null) 'author': author,
      if (blurb != null) 'blurb': blurb,
    });
  }

  RoundupCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? issueId,
    Value<int?>? bookmarkId,
    Value<int>? position,
    Value<String>? type,
    Value<String>? title,
    Value<String>? url,
    Value<String>? discussionUrl,
    Value<String>? excerpt,
    Value<String>? author,
    Value<String>? blurb,
  }) {
    return RoundupCardsCompanion(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      bookmarkId: bookmarkId ?? this.bookmarkId,
      position: position ?? this.position,
      type: type ?? this.type,
      title: title ?? this.title,
      url: url ?? this.url,
      discussionUrl: discussionUrl ?? this.discussionUrl,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      blurb: blurb ?? this.blurb,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (issueId.present) {
      map['issue_id'] = Variable<String>(issueId.value);
    }
    if (bookmarkId.present) {
      map['bookmark_id'] = Variable<int>(bookmarkId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (discussionUrl.present) {
      map['discussion_url'] = Variable<String>(discussionUrl.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (blurb.present) {
      map['blurb'] = Variable<String>(blurb.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundupCardsCompanion(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('bookmarkId: $bookmarkId, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('discussionUrl: $discussionUrl, ')
          ..write('excerpt: $excerpt, ')
          ..write('author: $author, ')
          ..write('blurb: $blurb')
          ..write(')'))
        .toString();
  }
}

class $CommentExportsTable extends CommentExports
    with TableInfo<$CommentExportsTable, CommentExport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<int> storyId = GeneratedColumn<int>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _rootLimitMeta = const VerificationMeta(
    'rootLimit',
  );
  @override
  late final GeneratedColumn<int> rootLimit = GeneratedColumn<int>(
    'root_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonContentMeta = const VerificationMeta(
    'jsonContent',
  );
  @override
  late final GeneratedColumn<String> jsonContent = GeneratedColumn<String>(
    'json_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storyId,
    title,
    depth,
    rootLimit,
    status,
    error,
    jsonContent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comment_exports';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentExport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
    }
    if (data.containsKey('root_limit')) {
      context.handle(
        _rootLimitMeta,
        rootLimit.isAcceptableOrUnknown(data['root_limit']!, _rootLimitMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('json_content')) {
      context.handle(
        _jsonContentMeta,
        jsonContent.isAcceptableOrUnknown(
          data['json_content']!,
          _jsonContentMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentExport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentExport(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      storyId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}story_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      depth:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}depth'],
          )!,
      rootLimit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}root_limit'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      jsonContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_content'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $CommentExportsTable createAlias(String alias) {
    return $CommentExportsTable(attachedDatabase, alias);
  }
}

class CommentExport extends DataClass implements Insertable<CommentExport> {
  final String id;
  final int storyId;
  final String title;
  final int depth;
  final int rootLimit;
  final String status;
  final String? error;
  final String? jsonContent;
  final DateTime createdAt;
  const CommentExport({
    required this.id,
    required this.storyId,
    required this.title,
    required this.depth,
    required this.rootLimit,
    required this.status,
    this.error,
    this.jsonContent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['story_id'] = Variable<int>(storyId);
    map['title'] = Variable<String>(title);
    map['depth'] = Variable<int>(depth);
    map['root_limit'] = Variable<int>(rootLimit);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || jsonContent != null) {
      map['json_content'] = Variable<String>(jsonContent);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommentExportsCompanion toCompanion(bool nullToAbsent) {
    return CommentExportsCompanion(
      id: Value(id),
      storyId: Value(storyId),
      title: Value(title),
      depth: Value(depth),
      rootLimit: Value(rootLimit),
      status: Value(status),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      jsonContent:
          jsonContent == null && nullToAbsent
              ? const Value.absent()
              : Value(jsonContent),
      createdAt: Value(createdAt),
    );
  }

  factory CommentExport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentExport(
      id: serializer.fromJson<String>(json['id']),
      storyId: serializer.fromJson<int>(json['storyId']),
      title: serializer.fromJson<String>(json['title']),
      depth: serializer.fromJson<int>(json['depth']),
      rootLimit: serializer.fromJson<int>(json['rootLimit']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      jsonContent: serializer.fromJson<String?>(json['jsonContent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storyId': serializer.toJson<int>(storyId),
      'title': serializer.toJson<String>(title),
      'depth': serializer.toJson<int>(depth),
      'rootLimit': serializer.toJson<int>(rootLimit),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'jsonContent': serializer.toJson<String?>(jsonContent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CommentExport copyWith({
    String? id,
    int? storyId,
    String? title,
    int? depth,
    int? rootLimit,
    String? status,
    Value<String?> error = const Value.absent(),
    Value<String?> jsonContent = const Value.absent(),
    DateTime? createdAt,
  }) => CommentExport(
    id: id ?? this.id,
    storyId: storyId ?? this.storyId,
    title: title ?? this.title,
    depth: depth ?? this.depth,
    rootLimit: rootLimit ?? this.rootLimit,
    status: status ?? this.status,
    error: error.present ? error.value : this.error,
    jsonContent: jsonContent.present ? jsonContent.value : this.jsonContent,
    createdAt: createdAt ?? this.createdAt,
  );
  CommentExport copyWithCompanion(CommentExportsCompanion data) {
    return CommentExport(
      id: data.id.present ? data.id.value : this.id,
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      title: data.title.present ? data.title.value : this.title,
      depth: data.depth.present ? data.depth.value : this.depth,
      rootLimit: data.rootLimit.present ? data.rootLimit.value : this.rootLimit,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      jsonContent:
          data.jsonContent.present ? data.jsonContent.value : this.jsonContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentExport(')
          ..write('id: $id, ')
          ..write('storyId: $storyId, ')
          ..write('title: $title, ')
          ..write('depth: $depth, ')
          ..write('rootLimit: $rootLimit, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('jsonContent: $jsonContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storyId,
    title,
    depth,
    rootLimit,
    status,
    error,
    jsonContent,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentExport &&
          other.id == this.id &&
          other.storyId == this.storyId &&
          other.title == this.title &&
          other.depth == this.depth &&
          other.rootLimit == this.rootLimit &&
          other.status == this.status &&
          other.error == this.error &&
          other.jsonContent == this.jsonContent &&
          other.createdAt == this.createdAt);
}

class CommentExportsCompanion extends UpdateCompanion<CommentExport> {
  final Value<String> id;
  final Value<int> storyId;
  final Value<String> title;
  final Value<int> depth;
  final Value<int> rootLimit;
  final Value<String> status;
  final Value<String?> error;
  final Value<String?> jsonContent;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CommentExportsCompanion({
    this.id = const Value.absent(),
    this.storyId = const Value.absent(),
    this.title = const Value.absent(),
    this.depth = const Value.absent(),
    this.rootLimit = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.jsonContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentExportsCompanion.insert({
    required String id,
    required int storyId,
    required String title,
    this.depth = const Value.absent(),
    this.rootLimit = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.jsonContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storyId = Value(storyId),
       title = Value(title);
  static Insertable<CommentExport> custom({
    Expression<String>? id,
    Expression<int>? storyId,
    Expression<String>? title,
    Expression<int>? depth,
    Expression<int>? rootLimit,
    Expression<String>? status,
    Expression<String>? error,
    Expression<String>? jsonContent,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storyId != null) 'story_id': storyId,
      if (title != null) 'title': title,
      if (depth != null) 'depth': depth,
      if (rootLimit != null) 'root_limit': rootLimit,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (jsonContent != null) 'json_content': jsonContent,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentExportsCompanion copyWith({
    Value<String>? id,
    Value<int>? storyId,
    Value<String>? title,
    Value<int>? depth,
    Value<int>? rootLimit,
    Value<String>? status,
    Value<String?>? error,
    Value<String?>? jsonContent,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CommentExportsCompanion(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      depth: depth ?? this.depth,
      rootLimit: rootLimit ?? this.rootLimit,
      status: status ?? this.status,
      error: error ?? this.error,
      jsonContent: jsonContent ?? this.jsonContent,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storyId.present) {
      map['story_id'] = Variable<int>(storyId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (rootLimit.present) {
      map['root_limit'] = Variable<int>(rootLimit.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (jsonContent.present) {
      map['json_content'] = Variable<String>(jsonContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentExportsCompanion(')
          ..write('id: $id, ')
          ..write('storyId: $storyId, ')
          ..write('title: $title, ')
          ..write('depth: $depth, ')
          ..write('rootLimit: $rootLimit, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('jsonContent: $jsonContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarksTableTable bookmarksTable = $BookmarksTableTable(this);
  late final $RoundupIssuesTable roundupIssues = $RoundupIssuesTable(this);
  late final $RoundupCardsTable roundupCards = $RoundupCardsTable(this);
  late final $CommentExportsTable commentExports = $CommentExportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarksTable,
    roundupIssues,
    roundupCards,
    commentExports,
  ];
}

typedef $$BookmarksTableTableCreateCompanionBuilder =
    BookmarksTableCompanion Function({
      Value<int> id,
      required String type,
      Value<String?> title,
      Value<String?> contentText,
      Value<String?> contentUrl,
      Value<String?> hnUrl,
      Value<int?> hnItemId,
      Value<String?> author,
      Value<String?> summary,
      Value<String?> domain,
      Value<bool> isPublished,
      Value<String?> publishedWeek,
      Value<DateTime> createdAt,
      Value<bool> archived,
      Value<String?> canonicalKey,
    });
typedef $$BookmarksTableTableUpdateCompanionBuilder =
    BookmarksTableCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String?> title,
      Value<String?> contentText,
      Value<String?> contentUrl,
      Value<String?> hnUrl,
      Value<int?> hnItemId,
      Value<String?> author,
      Value<String?> summary,
      Value<String?> domain,
      Value<bool> isPublished,
      Value<String?> publishedWeek,
      Value<DateTime> createdAt,
      Value<bool> archived,
      Value<String?> canonicalKey,
    });

class $$BookmarksTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hnUrl => $composableBuilder(
    column: $table.hnUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hnItemId => $composableBuilder(
    column: $table.hnItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedWeek => $composableBuilder(
    column: $table.publishedWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hnUrl => $composableBuilder(
    column: $table.hnUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hnItemId => $composableBuilder(
    column: $table.hnItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedWeek => $composableBuilder(
    column: $table.publishedWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hnUrl =>
      $composableBuilder(column: $table.hnUrl, builder: (column) => column);

  GeneratedColumn<int> get hnItemId =>
      $composableBuilder(column: $table.hnItemId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publishedWeek => $composableBuilder(
    column: $table.publishedWeek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => column,
  );
}

class $$BookmarksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTableTable,
          BookmarksTableData,
          $$BookmarksTableTableFilterComposer,
          $$BookmarksTableTableOrderingComposer,
          $$BookmarksTableTableAnnotationComposer,
          $$BookmarksTableTableCreateCompanionBuilder,
          $$BookmarksTableTableUpdateCompanionBuilder,
          (
            BookmarksTableData,
            BaseReferences<
              _$AppDatabase,
              $BookmarksTableTable,
              BookmarksTableData
            >,
          ),
          BookmarksTableData,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableTableManager(
    _$AppDatabase db,
    $BookmarksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BookmarksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$BookmarksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BookmarksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> contentText = const Value.absent(),
                Value<String?> contentUrl = const Value.absent(),
                Value<String?> hnUrl = const Value.absent(),
                Value<int?> hnItemId = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> domain = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<String?> publishedWeek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> canonicalKey = const Value.absent(),
              }) => BookmarksTableCompanion(
                id: id,
                type: type,
                title: title,
                contentText: contentText,
                contentUrl: contentUrl,
                hnUrl: hnUrl,
                hnItemId: hnItemId,
                author: author,
                summary: summary,
                domain: domain,
                isPublished: isPublished,
                publishedWeek: publishedWeek,
                createdAt: createdAt,
                archived: archived,
                canonicalKey: canonicalKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<String?> title = const Value.absent(),
                Value<String?> contentText = const Value.absent(),
                Value<String?> contentUrl = const Value.absent(),
                Value<String?> hnUrl = const Value.absent(),
                Value<int?> hnItemId = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> domain = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<String?> publishedWeek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> canonicalKey = const Value.absent(),
              }) => BookmarksTableCompanion.insert(
                id: id,
                type: type,
                title: title,
                contentText: contentText,
                contentUrl: contentUrl,
                hnUrl: hnUrl,
                hnItemId: hnItemId,
                author: author,
                summary: summary,
                domain: domain,
                isPublished: isPublished,
                publishedWeek: publishedWeek,
                createdAt: createdAt,
                archived: archived,
                canonicalKey: canonicalKey,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTableTable,
      BookmarksTableData,
      $$BookmarksTableTableFilterComposer,
      $$BookmarksTableTableOrderingComposer,
      $$BookmarksTableTableAnnotationComposer,
      $$BookmarksTableTableCreateCompanionBuilder,
      $$BookmarksTableTableUpdateCompanionBuilder,
      (
        BookmarksTableData,
        BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarksTableData>,
      ),
      BookmarksTableData,
      PrefetchHooks Function()
    >;
typedef $$RoundupIssuesTableCreateCompanionBuilder =
    RoundupIssuesCompanion Function({
      required String id,
      required String title,
      Value<String> introduction,
      required DateTime date,
      Value<int> revision,
      Value<int?> publishedRevision,
      Value<DateTime?> publishedAt,
      Value<String?> repository,
      Value<String?> filePath,
      Value<String?> branch,
      Value<String?> remoteSha,
      Value<String?> publicUrl,
      Value<int> rowid,
    });
typedef $$RoundupIssuesTableUpdateCompanionBuilder =
    RoundupIssuesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> introduction,
      Value<DateTime> date,
      Value<int> revision,
      Value<int?> publishedRevision,
      Value<DateTime?> publishedAt,
      Value<String?> repository,
      Value<String?> filePath,
      Value<String?> branch,
      Value<String?> remoteSha,
      Value<String?> publicUrl,
      Value<int> rowid,
    });

final class $$RoundupIssuesTableReferences
    extends BaseReferences<_$AppDatabase, $RoundupIssuesTable, RoundupIssue> {
  $$RoundupIssuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RoundupCardsTable, List<RoundupCard>>
  _roundupCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.roundupCards,
    aliasName: $_aliasNameGenerator(
      db.roundupIssues.id,
      db.roundupCards.issueId,
    ),
  );

  $$RoundupCardsTableProcessedTableManager get roundupCardsRefs {
    final manager = $$RoundupCardsTableTableManager(
      $_db,
      $_db.roundupCards,
    ).filter((f) => f.issueId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundupCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoundupIssuesTableFilterComposer
    extends Composer<_$AppDatabase, $RoundupIssuesTable> {
  $$RoundupIssuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get introduction => $composableBuilder(
    column: $table.introduction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishedRevision => $composableBuilder(
    column: $table.publishedRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repository => $composableBuilder(
    column: $table.repository,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteSha => $composableBuilder(
    column: $table.remoteSha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicUrl => $composableBuilder(
    column: $table.publicUrl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roundupCardsRefs(
    Expression<bool> Function($$RoundupCardsTableFilterComposer f) f,
  ) {
    final $$RoundupCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roundupCards,
      getReferencedColumn: (t) => t.issueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundupCardsTableFilterComposer(
            $db: $db,
            $table: $db.roundupCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundupIssuesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundupIssuesTable> {
  $$RoundupIssuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introduction => $composableBuilder(
    column: $table.introduction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishedRevision => $composableBuilder(
    column: $table.publishedRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repository => $composableBuilder(
    column: $table.repository,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteSha => $composableBuilder(
    column: $table.remoteSha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicUrl => $composableBuilder(
    column: $table.publicUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoundupIssuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundupIssuesTable> {
  $$RoundupIssuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get introduction => $composableBuilder(
    column: $table.introduction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get publishedRevision => $composableBuilder(
    column: $table.publishedRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repository => $composableBuilder(
    column: $table.repository,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<String> get remoteSha =>
      $composableBuilder(column: $table.remoteSha, builder: (column) => column);

  GeneratedColumn<String> get publicUrl =>
      $composableBuilder(column: $table.publicUrl, builder: (column) => column);

  Expression<T> roundupCardsRefs<T extends Object>(
    Expression<T> Function($$RoundupCardsTableAnnotationComposer a) f,
  ) {
    final $$RoundupCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roundupCards,
      getReferencedColumn: (t) => t.issueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundupCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.roundupCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundupIssuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoundupIssuesTable,
          RoundupIssue,
          $$RoundupIssuesTableFilterComposer,
          $$RoundupIssuesTableOrderingComposer,
          $$RoundupIssuesTableAnnotationComposer,
          $$RoundupIssuesTableCreateCompanionBuilder,
          $$RoundupIssuesTableUpdateCompanionBuilder,
          (RoundupIssue, $$RoundupIssuesTableReferences),
          RoundupIssue,
          PrefetchHooks Function({bool roundupCardsRefs})
        > {
  $$RoundupIssuesTableTableManager(_$AppDatabase db, $RoundupIssuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RoundupIssuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$RoundupIssuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RoundupIssuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> introduction = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> publishedRevision = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> repository = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> branch = const Value.absent(),
                Value<String?> remoteSha = const Value.absent(),
                Value<String?> publicUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundupIssuesCompanion(
                id: id,
                title: title,
                introduction: introduction,
                date: date,
                revision: revision,
                publishedRevision: publishedRevision,
                publishedAt: publishedAt,
                repository: repository,
                filePath: filePath,
                branch: branch,
                remoteSha: remoteSha,
                publicUrl: publicUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> introduction = const Value.absent(),
                required DateTime date,
                Value<int> revision = const Value.absent(),
                Value<int?> publishedRevision = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> repository = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> branch = const Value.absent(),
                Value<String?> remoteSha = const Value.absent(),
                Value<String?> publicUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundupIssuesCompanion.insert(
                id: id,
                title: title,
                introduction: introduction,
                date: date,
                revision: revision,
                publishedRevision: publishedRevision,
                publishedAt: publishedAt,
                repository: repository,
                filePath: filePath,
                branch: branch,
                remoteSha: remoteSha,
                publicUrl: publicUrl,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RoundupIssuesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({roundupCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roundupCardsRefs) db.roundupCards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roundupCardsRefs)
                    await $_getPrefetchedData<
                      RoundupIssue,
                      $RoundupIssuesTable,
                      RoundupCard
                    >(
                      currentTable: table,
                      referencedTable: $$RoundupIssuesTableReferences
                          ._roundupCardsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$RoundupIssuesTableReferences(
                                db,
                                table,
                                p0,
                              ).roundupCardsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.issueId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoundupIssuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoundupIssuesTable,
      RoundupIssue,
      $$RoundupIssuesTableFilterComposer,
      $$RoundupIssuesTableOrderingComposer,
      $$RoundupIssuesTableAnnotationComposer,
      $$RoundupIssuesTableCreateCompanionBuilder,
      $$RoundupIssuesTableUpdateCompanionBuilder,
      (RoundupIssue, $$RoundupIssuesTableReferences),
      RoundupIssue,
      PrefetchHooks Function({bool roundupCardsRefs})
    >;
typedef $$RoundupCardsTableCreateCompanionBuilder =
    RoundupCardsCompanion Function({
      Value<int> id,
      required String issueId,
      Value<int?> bookmarkId,
      required int position,
      required String type,
      Value<String> title,
      Value<String> url,
      Value<String> discussionUrl,
      Value<String> excerpt,
      Value<String> author,
      Value<String> blurb,
    });
typedef $$RoundupCardsTableUpdateCompanionBuilder =
    RoundupCardsCompanion Function({
      Value<int> id,
      Value<String> issueId,
      Value<int?> bookmarkId,
      Value<int> position,
      Value<String> type,
      Value<String> title,
      Value<String> url,
      Value<String> discussionUrl,
      Value<String> excerpt,
      Value<String> author,
      Value<String> blurb,
    });

final class $$RoundupCardsTableReferences
    extends BaseReferences<_$AppDatabase, $RoundupCardsTable, RoundupCard> {
  $$RoundupCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoundupIssuesTable _issueIdTable(_$AppDatabase db) =>
      db.roundupIssues.createAlias(
        $_aliasNameGenerator(db.roundupCards.issueId, db.roundupIssues.id),
      );

  $$RoundupIssuesTableProcessedTableManager get issueId {
    final $_column = $_itemColumn<String>('issue_id')!;

    final manager = $$RoundupIssuesTableTableManager(
      $_db,
      $_db.roundupIssues,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_issueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoundupCardsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundupCardsTable> {
  $$RoundupCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookmarkId => $composableBuilder(
    column: $table.bookmarkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discussionUrl => $composableBuilder(
    column: $table.discussionUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blurb => $composableBuilder(
    column: $table.blurb,
    builder: (column) => ColumnFilters(column),
  );

  $$RoundupIssuesTableFilterComposer get issueId {
    final $$RoundupIssuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.issueId,
      referencedTable: $db.roundupIssues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundupIssuesTableFilterComposer(
            $db: $db,
            $table: $db.roundupIssues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundupCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundupCardsTable> {
  $$RoundupCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookmarkId => $composableBuilder(
    column: $table.bookmarkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discussionUrl => $composableBuilder(
    column: $table.discussionUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blurb => $composableBuilder(
    column: $table.blurb,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoundupIssuesTableOrderingComposer get issueId {
    final $$RoundupIssuesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.issueId,
      referencedTable: $db.roundupIssues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundupIssuesTableOrderingComposer(
            $db: $db,
            $table: $db.roundupIssues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundupCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundupCardsTable> {
  $$RoundupCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookmarkId => $composableBuilder(
    column: $table.bookmarkId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get discussionUrl => $composableBuilder(
    column: $table.discussionUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get blurb =>
      $composableBuilder(column: $table.blurb, builder: (column) => column);

  $$RoundupIssuesTableAnnotationComposer get issueId {
    final $$RoundupIssuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.issueId,
      referencedTable: $db.roundupIssues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundupIssuesTableAnnotationComposer(
            $db: $db,
            $table: $db.roundupIssues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundupCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoundupCardsTable,
          RoundupCard,
          $$RoundupCardsTableFilterComposer,
          $$RoundupCardsTableOrderingComposer,
          $$RoundupCardsTableAnnotationComposer,
          $$RoundupCardsTableCreateCompanionBuilder,
          $$RoundupCardsTableUpdateCompanionBuilder,
          (RoundupCard, $$RoundupCardsTableReferences),
          RoundupCard,
          PrefetchHooks Function({bool issueId})
        > {
  $$RoundupCardsTableTableManager(_$AppDatabase db, $RoundupCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RoundupCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RoundupCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$RoundupCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> issueId = const Value.absent(),
                Value<int?> bookmarkId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> discussionUrl = const Value.absent(),
                Value<String> excerpt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> blurb = const Value.absent(),
              }) => RoundupCardsCompanion(
                id: id,
                issueId: issueId,
                bookmarkId: bookmarkId,
                position: position,
                type: type,
                title: title,
                url: url,
                discussionUrl: discussionUrl,
                excerpt: excerpt,
                author: author,
                blurb: blurb,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String issueId,
                Value<int?> bookmarkId = const Value.absent(),
                required int position,
                required String type,
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> discussionUrl = const Value.absent(),
                Value<String> excerpt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> blurb = const Value.absent(),
              }) => RoundupCardsCompanion.insert(
                id: id,
                issueId: issueId,
                bookmarkId: bookmarkId,
                position: position,
                type: type,
                title: title,
                url: url,
                discussionUrl: discussionUrl,
                excerpt: excerpt,
                author: author,
                blurb: blurb,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RoundupCardsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({issueId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (issueId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.issueId,
                            referencedTable: $$RoundupCardsTableReferences
                                ._issueIdTable(db),
                            referencedColumn:
                                $$RoundupCardsTableReferences
                                    ._issueIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoundupCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoundupCardsTable,
      RoundupCard,
      $$RoundupCardsTableFilterComposer,
      $$RoundupCardsTableOrderingComposer,
      $$RoundupCardsTableAnnotationComposer,
      $$RoundupCardsTableCreateCompanionBuilder,
      $$RoundupCardsTableUpdateCompanionBuilder,
      (RoundupCard, $$RoundupCardsTableReferences),
      RoundupCard,
      PrefetchHooks Function({bool issueId})
    >;
typedef $$CommentExportsTableCreateCompanionBuilder =
    CommentExportsCompanion Function({
      required String id,
      required int storyId,
      required String title,
      Value<int> depth,
      Value<int> rootLimit,
      Value<String> status,
      Value<String?> error,
      Value<String?> jsonContent,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CommentExportsTableUpdateCompanionBuilder =
    CommentExportsCompanion Function({
      Value<String> id,
      Value<int> storyId,
      Value<String> title,
      Value<int> depth,
      Value<int> rootLimit,
      Value<String> status,
      Value<String?> error,
      Value<String?> jsonContent,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CommentExportsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentExportsTable> {
  $$CommentExportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rootLimit => $composableBuilder(
    column: $table.rootLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonContent => $composableBuilder(
    column: $table.jsonContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommentExportsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentExportsTable> {
  $$CommentExportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rootLimit => $composableBuilder(
    column: $table.rootLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonContent => $composableBuilder(
    column: $table.jsonContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommentExportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentExportsTable> {
  $$CommentExportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<int> get rootLimit =>
      $composableBuilder(column: $table.rootLimit, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get jsonContent => $composableBuilder(
    column: $table.jsonContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CommentExportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentExportsTable,
          CommentExport,
          $$CommentExportsTableFilterComposer,
          $$CommentExportsTableOrderingComposer,
          $$CommentExportsTableAnnotationComposer,
          $$CommentExportsTableCreateCompanionBuilder,
          $$CommentExportsTableUpdateCompanionBuilder,
          (
            CommentExport,
            BaseReferences<_$AppDatabase, $CommentExportsTable, CommentExport>,
          ),
          CommentExport,
          PrefetchHooks Function()
        > {
  $$CommentExportsTableTableManager(
    _$AppDatabase db,
    $CommentExportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CommentExportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CommentExportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CommentExportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> storyId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> depth = const Value.absent(),
                Value<int> rootLimit = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> jsonContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentExportsCompanion(
                id: id,
                storyId: storyId,
                title: title,
                depth: depth,
                rootLimit: rootLimit,
                status: status,
                error: error,
                jsonContent: jsonContent,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int storyId,
                required String title,
                Value<int> depth = const Value.absent(),
                Value<int> rootLimit = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> jsonContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentExportsCompanion.insert(
                id: id,
                storyId: storyId,
                title: title,
                depth: depth,
                rootLimit: rootLimit,
                status: status,
                error: error,
                jsonContent: jsonContent,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommentExportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentExportsTable,
      CommentExport,
      $$CommentExportsTableFilterComposer,
      $$CommentExportsTableOrderingComposer,
      $$CommentExportsTableAnnotationComposer,
      $$CommentExportsTableCreateCompanionBuilder,
      $$CommentExportsTableUpdateCompanionBuilder,
      (
        CommentExport,
        BaseReferences<_$AppDatabase, $CommentExportsTable, CommentExport>,
      ),
      CommentExport,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(_db, _db.bookmarksTable);
  $$RoundupIssuesTableTableManager get roundupIssues =>
      $$RoundupIssuesTableTableManager(_db, _db.roundupIssues);
  $$RoundupCardsTableTableManager get roundupCards =>
      $$RoundupCardsTableTableManager(_db, _db.roundupCards);
  $$CommentExportsTableTableManager get commentExports =>
      $$CommentExportsTableTableManager(_db, _db.commentExports);
}
