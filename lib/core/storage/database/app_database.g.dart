// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookUrlMeta = const VerificationMeta(
    'bookUrl',
  );
  @override
  late final GeneratedColumn<String> bookUrl = GeneratedColumn<String>(
    'book_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tocUrlMeta = const VerificationMeta('tocUrl');
  @override
  late final GeneratedColumn<String> tocUrl = GeneratedColumn<String>(
    'toc_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _originNameMeta = const VerificationMeta(
    'originName',
  );
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
    'origin_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
    'intro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalChapterNumMeta = const VerificationMeta(
    'totalChapterNum',
  );
  @override
  late final GeneratedColumn<int> totalChapterNum = GeneratedColumn<int>(
    'total_chapter_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durChapterIndexMeta = const VerificationMeta(
    'durChapterIndex',
  );
  @override
  late final GeneratedColumn<int> durChapterIndex = GeneratedColumn<int>(
    'dur_chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durChapterPosMeta = const VerificationMeta(
    'durChapterPos',
  );
  @override
  late final GeneratedColumn<int> durChapterPos = GeneratedColumn<int>(
    'dur_chapter_pos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durChapterTimeMeta = const VerificationMeta(
    'durChapterTime',
  );
  @override
  late final GeneratedColumn<int> durChapterTime = GeneratedColumn<int>(
    'dur_chapter_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCheckTimeMeta = const VerificationMeta(
    'lastCheckTime',
  );
  @override
  late final GeneratedColumn<int> lastCheckTime = GeneratedColumn<int>(
    'last_check_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookUrl,
    tocUrl,
    origin,
    originName,
    name,
    author,
    coverUrl,
    intro,
    totalChapterNum,
    durChapterIndex,
    durChapterPos,
    durChapterTime,
    lastCheckTime,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_url')) {
      context.handle(
        _bookUrlMeta,
        bookUrl.isAcceptableOrUnknown(data['book_url']!, _bookUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_bookUrlMeta);
    }
    if (data.containsKey('toc_url')) {
      context.handle(
        _tocUrlMeta,
        tocUrl.isAcceptableOrUnknown(data['toc_url']!, _tocUrlMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('origin_name')) {
      context.handle(
        _originNameMeta,
        originName.isAcceptableOrUnknown(data['origin_name']!, _originNameMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('intro')) {
      context.handle(
        _introMeta,
        intro.isAcceptableOrUnknown(data['intro']!, _introMeta),
      );
    }
    if (data.containsKey('total_chapter_num')) {
      context.handle(
        _totalChapterNumMeta,
        totalChapterNum.isAcceptableOrUnknown(
          data['total_chapter_num']!,
          _totalChapterNumMeta,
        ),
      );
    }
    if (data.containsKey('dur_chapter_index')) {
      context.handle(
        _durChapterIndexMeta,
        durChapterIndex.isAcceptableOrUnknown(
          data['dur_chapter_index']!,
          _durChapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('dur_chapter_pos')) {
      context.handle(
        _durChapterPosMeta,
        durChapterPos.isAcceptableOrUnknown(
          data['dur_chapter_pos']!,
          _durChapterPosMeta,
        ),
      );
    }
    if (data.containsKey('dur_chapter_time')) {
      context.handle(
        _durChapterTimeMeta,
        durChapterTime.isAcceptableOrUnknown(
          data['dur_chapter_time']!,
          _durChapterTimeMeta,
        ),
      );
    }
    if (data.containsKey('last_check_time')) {
      context.handle(
        _lastCheckTimeMeta,
        lastCheckTime.isAcceptableOrUnknown(
          data['last_check_time']!,
          _lastCheckTimeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookUrl};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      bookUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_url'],
      )!,
      tocUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toc_url'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      originName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_name'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      intro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intro'],
      ),
      totalChapterNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_chapter_num'],
      )!,
      durChapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dur_chapter_index'],
      )!,
      durChapterPos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dur_chapter_pos'],
      )!,
      durChapterTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dur_chapter_time'],
      )!,
      lastCheckTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_check_time'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final String bookUrl;
  final String tocUrl;
  final String origin;
  final String originName;
  final String name;
  final String author;
  final String? coverUrl;
  final String? intro;
  final int totalChapterNum;
  final int durChapterIndex;
  final int durChapterPos;
  final int durChapterTime;
  final int lastCheckTime;
  final int createdAt;
  final int updatedAt;
  const Book({
    required this.bookUrl,
    required this.tocUrl,
    required this.origin,
    required this.originName,
    required this.name,
    required this.author,
    this.coverUrl,
    this.intro,
    required this.totalChapterNum,
    required this.durChapterIndex,
    required this.durChapterPos,
    required this.durChapterTime,
    required this.lastCheckTime,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_url'] = Variable<String>(bookUrl);
    map['toc_url'] = Variable<String>(tocUrl);
    map['origin'] = Variable<String>(origin);
    map['origin_name'] = Variable<String>(originName);
    map['name'] = Variable<String>(name);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    map['total_chapter_num'] = Variable<int>(totalChapterNum);
    map['dur_chapter_index'] = Variable<int>(durChapterIndex);
    map['dur_chapter_pos'] = Variable<int>(durChapterPos);
    map['dur_chapter_time'] = Variable<int>(durChapterTime);
    map['last_check_time'] = Variable<int>(lastCheckTime);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      bookUrl: Value(bookUrl),
      tocUrl: Value(tocUrl),
      origin: Value(origin),
      originName: Value(originName),
      name: Value(name),
      author: Value(author),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      intro: intro == null && nullToAbsent
          ? const Value.absent()
          : Value(intro),
      totalChapterNum: Value(totalChapterNum),
      durChapterIndex: Value(durChapterIndex),
      durChapterPos: Value(durChapterPos),
      durChapterTime: Value(durChapterTime),
      lastCheckTime: Value(lastCheckTime),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      bookUrl: serializer.fromJson<String>(json['bookUrl']),
      tocUrl: serializer.fromJson<String>(json['tocUrl']),
      origin: serializer.fromJson<String>(json['origin']),
      originName: serializer.fromJson<String>(json['originName']),
      name: serializer.fromJson<String>(json['name']),
      author: serializer.fromJson<String>(json['author']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      intro: serializer.fromJson<String?>(json['intro']),
      totalChapterNum: serializer.fromJson<int>(json['totalChapterNum']),
      durChapterIndex: serializer.fromJson<int>(json['durChapterIndex']),
      durChapterPos: serializer.fromJson<int>(json['durChapterPos']),
      durChapterTime: serializer.fromJson<int>(json['durChapterTime']),
      lastCheckTime: serializer.fromJson<int>(json['lastCheckTime']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookUrl': serializer.toJson<String>(bookUrl),
      'tocUrl': serializer.toJson<String>(tocUrl),
      'origin': serializer.toJson<String>(origin),
      'originName': serializer.toJson<String>(originName),
      'name': serializer.toJson<String>(name),
      'author': serializer.toJson<String>(author),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'intro': serializer.toJson<String?>(intro),
      'totalChapterNum': serializer.toJson<int>(totalChapterNum),
      'durChapterIndex': serializer.toJson<int>(durChapterIndex),
      'durChapterPos': serializer.toJson<int>(durChapterPos),
      'durChapterTime': serializer.toJson<int>(durChapterTime),
      'lastCheckTime': serializer.toJson<int>(lastCheckTime),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Book copyWith({
    String? bookUrl,
    String? tocUrl,
    String? origin,
    String? originName,
    String? name,
    String? author,
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> intro = const Value.absent(),
    int? totalChapterNum,
    int? durChapterIndex,
    int? durChapterPos,
    int? durChapterTime,
    int? lastCheckTime,
    int? createdAt,
    int? updatedAt,
  }) => Book(
    bookUrl: bookUrl ?? this.bookUrl,
    tocUrl: tocUrl ?? this.tocUrl,
    origin: origin ?? this.origin,
    originName: originName ?? this.originName,
    name: name ?? this.name,
    author: author ?? this.author,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    intro: intro.present ? intro.value : this.intro,
    totalChapterNum: totalChapterNum ?? this.totalChapterNum,
    durChapterIndex: durChapterIndex ?? this.durChapterIndex,
    durChapterPos: durChapterPos ?? this.durChapterPos,
    durChapterTime: durChapterTime ?? this.durChapterTime,
    lastCheckTime: lastCheckTime ?? this.lastCheckTime,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      bookUrl: data.bookUrl.present ? data.bookUrl.value : this.bookUrl,
      tocUrl: data.tocUrl.present ? data.tocUrl.value : this.tocUrl,
      origin: data.origin.present ? data.origin.value : this.origin,
      originName: data.originName.present
          ? data.originName.value
          : this.originName,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      intro: data.intro.present ? data.intro.value : this.intro,
      totalChapterNum: data.totalChapterNum.present
          ? data.totalChapterNum.value
          : this.totalChapterNum,
      durChapterIndex: data.durChapterIndex.present
          ? data.durChapterIndex.value
          : this.durChapterIndex,
      durChapterPos: data.durChapterPos.present
          ? data.durChapterPos.value
          : this.durChapterPos,
      durChapterTime: data.durChapterTime.present
          ? data.durChapterTime.value
          : this.durChapterTime,
      lastCheckTime: data.lastCheckTime.present
          ? data.lastCheckTime.value
          : this.lastCheckTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('bookUrl: $bookUrl, ')
          ..write('tocUrl: $tocUrl, ')
          ..write('origin: $origin, ')
          ..write('originName: $originName, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('intro: $intro, ')
          ..write('totalChapterNum: $totalChapterNum, ')
          ..write('durChapterIndex: $durChapterIndex, ')
          ..write('durChapterPos: $durChapterPos, ')
          ..write('durChapterTime: $durChapterTime, ')
          ..write('lastCheckTime: $lastCheckTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookUrl,
    tocUrl,
    origin,
    originName,
    name,
    author,
    coverUrl,
    intro,
    totalChapterNum,
    durChapterIndex,
    durChapterPos,
    durChapterTime,
    lastCheckTime,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.bookUrl == this.bookUrl &&
          other.tocUrl == this.tocUrl &&
          other.origin == this.origin &&
          other.originName == this.originName &&
          other.name == this.name &&
          other.author == this.author &&
          other.coverUrl == this.coverUrl &&
          other.intro == this.intro &&
          other.totalChapterNum == this.totalChapterNum &&
          other.durChapterIndex == this.durChapterIndex &&
          other.durChapterPos == this.durChapterPos &&
          other.durChapterTime == this.durChapterTime &&
          other.lastCheckTime == this.lastCheckTime &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> bookUrl;
  final Value<String> tocUrl;
  final Value<String> origin;
  final Value<String> originName;
  final Value<String> name;
  final Value<String> author;
  final Value<String?> coverUrl;
  final Value<String?> intro;
  final Value<int> totalChapterNum;
  final Value<int> durChapterIndex;
  final Value<int> durChapterPos;
  final Value<int> durChapterTime;
  final Value<int> lastCheckTime;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.bookUrl = const Value.absent(),
    this.tocUrl = const Value.absent(),
    this.origin = const Value.absent(),
    this.originName = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.intro = const Value.absent(),
    this.totalChapterNum = const Value.absent(),
    this.durChapterIndex = const Value.absent(),
    this.durChapterPos = const Value.absent(),
    this.durChapterTime = const Value.absent(),
    this.lastCheckTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String bookUrl,
    this.tocUrl = const Value.absent(),
    this.origin = const Value.absent(),
    this.originName = const Value.absent(),
    required String name,
    this.author = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.intro = const Value.absent(),
    this.totalChapterNum = const Value.absent(),
    this.durChapterIndex = const Value.absent(),
    this.durChapterPos = const Value.absent(),
    this.durChapterTime = const Value.absent(),
    this.lastCheckTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookUrl = Value(bookUrl),
       name = Value(name);
  static Insertable<Book> custom({
    Expression<String>? bookUrl,
    Expression<String>? tocUrl,
    Expression<String>? origin,
    Expression<String>? originName,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? coverUrl,
    Expression<String>? intro,
    Expression<int>? totalChapterNum,
    Expression<int>? durChapterIndex,
    Expression<int>? durChapterPos,
    Expression<int>? durChapterTime,
    Expression<int>? lastCheckTime,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookUrl != null) 'book_url': bookUrl,
      if (tocUrl != null) 'toc_url': tocUrl,
      if (origin != null) 'origin': origin,
      if (originName != null) 'origin_name': originName,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (intro != null) 'intro': intro,
      if (totalChapterNum != null) 'total_chapter_num': totalChapterNum,
      if (durChapterIndex != null) 'dur_chapter_index': durChapterIndex,
      if (durChapterPos != null) 'dur_chapter_pos': durChapterPos,
      if (durChapterTime != null) 'dur_chapter_time': durChapterTime,
      if (lastCheckTime != null) 'last_check_time': lastCheckTime,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? bookUrl,
    Value<String>? tocUrl,
    Value<String>? origin,
    Value<String>? originName,
    Value<String>? name,
    Value<String>? author,
    Value<String?>? coverUrl,
    Value<String?>? intro,
    Value<int>? totalChapterNum,
    Value<int>? durChapterIndex,
    Value<int>? durChapterPos,
    Value<int>? durChapterTime,
    Value<int>? lastCheckTime,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      bookUrl: bookUrl ?? this.bookUrl,
      tocUrl: tocUrl ?? this.tocUrl,
      origin: origin ?? this.origin,
      originName: originName ?? this.originName,
      name: name ?? this.name,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      intro: intro ?? this.intro,
      totalChapterNum: totalChapterNum ?? this.totalChapterNum,
      durChapterIndex: durChapterIndex ?? this.durChapterIndex,
      durChapterPos: durChapterPos ?? this.durChapterPos,
      durChapterTime: durChapterTime ?? this.durChapterTime,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookUrl.present) {
      map['book_url'] = Variable<String>(bookUrl.value);
    }
    if (tocUrl.present) {
      map['toc_url'] = Variable<String>(tocUrl.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (totalChapterNum.present) {
      map['total_chapter_num'] = Variable<int>(totalChapterNum.value);
    }
    if (durChapterIndex.present) {
      map['dur_chapter_index'] = Variable<int>(durChapterIndex.value);
    }
    if (durChapterPos.present) {
      map['dur_chapter_pos'] = Variable<int>(durChapterPos.value);
    }
    if (durChapterTime.present) {
      map['dur_chapter_time'] = Variable<int>(durChapterTime.value);
    }
    if (lastCheckTime.present) {
      map['last_check_time'] = Variable<int>(lastCheckTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('bookUrl: $bookUrl, ')
          ..write('tocUrl: $tocUrl, ')
          ..write('origin: $origin, ')
          ..write('originName: $originName, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('intro: $intro, ')
          ..write('totalChapterNum: $totalChapterNum, ')
          ..write('durChapterIndex: $durChapterIndex, ')
          ..write('durChapterPos: $durChapterPos, ')
          ..write('durChapterTime: $durChapterTime, ')
          ..write('lastCheckTime: $lastCheckTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookSourcesTable extends BookSources
    with TableInfo<$BookSourcesTable, BookSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookSourceUrlMeta = const VerificationMeta(
    'bookSourceUrl',
  );
  @override
  late final GeneratedColumn<String> bookSourceUrl = GeneratedColumn<String>(
    'book_source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookSourceNameMeta = const VerificationMeta(
    'bookSourceName',
  );
  @override
  late final GeneratedColumn<String> bookSourceName = GeneratedColumn<String>(
    'book_source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookSourceGroupMeta = const VerificationMeta(
    'bookSourceGroup',
  );
  @override
  late final GeneratedColumn<String> bookSourceGroup = GeneratedColumn<String>(
    'book_source_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookSourceTypeMeta = const VerificationMeta(
    'bookSourceType',
  );
  @override
  late final GeneratedColumn<int> bookSourceType = GeneratedColumn<int>(
    'book_source_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bookUrlPatternMeta = const VerificationMeta(
    'bookUrlPattern',
  );
  @override
  late final GeneratedColumn<String> bookUrlPattern = GeneratedColumn<String>(
    'book_url_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customOrderMeta = const VerificationMeta(
    'customOrder',
  );
  @override
  late final GeneratedColumn<int> customOrder = GeneratedColumn<int>(
    'custom_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enabledExploreMeta = const VerificationMeta(
    'enabledExplore',
  );
  @override
  late final GeneratedColumn<bool> enabledExplore = GeneratedColumn<bool>(
    'enabled_explore',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled_explore" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _jsLibMeta = const VerificationMeta('jsLib');
  @override
  late final GeneratedColumn<String> jsLib = GeneratedColumn<String>(
    'js_lib',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledCookieJarMeta = const VerificationMeta(
    'enabledCookieJar',
  );
  @override
  late final GeneratedColumn<bool> enabledCookieJar = GeneratedColumn<bool>(
    'enabled_cookie_jar',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled_cookie_jar" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _concurrentRateMeta = const VerificationMeta(
    'concurrentRate',
  );
  @override
  late final GeneratedColumn<String> concurrentRate = GeneratedColumn<String>(
    'concurrent_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headerMeta = const VerificationMeta('header');
  @override
  late final GeneratedColumn<String> header = GeneratedColumn<String>(
    'header',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginUrlMeta = const VerificationMeta(
    'loginUrl',
  );
  @override
  late final GeneratedColumn<String> loginUrl = GeneratedColumn<String>(
    'login_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginUiMeta = const VerificationMeta(
    'loginUi',
  );
  @override
  late final GeneratedColumn<String> loginUi = GeneratedColumn<String>(
    'login_ui',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginCheckJsMeta = const VerificationMeta(
    'loginCheckJs',
  );
  @override
  late final GeneratedColumn<String> loginCheckJs = GeneratedColumn<String>(
    'login_check_js',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverDecodeJsMeta = const VerificationMeta(
    'coverDecodeJs',
  );
  @override
  late final GeneratedColumn<String> coverDecodeJs = GeneratedColumn<String>(
    'cover_decode_js',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookSourceCommentMeta = const VerificationMeta(
    'bookSourceComment',
  );
  @override
  late final GeneratedColumn<String> bookSourceComment =
      GeneratedColumn<String>(
        'book_source_comment',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _variableCommentMeta = const VerificationMeta(
    'variableComment',
  );
  @override
  late final GeneratedColumn<String> variableComment = GeneratedColumn<String>(
    'variable_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdateTimeMeta = const VerificationMeta(
    'lastUpdateTime',
  );
  @override
  late final GeneratedColumn<int> lastUpdateTime = GeneratedColumn<int>(
    'last_update_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _respondTimeMeta = const VerificationMeta(
    'respondTime',
  );
  @override
  late final GeneratedColumn<int> respondTime = GeneratedColumn<int>(
    'respond_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(180000),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exploreUrlMeta = const VerificationMeta(
    'exploreUrl',
  );
  @override
  late final GeneratedColumn<String> exploreUrl = GeneratedColumn<String>(
    'explore_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exploreScreenMeta = const VerificationMeta(
    'exploreScreen',
  );
  @override
  late final GeneratedColumn<String> exploreScreen = GeneratedColumn<String>(
    'explore_screen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleExploreMeta = const VerificationMeta(
    'ruleExplore',
  );
  @override
  late final GeneratedColumn<String> ruleExplore = GeneratedColumn<String>(
    'rule_explore',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchUrlMeta = const VerificationMeta(
    'searchUrl',
  );
  @override
  late final GeneratedColumn<String> searchUrl = GeneratedColumn<String>(
    'search_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleSearchMeta = const VerificationMeta(
    'ruleSearch',
  );
  @override
  late final GeneratedColumn<String> ruleSearch = GeneratedColumn<String>(
    'rule_search',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleBookInfoMeta = const VerificationMeta(
    'ruleBookInfo',
  );
  @override
  late final GeneratedColumn<String> ruleBookInfo = GeneratedColumn<String>(
    'rule_book_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleTocMeta = const VerificationMeta(
    'ruleToc',
  );
  @override
  late final GeneratedColumn<String> ruleToc = GeneratedColumn<String>(
    'rule_toc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleContentMeta = const VerificationMeta(
    'ruleContent',
  );
  @override
  late final GeneratedColumn<String> ruleContent = GeneratedColumn<String>(
    'rule_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleReviewMeta = const VerificationMeta(
    'ruleReview',
  );
  @override
  late final GeneratedColumn<String> ruleReview = GeneratedColumn<String>(
    'rule_review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookSourceUrl,
    bookSourceName,
    bookSourceGroup,
    bookSourceType,
    bookUrlPattern,
    customOrder,
    enabled,
    enabledExplore,
    jsLib,
    enabledCookieJar,
    concurrentRate,
    header,
    loginUrl,
    loginUi,
    loginCheckJs,
    coverDecodeJs,
    bookSourceComment,
    variableComment,
    lastUpdateTime,
    respondTime,
    weight,
    exploreUrl,
    exploreScreen,
    ruleExplore,
    searchUrl,
    ruleSearch,
    ruleBookInfo,
    ruleToc,
    ruleContent,
    ruleReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_source_url')) {
      context.handle(
        _bookSourceUrlMeta,
        bookSourceUrl.isAcceptableOrUnknown(
          data['book_source_url']!,
          _bookSourceUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookSourceUrlMeta);
    }
    if (data.containsKey('book_source_name')) {
      context.handle(
        _bookSourceNameMeta,
        bookSourceName.isAcceptableOrUnknown(
          data['book_source_name']!,
          _bookSourceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookSourceNameMeta);
    }
    if (data.containsKey('book_source_group')) {
      context.handle(
        _bookSourceGroupMeta,
        bookSourceGroup.isAcceptableOrUnknown(
          data['book_source_group']!,
          _bookSourceGroupMeta,
        ),
      );
    }
    if (data.containsKey('book_source_type')) {
      context.handle(
        _bookSourceTypeMeta,
        bookSourceType.isAcceptableOrUnknown(
          data['book_source_type']!,
          _bookSourceTypeMeta,
        ),
      );
    }
    if (data.containsKey('book_url_pattern')) {
      context.handle(
        _bookUrlPatternMeta,
        bookUrlPattern.isAcceptableOrUnknown(
          data['book_url_pattern']!,
          _bookUrlPatternMeta,
        ),
      );
    }
    if (data.containsKey('custom_order')) {
      context.handle(
        _customOrderMeta,
        customOrder.isAcceptableOrUnknown(
          data['custom_order']!,
          _customOrderMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('enabled_explore')) {
      context.handle(
        _enabledExploreMeta,
        enabledExplore.isAcceptableOrUnknown(
          data['enabled_explore']!,
          _enabledExploreMeta,
        ),
      );
    }
    if (data.containsKey('js_lib')) {
      context.handle(
        _jsLibMeta,
        jsLib.isAcceptableOrUnknown(data['js_lib']!, _jsLibMeta),
      );
    }
    if (data.containsKey('enabled_cookie_jar')) {
      context.handle(
        _enabledCookieJarMeta,
        enabledCookieJar.isAcceptableOrUnknown(
          data['enabled_cookie_jar']!,
          _enabledCookieJarMeta,
        ),
      );
    }
    if (data.containsKey('concurrent_rate')) {
      context.handle(
        _concurrentRateMeta,
        concurrentRate.isAcceptableOrUnknown(
          data['concurrent_rate']!,
          _concurrentRateMeta,
        ),
      );
    }
    if (data.containsKey('header')) {
      context.handle(
        _headerMeta,
        header.isAcceptableOrUnknown(data['header']!, _headerMeta),
      );
    }
    if (data.containsKey('login_url')) {
      context.handle(
        _loginUrlMeta,
        loginUrl.isAcceptableOrUnknown(data['login_url']!, _loginUrlMeta),
      );
    }
    if (data.containsKey('login_ui')) {
      context.handle(
        _loginUiMeta,
        loginUi.isAcceptableOrUnknown(data['login_ui']!, _loginUiMeta),
      );
    }
    if (data.containsKey('login_check_js')) {
      context.handle(
        _loginCheckJsMeta,
        loginCheckJs.isAcceptableOrUnknown(
          data['login_check_js']!,
          _loginCheckJsMeta,
        ),
      );
    }
    if (data.containsKey('cover_decode_js')) {
      context.handle(
        _coverDecodeJsMeta,
        coverDecodeJs.isAcceptableOrUnknown(
          data['cover_decode_js']!,
          _coverDecodeJsMeta,
        ),
      );
    }
    if (data.containsKey('book_source_comment')) {
      context.handle(
        _bookSourceCommentMeta,
        bookSourceComment.isAcceptableOrUnknown(
          data['book_source_comment']!,
          _bookSourceCommentMeta,
        ),
      );
    }
    if (data.containsKey('variable_comment')) {
      context.handle(
        _variableCommentMeta,
        variableComment.isAcceptableOrUnknown(
          data['variable_comment']!,
          _variableCommentMeta,
        ),
      );
    }
    if (data.containsKey('last_update_time')) {
      context.handle(
        _lastUpdateTimeMeta,
        lastUpdateTime.isAcceptableOrUnknown(
          data['last_update_time']!,
          _lastUpdateTimeMeta,
        ),
      );
    }
    if (data.containsKey('respond_time')) {
      context.handle(
        _respondTimeMeta,
        respondTime.isAcceptableOrUnknown(
          data['respond_time']!,
          _respondTimeMeta,
        ),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('explore_url')) {
      context.handle(
        _exploreUrlMeta,
        exploreUrl.isAcceptableOrUnknown(data['explore_url']!, _exploreUrlMeta),
      );
    }
    if (data.containsKey('explore_screen')) {
      context.handle(
        _exploreScreenMeta,
        exploreScreen.isAcceptableOrUnknown(
          data['explore_screen']!,
          _exploreScreenMeta,
        ),
      );
    }
    if (data.containsKey('rule_explore')) {
      context.handle(
        _ruleExploreMeta,
        ruleExplore.isAcceptableOrUnknown(
          data['rule_explore']!,
          _ruleExploreMeta,
        ),
      );
    }
    if (data.containsKey('search_url')) {
      context.handle(
        _searchUrlMeta,
        searchUrl.isAcceptableOrUnknown(data['search_url']!, _searchUrlMeta),
      );
    }
    if (data.containsKey('rule_search')) {
      context.handle(
        _ruleSearchMeta,
        ruleSearch.isAcceptableOrUnknown(data['rule_search']!, _ruleSearchMeta),
      );
    }
    if (data.containsKey('rule_book_info')) {
      context.handle(
        _ruleBookInfoMeta,
        ruleBookInfo.isAcceptableOrUnknown(
          data['rule_book_info']!,
          _ruleBookInfoMeta,
        ),
      );
    }
    if (data.containsKey('rule_toc')) {
      context.handle(
        _ruleTocMeta,
        ruleToc.isAcceptableOrUnknown(data['rule_toc']!, _ruleTocMeta),
      );
    }
    if (data.containsKey('rule_content')) {
      context.handle(
        _ruleContentMeta,
        ruleContent.isAcceptableOrUnknown(
          data['rule_content']!,
          _ruleContentMeta,
        ),
      );
    }
    if (data.containsKey('rule_review')) {
      context.handle(
        _ruleReviewMeta,
        ruleReview.isAcceptableOrUnknown(data['rule_review']!, _ruleReviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookSourceUrl};
  @override
  BookSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookSource(
      bookSourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_source_url'],
      )!,
      bookSourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_source_name'],
      )!,
      bookSourceGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_source_group'],
      ),
      bookSourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_source_type'],
      )!,
      bookUrlPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_url_pattern'],
      ),
      customOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_order'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      enabledExplore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled_explore'],
      )!,
      jsLib: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}js_lib'],
      ),
      enabledCookieJar: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled_cookie_jar'],
      )!,
      concurrentRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concurrent_rate'],
      ),
      header: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header'],
      ),
      loginUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_url'],
      ),
      loginUi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_ui'],
      ),
      loginCheckJs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_check_js'],
      ),
      coverDecodeJs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_decode_js'],
      ),
      bookSourceComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_source_comment'],
      ),
      variableComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variable_comment'],
      ),
      lastUpdateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_update_time'],
      )!,
      respondTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}respond_time'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight'],
      )!,
      exploreUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explore_url'],
      ),
      exploreScreen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explore_screen'],
      ),
      ruleExplore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_explore'],
      ),
      searchUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_url'],
      ),
      ruleSearch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_search'],
      ),
      ruleBookInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_book_info'],
      ),
      ruleToc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_toc'],
      ),
      ruleContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_content'],
      ),
      ruleReview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_review'],
      ),
    );
  }

  @override
  $BookSourcesTable createAlias(String alias) {
    return $BookSourcesTable(attachedDatabase, alias);
  }
}

class BookSource extends DataClass implements Insertable<BookSource> {
  final String bookSourceUrl;
  final String bookSourceName;
  final String? bookSourceGroup;
  final int bookSourceType;
  final String? bookUrlPattern;
  final int customOrder;
  final bool enabled;
  final bool enabledExplore;
  final String? jsLib;
  final bool enabledCookieJar;
  final String? concurrentRate;
  final String? header;
  final String? loginUrl;
  final String? loginUi;
  final String? loginCheckJs;
  final String? coverDecodeJs;
  final String? bookSourceComment;
  final String? variableComment;
  final int lastUpdateTime;
  final int respondTime;
  final int weight;
  final String? exploreUrl;
  final String? exploreScreen;
  final String? ruleExplore;
  final String? searchUrl;
  final String? ruleSearch;
  final String? ruleBookInfo;
  final String? ruleToc;
  final String? ruleContent;
  final String? ruleReview;
  const BookSource({
    required this.bookSourceUrl,
    required this.bookSourceName,
    this.bookSourceGroup,
    required this.bookSourceType,
    this.bookUrlPattern,
    required this.customOrder,
    required this.enabled,
    required this.enabledExplore,
    this.jsLib,
    required this.enabledCookieJar,
    this.concurrentRate,
    this.header,
    this.loginUrl,
    this.loginUi,
    this.loginCheckJs,
    this.coverDecodeJs,
    this.bookSourceComment,
    this.variableComment,
    required this.lastUpdateTime,
    required this.respondTime,
    required this.weight,
    this.exploreUrl,
    this.exploreScreen,
    this.ruleExplore,
    this.searchUrl,
    this.ruleSearch,
    this.ruleBookInfo,
    this.ruleToc,
    this.ruleContent,
    this.ruleReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_source_url'] = Variable<String>(bookSourceUrl);
    map['book_source_name'] = Variable<String>(bookSourceName);
    if (!nullToAbsent || bookSourceGroup != null) {
      map['book_source_group'] = Variable<String>(bookSourceGroup);
    }
    map['book_source_type'] = Variable<int>(bookSourceType);
    if (!nullToAbsent || bookUrlPattern != null) {
      map['book_url_pattern'] = Variable<String>(bookUrlPattern);
    }
    map['custom_order'] = Variable<int>(customOrder);
    map['enabled'] = Variable<bool>(enabled);
    map['enabled_explore'] = Variable<bool>(enabledExplore);
    if (!nullToAbsent || jsLib != null) {
      map['js_lib'] = Variable<String>(jsLib);
    }
    map['enabled_cookie_jar'] = Variable<bool>(enabledCookieJar);
    if (!nullToAbsent || concurrentRate != null) {
      map['concurrent_rate'] = Variable<String>(concurrentRate);
    }
    if (!nullToAbsent || header != null) {
      map['header'] = Variable<String>(header);
    }
    if (!nullToAbsent || loginUrl != null) {
      map['login_url'] = Variable<String>(loginUrl);
    }
    if (!nullToAbsent || loginUi != null) {
      map['login_ui'] = Variable<String>(loginUi);
    }
    if (!nullToAbsent || loginCheckJs != null) {
      map['login_check_js'] = Variable<String>(loginCheckJs);
    }
    if (!nullToAbsent || coverDecodeJs != null) {
      map['cover_decode_js'] = Variable<String>(coverDecodeJs);
    }
    if (!nullToAbsent || bookSourceComment != null) {
      map['book_source_comment'] = Variable<String>(bookSourceComment);
    }
    if (!nullToAbsent || variableComment != null) {
      map['variable_comment'] = Variable<String>(variableComment);
    }
    map['last_update_time'] = Variable<int>(lastUpdateTime);
    map['respond_time'] = Variable<int>(respondTime);
    map['weight'] = Variable<int>(weight);
    if (!nullToAbsent || exploreUrl != null) {
      map['explore_url'] = Variable<String>(exploreUrl);
    }
    if (!nullToAbsent || exploreScreen != null) {
      map['explore_screen'] = Variable<String>(exploreScreen);
    }
    if (!nullToAbsent || ruleExplore != null) {
      map['rule_explore'] = Variable<String>(ruleExplore);
    }
    if (!nullToAbsent || searchUrl != null) {
      map['search_url'] = Variable<String>(searchUrl);
    }
    if (!nullToAbsent || ruleSearch != null) {
      map['rule_search'] = Variable<String>(ruleSearch);
    }
    if (!nullToAbsent || ruleBookInfo != null) {
      map['rule_book_info'] = Variable<String>(ruleBookInfo);
    }
    if (!nullToAbsent || ruleToc != null) {
      map['rule_toc'] = Variable<String>(ruleToc);
    }
    if (!nullToAbsent || ruleContent != null) {
      map['rule_content'] = Variable<String>(ruleContent);
    }
    if (!nullToAbsent || ruleReview != null) {
      map['rule_review'] = Variable<String>(ruleReview);
    }
    return map;
  }

  BookSourcesCompanion toCompanion(bool nullToAbsent) {
    return BookSourcesCompanion(
      bookSourceUrl: Value(bookSourceUrl),
      bookSourceName: Value(bookSourceName),
      bookSourceGroup: bookSourceGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bookSourceGroup),
      bookSourceType: Value(bookSourceType),
      bookUrlPattern: bookUrlPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(bookUrlPattern),
      customOrder: Value(customOrder),
      enabled: Value(enabled),
      enabledExplore: Value(enabledExplore),
      jsLib: jsLib == null && nullToAbsent
          ? const Value.absent()
          : Value(jsLib),
      enabledCookieJar: Value(enabledCookieJar),
      concurrentRate: concurrentRate == null && nullToAbsent
          ? const Value.absent()
          : Value(concurrentRate),
      header: header == null && nullToAbsent
          ? const Value.absent()
          : Value(header),
      loginUrl: loginUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(loginUrl),
      loginUi: loginUi == null && nullToAbsent
          ? const Value.absent()
          : Value(loginUi),
      loginCheckJs: loginCheckJs == null && nullToAbsent
          ? const Value.absent()
          : Value(loginCheckJs),
      coverDecodeJs: coverDecodeJs == null && nullToAbsent
          ? const Value.absent()
          : Value(coverDecodeJs),
      bookSourceComment: bookSourceComment == null && nullToAbsent
          ? const Value.absent()
          : Value(bookSourceComment),
      variableComment: variableComment == null && nullToAbsent
          ? const Value.absent()
          : Value(variableComment),
      lastUpdateTime: Value(lastUpdateTime),
      respondTime: Value(respondTime),
      weight: Value(weight),
      exploreUrl: exploreUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(exploreUrl),
      exploreScreen: exploreScreen == null && nullToAbsent
          ? const Value.absent()
          : Value(exploreScreen),
      ruleExplore: ruleExplore == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleExplore),
      searchUrl: searchUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(searchUrl),
      ruleSearch: ruleSearch == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleSearch),
      ruleBookInfo: ruleBookInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleBookInfo),
      ruleToc: ruleToc == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleToc),
      ruleContent: ruleContent == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleContent),
      ruleReview: ruleReview == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleReview),
    );
  }

  factory BookSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookSource(
      bookSourceUrl: serializer.fromJson<String>(json['bookSourceUrl']),
      bookSourceName: serializer.fromJson<String>(json['bookSourceName']),
      bookSourceGroup: serializer.fromJson<String?>(json['bookSourceGroup']),
      bookSourceType: serializer.fromJson<int>(json['bookSourceType']),
      bookUrlPattern: serializer.fromJson<String?>(json['bookUrlPattern']),
      customOrder: serializer.fromJson<int>(json['customOrder']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      enabledExplore: serializer.fromJson<bool>(json['enabledExplore']),
      jsLib: serializer.fromJson<String?>(json['jsLib']),
      enabledCookieJar: serializer.fromJson<bool>(json['enabledCookieJar']),
      concurrentRate: serializer.fromJson<String?>(json['concurrentRate']),
      header: serializer.fromJson<String?>(json['header']),
      loginUrl: serializer.fromJson<String?>(json['loginUrl']),
      loginUi: serializer.fromJson<String?>(json['loginUi']),
      loginCheckJs: serializer.fromJson<String?>(json['loginCheckJs']),
      coverDecodeJs: serializer.fromJson<String?>(json['coverDecodeJs']),
      bookSourceComment: serializer.fromJson<String?>(
        json['bookSourceComment'],
      ),
      variableComment: serializer.fromJson<String?>(json['variableComment']),
      lastUpdateTime: serializer.fromJson<int>(json['lastUpdateTime']),
      respondTime: serializer.fromJson<int>(json['respondTime']),
      weight: serializer.fromJson<int>(json['weight']),
      exploreUrl: serializer.fromJson<String?>(json['exploreUrl']),
      exploreScreen: serializer.fromJson<String?>(json['exploreScreen']),
      ruleExplore: serializer.fromJson<String?>(json['ruleExplore']),
      searchUrl: serializer.fromJson<String?>(json['searchUrl']),
      ruleSearch: serializer.fromJson<String?>(json['ruleSearch']),
      ruleBookInfo: serializer.fromJson<String?>(json['ruleBookInfo']),
      ruleToc: serializer.fromJson<String?>(json['ruleToc']),
      ruleContent: serializer.fromJson<String?>(json['ruleContent']),
      ruleReview: serializer.fromJson<String?>(json['ruleReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookSourceUrl': serializer.toJson<String>(bookSourceUrl),
      'bookSourceName': serializer.toJson<String>(bookSourceName),
      'bookSourceGroup': serializer.toJson<String?>(bookSourceGroup),
      'bookSourceType': serializer.toJson<int>(bookSourceType),
      'bookUrlPattern': serializer.toJson<String?>(bookUrlPattern),
      'customOrder': serializer.toJson<int>(customOrder),
      'enabled': serializer.toJson<bool>(enabled),
      'enabledExplore': serializer.toJson<bool>(enabledExplore),
      'jsLib': serializer.toJson<String?>(jsLib),
      'enabledCookieJar': serializer.toJson<bool>(enabledCookieJar),
      'concurrentRate': serializer.toJson<String?>(concurrentRate),
      'header': serializer.toJson<String?>(header),
      'loginUrl': serializer.toJson<String?>(loginUrl),
      'loginUi': serializer.toJson<String?>(loginUi),
      'loginCheckJs': serializer.toJson<String?>(loginCheckJs),
      'coverDecodeJs': serializer.toJson<String?>(coverDecodeJs),
      'bookSourceComment': serializer.toJson<String?>(bookSourceComment),
      'variableComment': serializer.toJson<String?>(variableComment),
      'lastUpdateTime': serializer.toJson<int>(lastUpdateTime),
      'respondTime': serializer.toJson<int>(respondTime),
      'weight': serializer.toJson<int>(weight),
      'exploreUrl': serializer.toJson<String?>(exploreUrl),
      'exploreScreen': serializer.toJson<String?>(exploreScreen),
      'ruleExplore': serializer.toJson<String?>(ruleExplore),
      'searchUrl': serializer.toJson<String?>(searchUrl),
      'ruleSearch': serializer.toJson<String?>(ruleSearch),
      'ruleBookInfo': serializer.toJson<String?>(ruleBookInfo),
      'ruleToc': serializer.toJson<String?>(ruleToc),
      'ruleContent': serializer.toJson<String?>(ruleContent),
      'ruleReview': serializer.toJson<String?>(ruleReview),
    };
  }

  BookSource copyWith({
    String? bookSourceUrl,
    String? bookSourceName,
    Value<String?> bookSourceGroup = const Value.absent(),
    int? bookSourceType,
    Value<String?> bookUrlPattern = const Value.absent(),
    int? customOrder,
    bool? enabled,
    bool? enabledExplore,
    Value<String?> jsLib = const Value.absent(),
    bool? enabledCookieJar,
    Value<String?> concurrentRate = const Value.absent(),
    Value<String?> header = const Value.absent(),
    Value<String?> loginUrl = const Value.absent(),
    Value<String?> loginUi = const Value.absent(),
    Value<String?> loginCheckJs = const Value.absent(),
    Value<String?> coverDecodeJs = const Value.absent(),
    Value<String?> bookSourceComment = const Value.absent(),
    Value<String?> variableComment = const Value.absent(),
    int? lastUpdateTime,
    int? respondTime,
    int? weight,
    Value<String?> exploreUrl = const Value.absent(),
    Value<String?> exploreScreen = const Value.absent(),
    Value<String?> ruleExplore = const Value.absent(),
    Value<String?> searchUrl = const Value.absent(),
    Value<String?> ruleSearch = const Value.absent(),
    Value<String?> ruleBookInfo = const Value.absent(),
    Value<String?> ruleToc = const Value.absent(),
    Value<String?> ruleContent = const Value.absent(),
    Value<String?> ruleReview = const Value.absent(),
  }) => BookSource(
    bookSourceUrl: bookSourceUrl ?? this.bookSourceUrl,
    bookSourceName: bookSourceName ?? this.bookSourceName,
    bookSourceGroup: bookSourceGroup.present
        ? bookSourceGroup.value
        : this.bookSourceGroup,
    bookSourceType: bookSourceType ?? this.bookSourceType,
    bookUrlPattern: bookUrlPattern.present
        ? bookUrlPattern.value
        : this.bookUrlPattern,
    customOrder: customOrder ?? this.customOrder,
    enabled: enabled ?? this.enabled,
    enabledExplore: enabledExplore ?? this.enabledExplore,
    jsLib: jsLib.present ? jsLib.value : this.jsLib,
    enabledCookieJar: enabledCookieJar ?? this.enabledCookieJar,
    concurrentRate: concurrentRate.present
        ? concurrentRate.value
        : this.concurrentRate,
    header: header.present ? header.value : this.header,
    loginUrl: loginUrl.present ? loginUrl.value : this.loginUrl,
    loginUi: loginUi.present ? loginUi.value : this.loginUi,
    loginCheckJs: loginCheckJs.present ? loginCheckJs.value : this.loginCheckJs,
    coverDecodeJs: coverDecodeJs.present
        ? coverDecodeJs.value
        : this.coverDecodeJs,
    bookSourceComment: bookSourceComment.present
        ? bookSourceComment.value
        : this.bookSourceComment,
    variableComment: variableComment.present
        ? variableComment.value
        : this.variableComment,
    lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    respondTime: respondTime ?? this.respondTime,
    weight: weight ?? this.weight,
    exploreUrl: exploreUrl.present ? exploreUrl.value : this.exploreUrl,
    exploreScreen: exploreScreen.present
        ? exploreScreen.value
        : this.exploreScreen,
    ruleExplore: ruleExplore.present ? ruleExplore.value : this.ruleExplore,
    searchUrl: searchUrl.present ? searchUrl.value : this.searchUrl,
    ruleSearch: ruleSearch.present ? ruleSearch.value : this.ruleSearch,
    ruleBookInfo: ruleBookInfo.present ? ruleBookInfo.value : this.ruleBookInfo,
    ruleToc: ruleToc.present ? ruleToc.value : this.ruleToc,
    ruleContent: ruleContent.present ? ruleContent.value : this.ruleContent,
    ruleReview: ruleReview.present ? ruleReview.value : this.ruleReview,
  );
  BookSource copyWithCompanion(BookSourcesCompanion data) {
    return BookSource(
      bookSourceUrl: data.bookSourceUrl.present
          ? data.bookSourceUrl.value
          : this.bookSourceUrl,
      bookSourceName: data.bookSourceName.present
          ? data.bookSourceName.value
          : this.bookSourceName,
      bookSourceGroup: data.bookSourceGroup.present
          ? data.bookSourceGroup.value
          : this.bookSourceGroup,
      bookSourceType: data.bookSourceType.present
          ? data.bookSourceType.value
          : this.bookSourceType,
      bookUrlPattern: data.bookUrlPattern.present
          ? data.bookUrlPattern.value
          : this.bookUrlPattern,
      customOrder: data.customOrder.present
          ? data.customOrder.value
          : this.customOrder,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      enabledExplore: data.enabledExplore.present
          ? data.enabledExplore.value
          : this.enabledExplore,
      jsLib: data.jsLib.present ? data.jsLib.value : this.jsLib,
      enabledCookieJar: data.enabledCookieJar.present
          ? data.enabledCookieJar.value
          : this.enabledCookieJar,
      concurrentRate: data.concurrentRate.present
          ? data.concurrentRate.value
          : this.concurrentRate,
      header: data.header.present ? data.header.value : this.header,
      loginUrl: data.loginUrl.present ? data.loginUrl.value : this.loginUrl,
      loginUi: data.loginUi.present ? data.loginUi.value : this.loginUi,
      loginCheckJs: data.loginCheckJs.present
          ? data.loginCheckJs.value
          : this.loginCheckJs,
      coverDecodeJs: data.coverDecodeJs.present
          ? data.coverDecodeJs.value
          : this.coverDecodeJs,
      bookSourceComment: data.bookSourceComment.present
          ? data.bookSourceComment.value
          : this.bookSourceComment,
      variableComment: data.variableComment.present
          ? data.variableComment.value
          : this.variableComment,
      lastUpdateTime: data.lastUpdateTime.present
          ? data.lastUpdateTime.value
          : this.lastUpdateTime,
      respondTime: data.respondTime.present
          ? data.respondTime.value
          : this.respondTime,
      weight: data.weight.present ? data.weight.value : this.weight,
      exploreUrl: data.exploreUrl.present
          ? data.exploreUrl.value
          : this.exploreUrl,
      exploreScreen: data.exploreScreen.present
          ? data.exploreScreen.value
          : this.exploreScreen,
      ruleExplore: data.ruleExplore.present
          ? data.ruleExplore.value
          : this.ruleExplore,
      searchUrl: data.searchUrl.present ? data.searchUrl.value : this.searchUrl,
      ruleSearch: data.ruleSearch.present
          ? data.ruleSearch.value
          : this.ruleSearch,
      ruleBookInfo: data.ruleBookInfo.present
          ? data.ruleBookInfo.value
          : this.ruleBookInfo,
      ruleToc: data.ruleToc.present ? data.ruleToc.value : this.ruleToc,
      ruleContent: data.ruleContent.present
          ? data.ruleContent.value
          : this.ruleContent,
      ruleReview: data.ruleReview.present
          ? data.ruleReview.value
          : this.ruleReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookSource(')
          ..write('bookSourceUrl: $bookSourceUrl, ')
          ..write('bookSourceName: $bookSourceName, ')
          ..write('bookSourceGroup: $bookSourceGroup, ')
          ..write('bookSourceType: $bookSourceType, ')
          ..write('bookUrlPattern: $bookUrlPattern, ')
          ..write('customOrder: $customOrder, ')
          ..write('enabled: $enabled, ')
          ..write('enabledExplore: $enabledExplore, ')
          ..write('jsLib: $jsLib, ')
          ..write('enabledCookieJar: $enabledCookieJar, ')
          ..write('concurrentRate: $concurrentRate, ')
          ..write('header: $header, ')
          ..write('loginUrl: $loginUrl, ')
          ..write('loginUi: $loginUi, ')
          ..write('loginCheckJs: $loginCheckJs, ')
          ..write('coverDecodeJs: $coverDecodeJs, ')
          ..write('bookSourceComment: $bookSourceComment, ')
          ..write('variableComment: $variableComment, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('respondTime: $respondTime, ')
          ..write('weight: $weight, ')
          ..write('exploreUrl: $exploreUrl, ')
          ..write('exploreScreen: $exploreScreen, ')
          ..write('ruleExplore: $ruleExplore, ')
          ..write('searchUrl: $searchUrl, ')
          ..write('ruleSearch: $ruleSearch, ')
          ..write('ruleBookInfo: $ruleBookInfo, ')
          ..write('ruleToc: $ruleToc, ')
          ..write('ruleContent: $ruleContent, ')
          ..write('ruleReview: $ruleReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    bookSourceUrl,
    bookSourceName,
    bookSourceGroup,
    bookSourceType,
    bookUrlPattern,
    customOrder,
    enabled,
    enabledExplore,
    jsLib,
    enabledCookieJar,
    concurrentRate,
    header,
    loginUrl,
    loginUi,
    loginCheckJs,
    coverDecodeJs,
    bookSourceComment,
    variableComment,
    lastUpdateTime,
    respondTime,
    weight,
    exploreUrl,
    exploreScreen,
    ruleExplore,
    searchUrl,
    ruleSearch,
    ruleBookInfo,
    ruleToc,
    ruleContent,
    ruleReview,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookSource &&
          other.bookSourceUrl == this.bookSourceUrl &&
          other.bookSourceName == this.bookSourceName &&
          other.bookSourceGroup == this.bookSourceGroup &&
          other.bookSourceType == this.bookSourceType &&
          other.bookUrlPattern == this.bookUrlPattern &&
          other.customOrder == this.customOrder &&
          other.enabled == this.enabled &&
          other.enabledExplore == this.enabledExplore &&
          other.jsLib == this.jsLib &&
          other.enabledCookieJar == this.enabledCookieJar &&
          other.concurrentRate == this.concurrentRate &&
          other.header == this.header &&
          other.loginUrl == this.loginUrl &&
          other.loginUi == this.loginUi &&
          other.loginCheckJs == this.loginCheckJs &&
          other.coverDecodeJs == this.coverDecodeJs &&
          other.bookSourceComment == this.bookSourceComment &&
          other.variableComment == this.variableComment &&
          other.lastUpdateTime == this.lastUpdateTime &&
          other.respondTime == this.respondTime &&
          other.weight == this.weight &&
          other.exploreUrl == this.exploreUrl &&
          other.exploreScreen == this.exploreScreen &&
          other.ruleExplore == this.ruleExplore &&
          other.searchUrl == this.searchUrl &&
          other.ruleSearch == this.ruleSearch &&
          other.ruleBookInfo == this.ruleBookInfo &&
          other.ruleToc == this.ruleToc &&
          other.ruleContent == this.ruleContent &&
          other.ruleReview == this.ruleReview);
}

class BookSourcesCompanion extends UpdateCompanion<BookSource> {
  final Value<String> bookSourceUrl;
  final Value<String> bookSourceName;
  final Value<String?> bookSourceGroup;
  final Value<int> bookSourceType;
  final Value<String?> bookUrlPattern;
  final Value<int> customOrder;
  final Value<bool> enabled;
  final Value<bool> enabledExplore;
  final Value<String?> jsLib;
  final Value<bool> enabledCookieJar;
  final Value<String?> concurrentRate;
  final Value<String?> header;
  final Value<String?> loginUrl;
  final Value<String?> loginUi;
  final Value<String?> loginCheckJs;
  final Value<String?> coverDecodeJs;
  final Value<String?> bookSourceComment;
  final Value<String?> variableComment;
  final Value<int> lastUpdateTime;
  final Value<int> respondTime;
  final Value<int> weight;
  final Value<String?> exploreUrl;
  final Value<String?> exploreScreen;
  final Value<String?> ruleExplore;
  final Value<String?> searchUrl;
  final Value<String?> ruleSearch;
  final Value<String?> ruleBookInfo;
  final Value<String?> ruleToc;
  final Value<String?> ruleContent;
  final Value<String?> ruleReview;
  final Value<int> rowid;
  const BookSourcesCompanion({
    this.bookSourceUrl = const Value.absent(),
    this.bookSourceName = const Value.absent(),
    this.bookSourceGroup = const Value.absent(),
    this.bookSourceType = const Value.absent(),
    this.bookUrlPattern = const Value.absent(),
    this.customOrder = const Value.absent(),
    this.enabled = const Value.absent(),
    this.enabledExplore = const Value.absent(),
    this.jsLib = const Value.absent(),
    this.enabledCookieJar = const Value.absent(),
    this.concurrentRate = const Value.absent(),
    this.header = const Value.absent(),
    this.loginUrl = const Value.absent(),
    this.loginUi = const Value.absent(),
    this.loginCheckJs = const Value.absent(),
    this.coverDecodeJs = const Value.absent(),
    this.bookSourceComment = const Value.absent(),
    this.variableComment = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
    this.respondTime = const Value.absent(),
    this.weight = const Value.absent(),
    this.exploreUrl = const Value.absent(),
    this.exploreScreen = const Value.absent(),
    this.ruleExplore = const Value.absent(),
    this.searchUrl = const Value.absent(),
    this.ruleSearch = const Value.absent(),
    this.ruleBookInfo = const Value.absent(),
    this.ruleToc = const Value.absent(),
    this.ruleContent = const Value.absent(),
    this.ruleReview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookSourcesCompanion.insert({
    required String bookSourceUrl,
    required String bookSourceName,
    this.bookSourceGroup = const Value.absent(),
    this.bookSourceType = const Value.absent(),
    this.bookUrlPattern = const Value.absent(),
    this.customOrder = const Value.absent(),
    this.enabled = const Value.absent(),
    this.enabledExplore = const Value.absent(),
    this.jsLib = const Value.absent(),
    this.enabledCookieJar = const Value.absent(),
    this.concurrentRate = const Value.absent(),
    this.header = const Value.absent(),
    this.loginUrl = const Value.absent(),
    this.loginUi = const Value.absent(),
    this.loginCheckJs = const Value.absent(),
    this.coverDecodeJs = const Value.absent(),
    this.bookSourceComment = const Value.absent(),
    this.variableComment = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
    this.respondTime = const Value.absent(),
    this.weight = const Value.absent(),
    this.exploreUrl = const Value.absent(),
    this.exploreScreen = const Value.absent(),
    this.ruleExplore = const Value.absent(),
    this.searchUrl = const Value.absent(),
    this.ruleSearch = const Value.absent(),
    this.ruleBookInfo = const Value.absent(),
    this.ruleToc = const Value.absent(),
    this.ruleContent = const Value.absent(),
    this.ruleReview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookSourceUrl = Value(bookSourceUrl),
       bookSourceName = Value(bookSourceName);
  static Insertable<BookSource> custom({
    Expression<String>? bookSourceUrl,
    Expression<String>? bookSourceName,
    Expression<String>? bookSourceGroup,
    Expression<int>? bookSourceType,
    Expression<String>? bookUrlPattern,
    Expression<int>? customOrder,
    Expression<bool>? enabled,
    Expression<bool>? enabledExplore,
    Expression<String>? jsLib,
    Expression<bool>? enabledCookieJar,
    Expression<String>? concurrentRate,
    Expression<String>? header,
    Expression<String>? loginUrl,
    Expression<String>? loginUi,
    Expression<String>? loginCheckJs,
    Expression<String>? coverDecodeJs,
    Expression<String>? bookSourceComment,
    Expression<String>? variableComment,
    Expression<int>? lastUpdateTime,
    Expression<int>? respondTime,
    Expression<int>? weight,
    Expression<String>? exploreUrl,
    Expression<String>? exploreScreen,
    Expression<String>? ruleExplore,
    Expression<String>? searchUrl,
    Expression<String>? ruleSearch,
    Expression<String>? ruleBookInfo,
    Expression<String>? ruleToc,
    Expression<String>? ruleContent,
    Expression<String>? ruleReview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookSourceUrl != null) 'book_source_url': bookSourceUrl,
      if (bookSourceName != null) 'book_source_name': bookSourceName,
      if (bookSourceGroup != null) 'book_source_group': bookSourceGroup,
      if (bookSourceType != null) 'book_source_type': bookSourceType,
      if (bookUrlPattern != null) 'book_url_pattern': bookUrlPattern,
      if (customOrder != null) 'custom_order': customOrder,
      if (enabled != null) 'enabled': enabled,
      if (enabledExplore != null) 'enabled_explore': enabledExplore,
      if (jsLib != null) 'js_lib': jsLib,
      if (enabledCookieJar != null) 'enabled_cookie_jar': enabledCookieJar,
      if (concurrentRate != null) 'concurrent_rate': concurrentRate,
      if (header != null) 'header': header,
      if (loginUrl != null) 'login_url': loginUrl,
      if (loginUi != null) 'login_ui': loginUi,
      if (loginCheckJs != null) 'login_check_js': loginCheckJs,
      if (coverDecodeJs != null) 'cover_decode_js': coverDecodeJs,
      if (bookSourceComment != null) 'book_source_comment': bookSourceComment,
      if (variableComment != null) 'variable_comment': variableComment,
      if (lastUpdateTime != null) 'last_update_time': lastUpdateTime,
      if (respondTime != null) 'respond_time': respondTime,
      if (weight != null) 'weight': weight,
      if (exploreUrl != null) 'explore_url': exploreUrl,
      if (exploreScreen != null) 'explore_screen': exploreScreen,
      if (ruleExplore != null) 'rule_explore': ruleExplore,
      if (searchUrl != null) 'search_url': searchUrl,
      if (ruleSearch != null) 'rule_search': ruleSearch,
      if (ruleBookInfo != null) 'rule_book_info': ruleBookInfo,
      if (ruleToc != null) 'rule_toc': ruleToc,
      if (ruleContent != null) 'rule_content': ruleContent,
      if (ruleReview != null) 'rule_review': ruleReview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookSourcesCompanion copyWith({
    Value<String>? bookSourceUrl,
    Value<String>? bookSourceName,
    Value<String?>? bookSourceGroup,
    Value<int>? bookSourceType,
    Value<String?>? bookUrlPattern,
    Value<int>? customOrder,
    Value<bool>? enabled,
    Value<bool>? enabledExplore,
    Value<String?>? jsLib,
    Value<bool>? enabledCookieJar,
    Value<String?>? concurrentRate,
    Value<String?>? header,
    Value<String?>? loginUrl,
    Value<String?>? loginUi,
    Value<String?>? loginCheckJs,
    Value<String?>? coverDecodeJs,
    Value<String?>? bookSourceComment,
    Value<String?>? variableComment,
    Value<int>? lastUpdateTime,
    Value<int>? respondTime,
    Value<int>? weight,
    Value<String?>? exploreUrl,
    Value<String?>? exploreScreen,
    Value<String?>? ruleExplore,
    Value<String?>? searchUrl,
    Value<String?>? ruleSearch,
    Value<String?>? ruleBookInfo,
    Value<String?>? ruleToc,
    Value<String?>? ruleContent,
    Value<String?>? ruleReview,
    Value<int>? rowid,
  }) {
    return BookSourcesCompanion(
      bookSourceUrl: bookSourceUrl ?? this.bookSourceUrl,
      bookSourceName: bookSourceName ?? this.bookSourceName,
      bookSourceGroup: bookSourceGroup ?? this.bookSourceGroup,
      bookSourceType: bookSourceType ?? this.bookSourceType,
      bookUrlPattern: bookUrlPattern ?? this.bookUrlPattern,
      customOrder: customOrder ?? this.customOrder,
      enabled: enabled ?? this.enabled,
      enabledExplore: enabledExplore ?? this.enabledExplore,
      jsLib: jsLib ?? this.jsLib,
      enabledCookieJar: enabledCookieJar ?? this.enabledCookieJar,
      concurrentRate: concurrentRate ?? this.concurrentRate,
      header: header ?? this.header,
      loginUrl: loginUrl ?? this.loginUrl,
      loginUi: loginUi ?? this.loginUi,
      loginCheckJs: loginCheckJs ?? this.loginCheckJs,
      coverDecodeJs: coverDecodeJs ?? this.coverDecodeJs,
      bookSourceComment: bookSourceComment ?? this.bookSourceComment,
      variableComment: variableComment ?? this.variableComment,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      respondTime: respondTime ?? this.respondTime,
      weight: weight ?? this.weight,
      exploreUrl: exploreUrl ?? this.exploreUrl,
      exploreScreen: exploreScreen ?? this.exploreScreen,
      ruleExplore: ruleExplore ?? this.ruleExplore,
      searchUrl: searchUrl ?? this.searchUrl,
      ruleSearch: ruleSearch ?? this.ruleSearch,
      ruleBookInfo: ruleBookInfo ?? this.ruleBookInfo,
      ruleToc: ruleToc ?? this.ruleToc,
      ruleContent: ruleContent ?? this.ruleContent,
      ruleReview: ruleReview ?? this.ruleReview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookSourceUrl.present) {
      map['book_source_url'] = Variable<String>(bookSourceUrl.value);
    }
    if (bookSourceName.present) {
      map['book_source_name'] = Variable<String>(bookSourceName.value);
    }
    if (bookSourceGroup.present) {
      map['book_source_group'] = Variable<String>(bookSourceGroup.value);
    }
    if (bookSourceType.present) {
      map['book_source_type'] = Variable<int>(bookSourceType.value);
    }
    if (bookUrlPattern.present) {
      map['book_url_pattern'] = Variable<String>(bookUrlPattern.value);
    }
    if (customOrder.present) {
      map['custom_order'] = Variable<int>(customOrder.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (enabledExplore.present) {
      map['enabled_explore'] = Variable<bool>(enabledExplore.value);
    }
    if (jsLib.present) {
      map['js_lib'] = Variable<String>(jsLib.value);
    }
    if (enabledCookieJar.present) {
      map['enabled_cookie_jar'] = Variable<bool>(enabledCookieJar.value);
    }
    if (concurrentRate.present) {
      map['concurrent_rate'] = Variable<String>(concurrentRate.value);
    }
    if (header.present) {
      map['header'] = Variable<String>(header.value);
    }
    if (loginUrl.present) {
      map['login_url'] = Variable<String>(loginUrl.value);
    }
    if (loginUi.present) {
      map['login_ui'] = Variable<String>(loginUi.value);
    }
    if (loginCheckJs.present) {
      map['login_check_js'] = Variable<String>(loginCheckJs.value);
    }
    if (coverDecodeJs.present) {
      map['cover_decode_js'] = Variable<String>(coverDecodeJs.value);
    }
    if (bookSourceComment.present) {
      map['book_source_comment'] = Variable<String>(bookSourceComment.value);
    }
    if (variableComment.present) {
      map['variable_comment'] = Variable<String>(variableComment.value);
    }
    if (lastUpdateTime.present) {
      map['last_update_time'] = Variable<int>(lastUpdateTime.value);
    }
    if (respondTime.present) {
      map['respond_time'] = Variable<int>(respondTime.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (exploreUrl.present) {
      map['explore_url'] = Variable<String>(exploreUrl.value);
    }
    if (exploreScreen.present) {
      map['explore_screen'] = Variable<String>(exploreScreen.value);
    }
    if (ruleExplore.present) {
      map['rule_explore'] = Variable<String>(ruleExplore.value);
    }
    if (searchUrl.present) {
      map['search_url'] = Variable<String>(searchUrl.value);
    }
    if (ruleSearch.present) {
      map['rule_search'] = Variable<String>(ruleSearch.value);
    }
    if (ruleBookInfo.present) {
      map['rule_book_info'] = Variable<String>(ruleBookInfo.value);
    }
    if (ruleToc.present) {
      map['rule_toc'] = Variable<String>(ruleToc.value);
    }
    if (ruleContent.present) {
      map['rule_content'] = Variable<String>(ruleContent.value);
    }
    if (ruleReview.present) {
      map['rule_review'] = Variable<String>(ruleReview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookSourcesCompanion(')
          ..write('bookSourceUrl: $bookSourceUrl, ')
          ..write('bookSourceName: $bookSourceName, ')
          ..write('bookSourceGroup: $bookSourceGroup, ')
          ..write('bookSourceType: $bookSourceType, ')
          ..write('bookUrlPattern: $bookUrlPattern, ')
          ..write('customOrder: $customOrder, ')
          ..write('enabled: $enabled, ')
          ..write('enabledExplore: $enabledExplore, ')
          ..write('jsLib: $jsLib, ')
          ..write('enabledCookieJar: $enabledCookieJar, ')
          ..write('concurrentRate: $concurrentRate, ')
          ..write('header: $header, ')
          ..write('loginUrl: $loginUrl, ')
          ..write('loginUi: $loginUi, ')
          ..write('loginCheckJs: $loginCheckJs, ')
          ..write('coverDecodeJs: $coverDecodeJs, ')
          ..write('bookSourceComment: $bookSourceComment, ')
          ..write('variableComment: $variableComment, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('respondTime: $respondTime, ')
          ..write('weight: $weight, ')
          ..write('exploreUrl: $exploreUrl, ')
          ..write('exploreScreen: $exploreScreen, ')
          ..write('ruleExplore: $ruleExplore, ')
          ..write('searchUrl: $searchUrl, ')
          ..write('ruleSearch: $ruleSearch, ')
          ..write('ruleBookInfo: $ruleBookInfo, ')
          ..write('ruleToc: $ruleToc, ')
          ..write('ruleContent: $ruleContent, ')
          ..write('ruleReview: $ruleReview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookChaptersTable extends BookChapters
    with TableInfo<$BookChaptersTable, BookChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookUrlMeta = const VerificationMeta(
    'bookUrl',
  );
  @override
  late final GeneratedColumn<String> bookUrl = GeneratedColumn<String>(
    'book_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
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
  static const VerificationMeta _chapterUrlMeta = const VerificationMeta(
    'chapterUrl',
  );
  @override
  late final GeneratedColumn<String> chapterUrl = GeneratedColumn<String>(
    'chapter_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVolumeMeta = const VerificationMeta(
    'isVolume',
  );
  @override
  late final GeneratedColumn<bool> isVolume = GeneratedColumn<bool>(
    'is_volume',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_volume" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updateTimeMeta = const VerificationMeta(
    'updateTime',
  );
  @override
  late final GeneratedColumn<int> updateTime = GeneratedColumn<int>(
    'update_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookUrl,
    chapterIndex,
    title,
    chapterUrl,
    content,
    isVolume,
    updateTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_url')) {
      context.handle(
        _bookUrlMeta,
        bookUrl.isAcceptableOrUnknown(data['book_url']!, _bookUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_bookUrlMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('chapter_url')) {
      context.handle(
        _chapterUrlMeta,
        chapterUrl.isAcceptableOrUnknown(data['chapter_url']!, _chapterUrlMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('is_volume')) {
      context.handle(
        _isVolumeMeta,
        isVolume.isAcceptableOrUnknown(data['is_volume']!, _isVolumeMeta),
      );
    }
    if (data.containsKey('update_time')) {
      context.handle(
        _updateTimeMeta,
        updateTime.isAcceptableOrUnknown(data['update_time']!, _updateTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookUrl, chapterIndex};
  @override
  BookChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookChapter(
      bookUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_url'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      chapterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_url'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      isVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_volume'],
      )!,
      updateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}update_time'],
      )!,
    );
  }

  @override
  $BookChaptersTable createAlias(String alias) {
    return $BookChaptersTable(attachedDatabase, alias);
  }
}

class BookChapter extends DataClass implements Insertable<BookChapter> {
  final String bookUrl;
  final int chapterIndex;
  final String title;
  final String chapterUrl;
  final String? content;
  final bool isVolume;
  final int updateTime;
  const BookChapter({
    required this.bookUrl,
    required this.chapterIndex,
    required this.title,
    required this.chapterUrl,
    this.content,
    required this.isVolume,
    required this.updateTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_url'] = Variable<String>(bookUrl);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['title'] = Variable<String>(title);
    map['chapter_url'] = Variable<String>(chapterUrl);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['is_volume'] = Variable<bool>(isVolume);
    map['update_time'] = Variable<int>(updateTime);
    return map;
  }

  BookChaptersCompanion toCompanion(bool nullToAbsent) {
    return BookChaptersCompanion(
      bookUrl: Value(bookUrl),
      chapterIndex: Value(chapterIndex),
      title: Value(title),
      chapterUrl: Value(chapterUrl),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      isVolume: Value(isVolume),
      updateTime: Value(updateTime),
    );
  }

  factory BookChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookChapter(
      bookUrl: serializer.fromJson<String>(json['bookUrl']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      title: serializer.fromJson<String>(json['title']),
      chapterUrl: serializer.fromJson<String>(json['chapterUrl']),
      content: serializer.fromJson<String?>(json['content']),
      isVolume: serializer.fromJson<bool>(json['isVolume']),
      updateTime: serializer.fromJson<int>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookUrl': serializer.toJson<String>(bookUrl),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'title': serializer.toJson<String>(title),
      'chapterUrl': serializer.toJson<String>(chapterUrl),
      'content': serializer.toJson<String?>(content),
      'isVolume': serializer.toJson<bool>(isVolume),
      'updateTime': serializer.toJson<int>(updateTime),
    };
  }

  BookChapter copyWith({
    String? bookUrl,
    int? chapterIndex,
    String? title,
    String? chapterUrl,
    Value<String?> content = const Value.absent(),
    bool? isVolume,
    int? updateTime,
  }) => BookChapter(
    bookUrl: bookUrl ?? this.bookUrl,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    title: title ?? this.title,
    chapterUrl: chapterUrl ?? this.chapterUrl,
    content: content.present ? content.value : this.content,
    isVolume: isVolume ?? this.isVolume,
    updateTime: updateTime ?? this.updateTime,
  );
  BookChapter copyWithCompanion(BookChaptersCompanion data) {
    return BookChapter(
      bookUrl: data.bookUrl.present ? data.bookUrl.value : this.bookUrl,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      title: data.title.present ? data.title.value : this.title,
      chapterUrl: data.chapterUrl.present
          ? data.chapterUrl.value
          : this.chapterUrl,
      content: data.content.present ? data.content.value : this.content,
      isVolume: data.isVolume.present ? data.isVolume.value : this.isVolume,
      updateTime: data.updateTime.present
          ? data.updateTime.value
          : this.updateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookChapter(')
          ..write('bookUrl: $bookUrl, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('content: $content, ')
          ..write('isVolume: $isVolume, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookUrl,
    chapterIndex,
    title,
    chapterUrl,
    content,
    isVolume,
    updateTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookChapter &&
          other.bookUrl == this.bookUrl &&
          other.chapterIndex == this.chapterIndex &&
          other.title == this.title &&
          other.chapterUrl == this.chapterUrl &&
          other.content == this.content &&
          other.isVolume == this.isVolume &&
          other.updateTime == this.updateTime);
}

class BookChaptersCompanion extends UpdateCompanion<BookChapter> {
  final Value<String> bookUrl;
  final Value<int> chapterIndex;
  final Value<String> title;
  final Value<String> chapterUrl;
  final Value<String?> content;
  final Value<bool> isVolume;
  final Value<int> updateTime;
  final Value<int> rowid;
  const BookChaptersCompanion({
    this.bookUrl = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.content = const Value.absent(),
    this.isVolume = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookChaptersCompanion.insert({
    required String bookUrl,
    required int chapterIndex,
    required String title,
    this.chapterUrl = const Value.absent(),
    this.content = const Value.absent(),
    this.isVolume = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookUrl = Value(bookUrl),
       chapterIndex = Value(chapterIndex),
       title = Value(title);
  static Insertable<BookChapter> custom({
    Expression<String>? bookUrl,
    Expression<int>? chapterIndex,
    Expression<String>? title,
    Expression<String>? chapterUrl,
    Expression<String>? content,
    Expression<bool>? isVolume,
    Expression<int>? updateTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookUrl != null) 'book_url': bookUrl,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (title != null) 'title': title,
      if (chapterUrl != null) 'chapter_url': chapterUrl,
      if (content != null) 'content': content,
      if (isVolume != null) 'is_volume': isVolume,
      if (updateTime != null) 'update_time': updateTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookChaptersCompanion copyWith({
    Value<String>? bookUrl,
    Value<int>? chapterIndex,
    Value<String>? title,
    Value<String>? chapterUrl,
    Value<String?>? content,
    Value<bool>? isVolume,
    Value<int>? updateTime,
    Value<int>? rowid,
  }) {
    return BookChaptersCompanion(
      bookUrl: bookUrl ?? this.bookUrl,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      title: title ?? this.title,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      content: content ?? this.content,
      isVolume: isVolume ?? this.isVolume,
      updateTime: updateTime ?? this.updateTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookUrl.present) {
      map['book_url'] = Variable<String>(bookUrl.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (chapterUrl.present) {
      map['chapter_url'] = Variable<String>(chapterUrl.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isVolume.present) {
      map['is_volume'] = Variable<bool>(isVolume.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<int>(updateTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookChaptersCompanion(')
          ..write('bookUrl: $bookUrl, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('content: $content, ')
          ..write('isVolume: $isVolume, ')
          ..write('updateTime: $updateTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderPreferencesTable extends ReaderPreferences
    with TableInfo<$ReaderPreferencesTable, ReaderPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ReaderPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReaderPreferencesTable createAlias(String alias) {
    return $ReaderPreferencesTable(attachedDatabase, alias);
  }
}

class ReaderPreference extends DataClass
    implements Insertable<ReaderPreference> {
  final String key;
  final String value;
  final int updatedAt;
  const ReaderPreference({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ReaderPreferencesCompanion toCompanion(bool nullToAbsent) {
    return ReaderPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReaderPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ReaderPreference copyWith({String? key, String? value, int? updatedAt}) =>
      ReaderPreference(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReaderPreference copyWithCompanion(ReaderPreferencesCompanion data) {
    return ReaderPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderPreference(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderPreference &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class ReaderPreferencesCompanion extends UpdateCompanion<ReaderPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ReaderPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderPreferencesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<ReaderPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReaderPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookSourcesTable bookSources = $BookSourcesTable(this);
  late final $BookChaptersTable bookChapters = $BookChaptersTable(this);
  late final $ReaderPreferencesTable readerPreferences =
      $ReaderPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    bookSources,
    bookChapters,
    readerPreferences,
  ];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String bookUrl,
      Value<String> tocUrl,
      Value<String> origin,
      Value<String> originName,
      required String name,
      Value<String> author,
      Value<String?> coverUrl,
      Value<String?> intro,
      Value<int> totalChapterNum,
      Value<int> durChapterIndex,
      Value<int> durChapterPos,
      Value<int> durChapterTime,
      Value<int> lastCheckTime,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> bookUrl,
      Value<String> tocUrl,
      Value<String> origin,
      Value<String> originName,
      Value<String> name,
      Value<String> author,
      Value<String?> coverUrl,
      Value<String?> intro,
      Value<int> totalChapterNum,
      Value<int> durChapterIndex,
      Value<int> durChapterPos,
      Value<int> durChapterTime,
      Value<int> lastCheckTime,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookUrl => $composableBuilder(
    column: $table.bookUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tocUrl => $composableBuilder(
    column: $table.tocUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originName => $composableBuilder(
    column: $table.originName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intro => $composableBuilder(
    column: $table.intro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalChapterNum => $composableBuilder(
    column: $table.totalChapterNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durChapterIndex => $composableBuilder(
    column: $table.durChapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durChapterPos => $composableBuilder(
    column: $table.durChapterPos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durChapterTime => $composableBuilder(
    column: $table.durChapterTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCheckTime => $composableBuilder(
    column: $table.lastCheckTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookUrl => $composableBuilder(
    column: $table.bookUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tocUrl => $composableBuilder(
    column: $table.tocUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originName => $composableBuilder(
    column: $table.originName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intro => $composableBuilder(
    column: $table.intro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalChapterNum => $composableBuilder(
    column: $table.totalChapterNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durChapterIndex => $composableBuilder(
    column: $table.durChapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durChapterPos => $composableBuilder(
    column: $table.durChapterPos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durChapterTime => $composableBuilder(
    column: $table.durChapterTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCheckTime => $composableBuilder(
    column: $table.lastCheckTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookUrl =>
      $composableBuilder(column: $table.bookUrl, builder: (column) => column);

  GeneratedColumn<String> get tocUrl =>
      $composableBuilder(column: $table.tocUrl, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get originName => $composableBuilder(
    column: $table.originName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<int> get totalChapterNum => $composableBuilder(
    column: $table.totalChapterNum,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durChapterIndex => $composableBuilder(
    column: $table.durChapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durChapterPos => $composableBuilder(
    column: $table.durChapterPos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durChapterTime => $composableBuilder(
    column: $table.durChapterTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCheckTime => $composableBuilder(
    column: $table.lastCheckTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookUrl = const Value.absent(),
                Value<String> tocUrl = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> originName = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> intro = const Value.absent(),
                Value<int> totalChapterNum = const Value.absent(),
                Value<int> durChapterIndex = const Value.absent(),
                Value<int> durChapterPos = const Value.absent(),
                Value<int> durChapterTime = const Value.absent(),
                Value<int> lastCheckTime = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                bookUrl: bookUrl,
                tocUrl: tocUrl,
                origin: origin,
                originName: originName,
                name: name,
                author: author,
                coverUrl: coverUrl,
                intro: intro,
                totalChapterNum: totalChapterNum,
                durChapterIndex: durChapterIndex,
                durChapterPos: durChapterPos,
                durChapterTime: durChapterTime,
                lastCheckTime: lastCheckTime,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookUrl,
                Value<String> tocUrl = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> originName = const Value.absent(),
                required String name,
                Value<String> author = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> intro = const Value.absent(),
                Value<int> totalChapterNum = const Value.absent(),
                Value<int> durChapterIndex = const Value.absent(),
                Value<int> durChapterPos = const Value.absent(),
                Value<int> durChapterTime = const Value.absent(),
                Value<int> lastCheckTime = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                bookUrl: bookUrl,
                tocUrl: tocUrl,
                origin: origin,
                originName: originName,
                name: name,
                author: author,
                coverUrl: coverUrl,
                intro: intro,
                totalChapterNum: totalChapterNum,
                durChapterIndex: durChapterIndex,
                durChapterPos: durChapterPos,
                durChapterTime: durChapterTime,
                lastCheckTime: lastCheckTime,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;
typedef $$BookSourcesTableCreateCompanionBuilder =
    BookSourcesCompanion Function({
      required String bookSourceUrl,
      required String bookSourceName,
      Value<String?> bookSourceGroup,
      Value<int> bookSourceType,
      Value<String?> bookUrlPattern,
      Value<int> customOrder,
      Value<bool> enabled,
      Value<bool> enabledExplore,
      Value<String?> jsLib,
      Value<bool> enabledCookieJar,
      Value<String?> concurrentRate,
      Value<String?> header,
      Value<String?> loginUrl,
      Value<String?> loginUi,
      Value<String?> loginCheckJs,
      Value<String?> coverDecodeJs,
      Value<String?> bookSourceComment,
      Value<String?> variableComment,
      Value<int> lastUpdateTime,
      Value<int> respondTime,
      Value<int> weight,
      Value<String?> exploreUrl,
      Value<String?> exploreScreen,
      Value<String?> ruleExplore,
      Value<String?> searchUrl,
      Value<String?> ruleSearch,
      Value<String?> ruleBookInfo,
      Value<String?> ruleToc,
      Value<String?> ruleContent,
      Value<String?> ruleReview,
      Value<int> rowid,
    });
typedef $$BookSourcesTableUpdateCompanionBuilder =
    BookSourcesCompanion Function({
      Value<String> bookSourceUrl,
      Value<String> bookSourceName,
      Value<String?> bookSourceGroup,
      Value<int> bookSourceType,
      Value<String?> bookUrlPattern,
      Value<int> customOrder,
      Value<bool> enabled,
      Value<bool> enabledExplore,
      Value<String?> jsLib,
      Value<bool> enabledCookieJar,
      Value<String?> concurrentRate,
      Value<String?> header,
      Value<String?> loginUrl,
      Value<String?> loginUi,
      Value<String?> loginCheckJs,
      Value<String?> coverDecodeJs,
      Value<String?> bookSourceComment,
      Value<String?> variableComment,
      Value<int> lastUpdateTime,
      Value<int> respondTime,
      Value<int> weight,
      Value<String?> exploreUrl,
      Value<String?> exploreScreen,
      Value<String?> ruleExplore,
      Value<String?> searchUrl,
      Value<String?> ruleSearch,
      Value<String?> ruleBookInfo,
      Value<String?> ruleToc,
      Value<String?> ruleContent,
      Value<String?> ruleReview,
      Value<int> rowid,
    });

class $$BookSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookSourceUrl => $composableBuilder(
    column: $table.bookSourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookSourceName => $composableBuilder(
    column: $table.bookSourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookSourceGroup => $composableBuilder(
    column: $table.bookSourceGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookSourceType => $composableBuilder(
    column: $table.bookSourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookUrlPattern => $composableBuilder(
    column: $table.bookUrlPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customOrder => $composableBuilder(
    column: $table.customOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabledExplore => $composableBuilder(
    column: $table.enabledExplore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsLib => $composableBuilder(
    column: $table.jsLib,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabledCookieJar => $composableBuilder(
    column: $table.enabledCookieJar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concurrentRate => $composableBuilder(
    column: $table.concurrentRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginUrl => $composableBuilder(
    column: $table.loginUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginUi => $composableBuilder(
    column: $table.loginUi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginCheckJs => $composableBuilder(
    column: $table.loginCheckJs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverDecodeJs => $composableBuilder(
    column: $table.coverDecodeJs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookSourceComment => $composableBuilder(
    column: $table.bookSourceComment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variableComment => $composableBuilder(
    column: $table.variableComment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respondTime => $composableBuilder(
    column: $table.respondTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exploreUrl => $composableBuilder(
    column: $table.exploreUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exploreScreen => $composableBuilder(
    column: $table.exploreScreen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleExplore => $composableBuilder(
    column: $table.ruleExplore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchUrl => $composableBuilder(
    column: $table.searchUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleSearch => $composableBuilder(
    column: $table.ruleSearch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleBookInfo => $composableBuilder(
    column: $table.ruleBookInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleToc => $composableBuilder(
    column: $table.ruleToc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleContent => $composableBuilder(
    column: $table.ruleContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleReview => $composableBuilder(
    column: $table.ruleReview,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookSourceUrl => $composableBuilder(
    column: $table.bookSourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookSourceName => $composableBuilder(
    column: $table.bookSourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookSourceGroup => $composableBuilder(
    column: $table.bookSourceGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookSourceType => $composableBuilder(
    column: $table.bookSourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookUrlPattern => $composableBuilder(
    column: $table.bookUrlPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customOrder => $composableBuilder(
    column: $table.customOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabledExplore => $composableBuilder(
    column: $table.enabledExplore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsLib => $composableBuilder(
    column: $table.jsLib,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabledCookieJar => $composableBuilder(
    column: $table.enabledCookieJar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concurrentRate => $composableBuilder(
    column: $table.concurrentRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginUrl => $composableBuilder(
    column: $table.loginUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginUi => $composableBuilder(
    column: $table.loginUi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginCheckJs => $composableBuilder(
    column: $table.loginCheckJs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverDecodeJs => $composableBuilder(
    column: $table.coverDecodeJs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookSourceComment => $composableBuilder(
    column: $table.bookSourceComment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variableComment => $composableBuilder(
    column: $table.variableComment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respondTime => $composableBuilder(
    column: $table.respondTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exploreUrl => $composableBuilder(
    column: $table.exploreUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exploreScreen => $composableBuilder(
    column: $table.exploreScreen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleExplore => $composableBuilder(
    column: $table.ruleExplore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchUrl => $composableBuilder(
    column: $table.searchUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleSearch => $composableBuilder(
    column: $table.ruleSearch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleBookInfo => $composableBuilder(
    column: $table.ruleBookInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleToc => $composableBuilder(
    column: $table.ruleToc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleContent => $composableBuilder(
    column: $table.ruleContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleReview => $composableBuilder(
    column: $table.ruleReview,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookSourceUrl => $composableBuilder(
    column: $table.bookSourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookSourceName => $composableBuilder(
    column: $table.bookSourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookSourceGroup => $composableBuilder(
    column: $table.bookSourceGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bookSourceType => $composableBuilder(
    column: $table.bookSourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookUrlPattern => $composableBuilder(
    column: $table.bookUrlPattern,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customOrder => $composableBuilder(
    column: $table.customOrder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get enabledExplore => $composableBuilder(
    column: $table.enabledExplore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsLib =>
      $composableBuilder(column: $table.jsLib, builder: (column) => column);

  GeneratedColumn<bool> get enabledCookieJar => $composableBuilder(
    column: $table.enabledCookieJar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concurrentRate => $composableBuilder(
    column: $table.concurrentRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get header =>
      $composableBuilder(column: $table.header, builder: (column) => column);

  GeneratedColumn<String> get loginUrl =>
      $composableBuilder(column: $table.loginUrl, builder: (column) => column);

  GeneratedColumn<String> get loginUi =>
      $composableBuilder(column: $table.loginUi, builder: (column) => column);

  GeneratedColumn<String> get loginCheckJs => $composableBuilder(
    column: $table.loginCheckJs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverDecodeJs => $composableBuilder(
    column: $table.coverDecodeJs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookSourceComment => $composableBuilder(
    column: $table.bookSourceComment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variableComment => $composableBuilder(
    column: $table.variableComment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUpdateTime => $composableBuilder(
    column: $table.lastUpdateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get respondTime => $composableBuilder(
    column: $table.respondTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get exploreUrl => $composableBuilder(
    column: $table.exploreUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exploreScreen => $composableBuilder(
    column: $table.exploreScreen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleExplore => $composableBuilder(
    column: $table.ruleExplore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchUrl =>
      $composableBuilder(column: $table.searchUrl, builder: (column) => column);

  GeneratedColumn<String> get ruleSearch => $composableBuilder(
    column: $table.ruleSearch,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleBookInfo => $composableBuilder(
    column: $table.ruleBookInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleToc =>
      $composableBuilder(column: $table.ruleToc, builder: (column) => column);

  GeneratedColumn<String> get ruleContent => $composableBuilder(
    column: $table.ruleContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleReview => $composableBuilder(
    column: $table.ruleReview,
    builder: (column) => column,
  );
}

class $$BookSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookSourcesTable,
          BookSource,
          $$BookSourcesTableFilterComposer,
          $$BookSourcesTableOrderingComposer,
          $$BookSourcesTableAnnotationComposer,
          $$BookSourcesTableCreateCompanionBuilder,
          $$BookSourcesTableUpdateCompanionBuilder,
          (
            BookSource,
            BaseReferences<_$AppDatabase, $BookSourcesTable, BookSource>,
          ),
          BookSource,
          PrefetchHooks Function()
        > {
  $$BookSourcesTableTableManager(_$AppDatabase db, $BookSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookSourceUrl = const Value.absent(),
                Value<String> bookSourceName = const Value.absent(),
                Value<String?> bookSourceGroup = const Value.absent(),
                Value<int> bookSourceType = const Value.absent(),
                Value<String?> bookUrlPattern = const Value.absent(),
                Value<int> customOrder = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> enabledExplore = const Value.absent(),
                Value<String?> jsLib = const Value.absent(),
                Value<bool> enabledCookieJar = const Value.absent(),
                Value<String?> concurrentRate = const Value.absent(),
                Value<String?> header = const Value.absent(),
                Value<String?> loginUrl = const Value.absent(),
                Value<String?> loginUi = const Value.absent(),
                Value<String?> loginCheckJs = const Value.absent(),
                Value<String?> coverDecodeJs = const Value.absent(),
                Value<String?> bookSourceComment = const Value.absent(),
                Value<String?> variableComment = const Value.absent(),
                Value<int> lastUpdateTime = const Value.absent(),
                Value<int> respondTime = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<String?> exploreUrl = const Value.absent(),
                Value<String?> exploreScreen = const Value.absent(),
                Value<String?> ruleExplore = const Value.absent(),
                Value<String?> searchUrl = const Value.absent(),
                Value<String?> ruleSearch = const Value.absent(),
                Value<String?> ruleBookInfo = const Value.absent(),
                Value<String?> ruleToc = const Value.absent(),
                Value<String?> ruleContent = const Value.absent(),
                Value<String?> ruleReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookSourcesCompanion(
                bookSourceUrl: bookSourceUrl,
                bookSourceName: bookSourceName,
                bookSourceGroup: bookSourceGroup,
                bookSourceType: bookSourceType,
                bookUrlPattern: bookUrlPattern,
                customOrder: customOrder,
                enabled: enabled,
                enabledExplore: enabledExplore,
                jsLib: jsLib,
                enabledCookieJar: enabledCookieJar,
                concurrentRate: concurrentRate,
                header: header,
                loginUrl: loginUrl,
                loginUi: loginUi,
                loginCheckJs: loginCheckJs,
                coverDecodeJs: coverDecodeJs,
                bookSourceComment: bookSourceComment,
                variableComment: variableComment,
                lastUpdateTime: lastUpdateTime,
                respondTime: respondTime,
                weight: weight,
                exploreUrl: exploreUrl,
                exploreScreen: exploreScreen,
                ruleExplore: ruleExplore,
                searchUrl: searchUrl,
                ruleSearch: ruleSearch,
                ruleBookInfo: ruleBookInfo,
                ruleToc: ruleToc,
                ruleContent: ruleContent,
                ruleReview: ruleReview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookSourceUrl,
                required String bookSourceName,
                Value<String?> bookSourceGroup = const Value.absent(),
                Value<int> bookSourceType = const Value.absent(),
                Value<String?> bookUrlPattern = const Value.absent(),
                Value<int> customOrder = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> enabledExplore = const Value.absent(),
                Value<String?> jsLib = const Value.absent(),
                Value<bool> enabledCookieJar = const Value.absent(),
                Value<String?> concurrentRate = const Value.absent(),
                Value<String?> header = const Value.absent(),
                Value<String?> loginUrl = const Value.absent(),
                Value<String?> loginUi = const Value.absent(),
                Value<String?> loginCheckJs = const Value.absent(),
                Value<String?> coverDecodeJs = const Value.absent(),
                Value<String?> bookSourceComment = const Value.absent(),
                Value<String?> variableComment = const Value.absent(),
                Value<int> lastUpdateTime = const Value.absent(),
                Value<int> respondTime = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<String?> exploreUrl = const Value.absent(),
                Value<String?> exploreScreen = const Value.absent(),
                Value<String?> ruleExplore = const Value.absent(),
                Value<String?> searchUrl = const Value.absent(),
                Value<String?> ruleSearch = const Value.absent(),
                Value<String?> ruleBookInfo = const Value.absent(),
                Value<String?> ruleToc = const Value.absent(),
                Value<String?> ruleContent = const Value.absent(),
                Value<String?> ruleReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookSourcesCompanion.insert(
                bookSourceUrl: bookSourceUrl,
                bookSourceName: bookSourceName,
                bookSourceGroup: bookSourceGroup,
                bookSourceType: bookSourceType,
                bookUrlPattern: bookUrlPattern,
                customOrder: customOrder,
                enabled: enabled,
                enabledExplore: enabledExplore,
                jsLib: jsLib,
                enabledCookieJar: enabledCookieJar,
                concurrentRate: concurrentRate,
                header: header,
                loginUrl: loginUrl,
                loginUi: loginUi,
                loginCheckJs: loginCheckJs,
                coverDecodeJs: coverDecodeJs,
                bookSourceComment: bookSourceComment,
                variableComment: variableComment,
                lastUpdateTime: lastUpdateTime,
                respondTime: respondTime,
                weight: weight,
                exploreUrl: exploreUrl,
                exploreScreen: exploreScreen,
                ruleExplore: ruleExplore,
                searchUrl: searchUrl,
                ruleSearch: ruleSearch,
                ruleBookInfo: ruleBookInfo,
                ruleToc: ruleToc,
                ruleContent: ruleContent,
                ruleReview: ruleReview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookSourcesTable,
      BookSource,
      $$BookSourcesTableFilterComposer,
      $$BookSourcesTableOrderingComposer,
      $$BookSourcesTableAnnotationComposer,
      $$BookSourcesTableCreateCompanionBuilder,
      $$BookSourcesTableUpdateCompanionBuilder,
      (
        BookSource,
        BaseReferences<_$AppDatabase, $BookSourcesTable, BookSource>,
      ),
      BookSource,
      PrefetchHooks Function()
    >;
typedef $$BookChaptersTableCreateCompanionBuilder =
    BookChaptersCompanion Function({
      required String bookUrl,
      required int chapterIndex,
      required String title,
      Value<String> chapterUrl,
      Value<String?> content,
      Value<bool> isVolume,
      Value<int> updateTime,
      Value<int> rowid,
    });
typedef $$BookChaptersTableUpdateCompanionBuilder =
    BookChaptersCompanion Function({
      Value<String> bookUrl,
      Value<int> chapterIndex,
      Value<String> title,
      Value<String> chapterUrl,
      Value<String?> content,
      Value<bool> isVolume,
      Value<int> updateTime,
      Value<int> rowid,
    });

class $$BookChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookUrl => $composableBuilder(
    column: $table.bookUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVolume => $composableBuilder(
    column: $table.isVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookUrl => $composableBuilder(
    column: $table.bookUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVolume => $composableBuilder(
    column: $table.isVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookUrl =>
      $composableBuilder(column: $table.bookUrl, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isVolume =>
      $composableBuilder(column: $table.isVolume, builder: (column) => column);

  GeneratedColumn<int> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => column,
  );
}

class $$BookChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookChaptersTable,
          BookChapter,
          $$BookChaptersTableFilterComposer,
          $$BookChaptersTableOrderingComposer,
          $$BookChaptersTableAnnotationComposer,
          $$BookChaptersTableCreateCompanionBuilder,
          $$BookChaptersTableUpdateCompanionBuilder,
          (
            BookChapter,
            BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapter>,
          ),
          BookChapter,
          PrefetchHooks Function()
        > {
  $$BookChaptersTableTableManager(_$AppDatabase db, $BookChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookUrl = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> chapterUrl = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<bool> isVolume = const Value.absent(),
                Value<int> updateTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookChaptersCompanion(
                bookUrl: bookUrl,
                chapterIndex: chapterIndex,
                title: title,
                chapterUrl: chapterUrl,
                content: content,
                isVolume: isVolume,
                updateTime: updateTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookUrl,
                required int chapterIndex,
                required String title,
                Value<String> chapterUrl = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<bool> isVolume = const Value.absent(),
                Value<int> updateTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookChaptersCompanion.insert(
                bookUrl: bookUrl,
                chapterIndex: chapterIndex,
                title: title,
                chapterUrl: chapterUrl,
                content: content,
                isVolume: isVolume,
                updateTime: updateTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookChaptersTable,
      BookChapter,
      $$BookChaptersTableFilterComposer,
      $$BookChaptersTableOrderingComposer,
      $$BookChaptersTableAnnotationComposer,
      $$BookChaptersTableCreateCompanionBuilder,
      $$BookChaptersTableUpdateCompanionBuilder,
      (
        BookChapter,
        BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapter>,
      ),
      BookChapter,
      PrefetchHooks Function()
    >;
typedef $$ReaderPreferencesTableCreateCompanionBuilder =
    ReaderPreferencesCompanion Function({
      required String key,
      Value<String> value,
      Value<int> updatedAt,
      Value<int> rowid,
    });
typedef $$ReaderPreferencesTableUpdateCompanionBuilder =
    ReaderPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ReaderPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderPreferencesTable> {
  $$ReaderPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReaderPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderPreferencesTable> {
  $$ReaderPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReaderPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderPreferencesTable> {
  $$ReaderPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReaderPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderPreferencesTable,
          ReaderPreference,
          $$ReaderPreferencesTableFilterComposer,
          $$ReaderPreferencesTableOrderingComposer,
          $$ReaderPreferencesTableAnnotationComposer,
          $$ReaderPreferencesTableCreateCompanionBuilder,
          $$ReaderPreferencesTableUpdateCompanionBuilder,
          (
            ReaderPreference,
            BaseReferences<
              _$AppDatabase,
              $ReaderPreferencesTable,
              ReaderPreference
            >,
          ),
          ReaderPreference,
          PrefetchHooks Function()
        > {
  $$ReaderPreferencesTableTableManager(
    _$AppDatabase db,
    $ReaderPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReaderPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderPreferencesTable,
      ReaderPreference,
      $$ReaderPreferencesTableFilterComposer,
      $$ReaderPreferencesTableOrderingComposer,
      $$ReaderPreferencesTableAnnotationComposer,
      $$ReaderPreferencesTableCreateCompanionBuilder,
      $$ReaderPreferencesTableUpdateCompanionBuilder,
      (
        ReaderPreference,
        BaseReferences<
          _$AppDatabase,
          $ReaderPreferencesTable,
          ReaderPreference
        >,
      ),
      ReaderPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookSourcesTableTableManager get bookSources =>
      $$BookSourcesTableTableManager(_db, _db.bookSources);
  $$BookChaptersTableTableManager get bookChapters =>
      $$BookChaptersTableTableManager(_db, _db.bookChapters);
  $$ReaderPreferencesTableTableManager get readerPreferences =>
      $$ReaderPreferencesTableTableManager(_db, _db.readerPreferences);
}
