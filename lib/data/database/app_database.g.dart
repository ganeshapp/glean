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
          ..write('createdAt: $createdAt')
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
          other.createdAt == this.createdAt);
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarksTableTable bookmarksTable = $BookmarksTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [bookmarksTable];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(_db, _db.bookmarksTable);
}
