import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/discovery/domain/services/legado_search_service.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class _MemorySourceRepository implements BookSourceRepository {
  _MemorySourceRepository(this._store);

  final Map<String, BookSourceEntity> _store;

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
  group('LegadoSearchService', () {
    late LegadoSearchService service;

    setUp(() {
      final repository = _MemorySourceRepository({
        'mock://search': BookSourceEntity(
          bookSourceUrl: 'mock://search',
          bookSourceName: 'Mock搜索源',
          enabled: true,
          enabledExplore: true,
          searchUrl: 'mock://search?key={{key}}&page={{page}}',
          ruleSearch: jsonEncode({
            'bookList': 'books',
            'name': 'name',
            'author': 'author',
            'bookUrl': 'bookUrl',
            'coverUrl': 'coverUrl',
            'intro': 'intro',
            'kind': 'kind',
            'wordCount': 'wordCount',
            'lastChapter': 'lastChapter',
          }),
          exploreUrl: jsonEncode([
            {
              'title': '推荐',
              'url': 'mock://explore?page={{page}}',
              'style': {
                'layout_flexBasisPercent': 0.5,
                'layout_alignSelf': 'center',
              },
            },
            {'title': '热门', 'url': 'mock://explore-hot?page={{page}}'},
          ]),
          exploreScreen: jsonEncode([
            {
              'title': '热门',
              'style': {
                'layout_alignSelf': 'flex_end',
                'layout_flexBasisPercent': 1,
              },
            },
          ]),
          ruleExplore: jsonEncode({
            'bookList': 'books',
            'name': 'name',
            'author': 'author',
            'bookUrl': 'bookUrl',
            'coverUrl': 'coverUrl',
            'intro': 'intro',
            'kind': 'kind',
            'wordCount': 'wordCount',
            'lastChapter': 'lastChapter',
          }),
        ),
        'mock://search-b': BookSourceEntity(
          bookSourceUrl: 'mock://search-b',
          bookSourceName: 'Mock搜索源B',
          enabled: true,
          enabledExplore: true,
          searchUrl: 'mock://search?key={{key}}&page={{page}}',
          ruleSearch: jsonEncode({
            'bookList': 'books',
            'name': 'name',
            'author': 'author',
            'bookUrl': 'bookUrl',
            'coverUrl': 'coverUrl',
            'intro': 'intro',
            'kind': 'kind',
            'wordCount': 'wordCount',
            'lastChapter': 'lastChapter',
          }),
          exploreUrl: '热门::mock://explore-hot?page={{page}}',
          ruleExplore: jsonEncode({
            'bookList': 'books',
            'name': 'name',
            'author': 'author',
            'bookUrl': 'bookUrl',
            'coverUrl': 'coverUrl',
            'intro': 'intro',
            'kind': 'kind',
            'wordCount': 'wordCount',
            'lastChapter': 'lastChapter',
          }),
        ),
      });

      service = LegadoSearchService(
        httpGateway: LegadoHttpGateway(Dio()),
        sourceRepository: repository,
      );
    });

    test('search 可返回结果', () async {
      final results = await service.search('测试');

      expect(results, isNotEmpty);
      expect(results.first.sourceUrl, 'mock://search');
      expect(results.first.name, contains('测试'));
    });

    test('search 命中详情页链接时按详情规则返回单本结果', () async {
      final detailRepository = _MemorySourceRepository({
        'mock://detail-search': BookSourceEntity(
          bookSourceUrl: 'mock://detail-search',
          bookSourceName: '详情搜索源',
          enabled: true,
          searchUrl: 'mock://book-info?book=mock-book-1',
          bookUrlPattern: r'^mock://book-info\?.+$',
          ruleSearch: jsonEncode({
            'bookList': 'books',
            'name': 'name',
            'author': 'author',
            'bookUrl': 'bookUrl',
          }),
          ruleBookInfo: jsonEncode({
            'name': 'name',
            'author': 'author',
            'intro': 'intro',
            'kind': 'kind',
            'wordCount': 'wordCount',
            'lastChapter': 'lastChapter',
            'coverUrl': 'coverUrl',
            'tocUrl': 'tocUrl',
          }),
        ),
      });
      final detailService = LegadoSearchService(
        httpGateway: LegadoHttpGateway(Dio()),
        sourceRepository: detailRepository,
      );

      final results = await detailService.search('任意关键词');

      expect(results, hasLength(1));
      expect(results.first.name, 'Mock 冒险（详情）');
      expect(results.first.author, 'Mock作者A');
      expect(results.first.bookUrl, 'mock://book-info?book=mock-book-1');
      expect(results.first.latestChapter, '第520章 归来');
    });

    test('search 聚合同名结果并统计来源数', () async {
      final results = await service.search('测试');

      expect(results, isNotEmpty);
      final merged = results.firstWhere((item) => item.name == '测试 的冒险');
      expect(merged.originCount, 2);
      expect(merged.origins.length, 2);
      expect(
        merged.origins.map((item) => item.sourceUrl),
        containsAll(['mock://search', 'mock://search-b']),
      );
      expect(results.length, 2);
    });

    test('explore 默认取首个分类结果', () async {
      final results = await service.explore(page: 2);

      expect(results, isNotEmpty);
      expect(results.first.sourceUrl, 'mock://search');
      expect(results.first.name, contains('推荐 榜单 2'));
    });

    test('getExploreKinds 可返回分类列表与样式信息', () async {
      final groups = await service.getExploreKinds();

      expect(groups.length, greaterThanOrEqualTo(2));

      final mainSource = groups.firstWhere(
        (group) => group.sourceUrl == 'mock://search',
      );

      expect(mainSource.kinds, hasLength(2));
      expect(mainSource.kinds.first.title, '推荐');
      expect(mainSource.kinds.first.exploreUrl, 'mock://explore?page={{page}}');
      expect(mainSource.kinds.first.style, isNotNull);
      expect(mainSource.kinds.first.style!.layoutFlexBasisPercent, 0.5);
      expect(mainSource.kinds.first.style!.layoutAlignSelf, 'center');

      expect(mainSource.kinds.last.title, '热门');
      expect(
        mainSource.kinds.last.exploreUrl,
        'mock://explore-hot?page={{page}}',
      );
      expect(mainSource.kinds.last.style, isNotNull);
      expect(mainSource.kinds.last.style!.layoutAlignSelf, 'flex_end');
      expect(mainSource.kinds.last.style!.layoutFlexBasisPercent, 1);
    });

    test('explore 支持按分类 URL 加载结果', () async {
      final results = await service.explore(
        page: 3,
        exploreUrl: 'mock://explore-hot?page={{page}}',
      );

      expect(results, isNotEmpty);
      expect(results.first.name, contains('热门 榜单 3'));
    });

    test('explore 聚合同名结果并统计来源数', () async {
      final results = await service.explore(
        page: 1,
        exploreUrl: 'mock://explore-hot?page={{page}}',
      );

      expect(results, isNotEmpty);
      final merged = results.firstWhere((item) => item.name == '热门 榜单 1-A');
      expect(merged.originCount, 2);
      expect(merged.origins.length, 2);
      expect(
        merged.origins.map((item) => item.sourceUrl),
        containsAll(['mock://search', 'mock://search-b']),
      );
      expect(results.length, 2);
    });

    test('explore 按分类点击时仅请求目标书源', () async {
      final results = await service.explore(
        page: 1,
        sourceUrl: 'mock://search',
        exploreUrl: 'mock://explore-hot?page={{page}}',
      );

      expect(results, isNotEmpty);
      expect(
        results.every((item) => item.sourceUrl == 'mock://search'),
        isTrue,
      );
      expect(results.first.name, contains('热门 榜单 1'));
    });
  });
}
