import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/reader/domain/services/legado_reader_service.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class _MemoryBookshelfRepository implements BookshelfRepository {
  final Map<String, BookEntity> _store = {};

  @override
  Future<List<BookEntity>> getBookshelf() async {
    return _store.values.toList(growable: false);
  }

  @override
  Future<void> removeBook(String bookUrl) async {
    _store.remove(bookUrl);
  }

  @override
  Future<void> saveBook(BookEntity book) async {
    _store[book.bookUrl] = book;
  }

  @override
  Stream<List<BookEntity>> watchBookshelf() {
    return Stream.value(_store.values.toList(growable: false));
  }
}

class _MemorySourceRepository implements BookSourceRepository {
  final Map<String, BookSourceEntity> _store;

  _MemorySourceRepository(this._store);

  List<BookSourceEntity> _sortedSources() {
    final list = _store.values.toList(growable: false);
    list.sort((a, b) {
      final orderCompare = a.customOrder.compareTo(b.customOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return a.bookSourceName.compareTo(b.bookSourceName);
    });
    return list;
  }

  @override
  Future<BookSourceEntity?> findBookSourceByUrl(String sourceUrl) async {
    return _store[sourceUrl];
  }

  @override
  Future<List<BookSourceEntity>> getBookSources({bool? enabled}) async {
    final list = _sortedSources();
    if (enabled == null) {
      return list;
    }
    return list.where((source) => source.enabled == enabled).toList();
  }

  @override
  Future<void> removeBookSource(String sourceUrl) async {
    _store.remove(sourceUrl);
  }

  @override
  Future<void> saveBookSource(BookSourceEntity source) async {
    _store[source.bookSourceUrl] = source;
  }

  @override
  Future<void> saveBookSources(List<BookSourceEntity> sources) async {
    for (final source in sources) {
      _store[source.bookSourceUrl] = source;
    }
  }

  @override
  Future<void> setBookSourceEnabled(String sourceUrl, bool enabled) async {
    final source = _store[sourceUrl];
    if (source == null) {
      return;
    }
    _store[sourceUrl] = BookSourceEntity(
      bookSourceUrl: source.bookSourceUrl,
      bookSourceName: source.bookSourceName,
      bookSourceGroup: source.bookSourceGroup,
      bookSourceType: source.bookSourceType,
      bookUrlPattern: source.bookUrlPattern,
      customOrder: source.customOrder,
      enabled: enabled,
      enabledExplore: source.enabledExplore,
      jsLib: source.jsLib,
      enabledCookieJar: source.enabledCookieJar,
      concurrentRate: source.concurrentRate,
      header: source.header,
      loginUrl: source.loginUrl,
      loginUi: source.loginUi,
      loginCheckJs: source.loginCheckJs,
      coverDecodeJs: source.coverDecodeJs,
      bookSourceComment: source.bookSourceComment,
      variableComment: source.variableComment,
      lastUpdateTime: source.lastUpdateTime,
      respondTime: source.respondTime,
      weight: source.weight,
      exploreUrl: source.exploreUrl,
      exploreScreen: source.exploreScreen,
      ruleExplore: source.ruleExplore,
      searchUrl: source.searchUrl,
      ruleSearch: source.ruleSearch,
      ruleBookInfo: source.ruleBookInfo,
      ruleToc: source.ruleToc,
      ruleContent: source.ruleContent,
      ruleReview: source.ruleReview,
    );
  }

  @override
  Future<void> moveBookSourceToTop(String sourceUrl) async {
    final source = _store[sourceUrl];
    if (source == null) {
      return;
    }
    final minOrder = _store.values.map((item) => item.customOrder).fold<int>(
      0,
      (previousValue, element) {
        return element < previousValue ? element : previousValue;
      },
    );
    _store[sourceUrl] = BookSourceEntity(
      bookSourceUrl: source.bookSourceUrl,
      bookSourceName: source.bookSourceName,
      bookSourceGroup: source.bookSourceGroup,
      bookSourceType: source.bookSourceType,
      bookUrlPattern: source.bookUrlPattern,
      customOrder: minOrder - 1,
      enabled: source.enabled,
      enabledExplore: source.enabledExplore,
      jsLib: source.jsLib,
      enabledCookieJar: source.enabledCookieJar,
      concurrentRate: source.concurrentRate,
      header: source.header,
      loginUrl: source.loginUrl,
      loginUi: source.loginUi,
      loginCheckJs: source.loginCheckJs,
      coverDecodeJs: source.coverDecodeJs,
      bookSourceComment: source.bookSourceComment,
      variableComment: source.variableComment,
      lastUpdateTime: source.lastUpdateTime,
      respondTime: source.respondTime,
      weight: source.weight,
      exploreUrl: source.exploreUrl,
      exploreScreen: source.exploreScreen,
      ruleExplore: source.ruleExplore,
      searchUrl: source.searchUrl,
      ruleSearch: source.ruleSearch,
      ruleBookInfo: source.ruleBookInfo,
      ruleToc: source.ruleToc,
      ruleContent: source.ruleContent,
      ruleReview: source.ruleReview,
    );
  }

  @override
  Future<void> moveBookSourceToBottom(String sourceUrl) async {
    final source = _store[sourceUrl];
    if (source == null) {
      return;
    }
    final maxOrder = _store.values.map((item) => item.customOrder).fold<int>(
      0,
      (previousValue, element) {
        return element > previousValue ? element : previousValue;
      },
    );
    _store[sourceUrl] = BookSourceEntity(
      bookSourceUrl: source.bookSourceUrl,
      bookSourceName: source.bookSourceName,
      bookSourceGroup: source.bookSourceGroup,
      bookSourceType: source.bookSourceType,
      bookUrlPattern: source.bookUrlPattern,
      customOrder: maxOrder + 1,
      enabled: source.enabled,
      enabledExplore: source.enabledExplore,
      jsLib: source.jsLib,
      enabledCookieJar: source.enabledCookieJar,
      concurrentRate: source.concurrentRate,
      header: source.header,
      loginUrl: source.loginUrl,
      loginUi: source.loginUi,
      loginCheckJs: source.loginCheckJs,
      coverDecodeJs: source.coverDecodeJs,
      bookSourceComment: source.bookSourceComment,
      variableComment: source.variableComment,
      lastUpdateTime: source.lastUpdateTime,
      respondTime: source.respondTime,
      weight: source.weight,
      exploreUrl: source.exploreUrl,
      exploreScreen: source.exploreScreen,
      ruleExplore: source.ruleExplore,
      searchUrl: source.searchUrl,
      ruleSearch: source.ruleSearch,
      ruleBookInfo: source.ruleBookInfo,
      ruleToc: source.ruleToc,
      ruleContent: source.ruleContent,
      ruleReview: source.ruleReview,
    );
  }

  @override
  Stream<List<BookSourceEntity>> watchBookSources({bool? enabled}) {
    return Stream.value(_sortedSources());
  }
}

void main() {
  group('LegadoReaderService', () {
    late _MemoryBookshelfRepository bookshelfRepository;
    late _MemorySourceRepository sourceRepository;
    late LegadoReaderService service;

    setUp(() {
      bookshelfRepository = _MemoryBookshelfRepository();
      sourceRepository = _MemorySourceRepository({
        'mock://search': BookSourceEntity(
          bookSourceUrl: 'mock://search',
          bookSourceName: 'Mock源',
          ruleBookInfo: jsonEncode({
            'url': 'mock://book-info?book={{bookUrl}}',
            'name': 'name',
            'author': 'author',
            'intro': 'intro',
            'kind': 'kind',
            'wordCount': 'wordCount',
            'lastChapter': 'lastChapter',
            'updateTime': 'updateTime',
            'coverUrl': 'coverUrl',
            'tocUrl': 'tocUrl',
            'canReName': 'allowRename',
          }),
          ruleToc: jsonEncode({
            'url': 'mock://toc?book={{bookUrl}}',
            'chapterList': 'chapters',
            'chapterName': 'title',
            'chapterUrl': 'url',
          }),
          ruleContent: jsonEncode({'content': 'content'}),
        ),
        'mock://toc-fallback': BookSourceEntity(
          bookSourceUrl: 'mock://toc-fallback',
          bookSourceName: 'TOC回退源',
          ruleToc: jsonEncode({
            'chapterList': 'chapters',
            'chapterName': 'title',
            'chapterUrl': 'url',
          }),
          ruleContent: jsonEncode({'content': 'content'}),
        ),
      });

      service = LegadoReaderService(
        httpGateway: LegadoHttpGateway(Dio()),
        sourceRepository: sourceRepository,
        bookshelfRepository: bookshelfRepository,
      );
    });

    test('可加入书架', () async {
      final saved = await service.addSearchResultToBookshelf(
        sourceUrl: 'mock://search',
        name: '测试书',
        author: '作者',
        bookUrl: 'mock-book-1',
        coverUrl: null,
        intro: '简介',
      );

      expect(saved.bookUrl, 'mock-book-1');
      final list = await bookshelfRepository.getBookshelf();
      expect(list, hasLength(1));
      expect(list.first.name, '测试书');
    });

    test('可抓取详情并对齐 ruleBookInfo 字段', () async {
      final info = await service.fetchBookInfo(
        sourceUrl: 'mock://search',
        fallbackName: '搜索名',
        fallbackAuthor: '搜索作者',
        fallbackBookUrl: 'mock-book-2',
      );

      expect(info.name, 'Mock 纪元（详情）');
      expect(info.author, 'Mock作者B');
      expect(info.kind, '轻小说,冒险');
      expect(info.wordCount, '66万字');
      expect(info.latestChapter, '第661章 回声');
      expect(info.tocUrl, 'mock://toc?book=mock-book-2');
    });

    test('禁用改名时保留搜索结果名作者', () async {
      final info = await service.fetchBookInfo(
        sourceUrl: 'mock://search',
        fallbackName: '搜索名',
        fallbackAuthor: '搜索作者',
        fallbackBookUrl: 'mock-book-1',
        canReName: false,
      );

      expect(info.name, '搜索名');
      expect(info.author, '搜索作者');
      expect(info.intro, contains('mock-book-1'));
      expect(info.tocUrl, 'mock://toc?book=mock-book-1');
    });

    test('ruleToc 无 url 时可回退使用 tocUrl', () async {
      final chapters = await service.fetchChapters(
        sourceUrl: 'mock://toc-fallback',
        bookUrl: 'mock-book-1',
        tocUrl: 'mock://toc?book=mock-book-1',
      );

      expect(chapters, isNotEmpty);
      expect(chapters.first.title, '第1章');
    });

    test('ruleToc 无 url 且 tocUrl 相对路径时按 bookUrl 回退', () async {
      sourceRepository = _MemorySourceRepository({
        'mock://relative-toc': BookSourceEntity(
          bookSourceUrl: 'mock://relative-toc',
          bookSourceName: '相对目录源',
          ruleToc: jsonEncode({
            'chapterList': 'chapters',
            'chapterName': 'title',
            'chapterUrl': 'url',
          }),
          ruleContent: jsonEncode({'content': 'content'}),
        ),
      });
      service = LegadoReaderService(
        httpGateway: LegadoHttpGateway(Dio()),
        sourceRepository: sourceRepository,
        bookshelfRepository: bookshelfRepository,
      );

      final chapters = await service.fetchChapters(
        sourceUrl: 'mock://relative-toc',
        bookUrl: 'mock://search/book/1',
        tocUrl: '//toc?book=mock-book-1',
      );

      expect(chapters, isNotEmpty);
      expect(chapters.first.title, '第1章');
    });

    test('可抓取目录与正文', () async {
      final chapters = await service.fetchChapters(
        sourceUrl: 'mock://search',
        bookUrl: 'mock-book-1',
      );

      expect(chapters, isNotEmpty);
      expect(chapters.first.title, contains('第1章'));

      final content = await service.fetchChapterContent(
        sourceUrl: 'mock://search',
        bookUrl: 'mock-book-1',
        chapter: chapters.first,
      );

      expect(content, isNotNull);
      expect(content, contains('正文示例'));
    });
  });
}
