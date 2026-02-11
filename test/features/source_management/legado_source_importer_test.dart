import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/features/source_management/application/legado_source_importer.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class _MemoryBookSourceRepository implements BookSourceRepository {
  final Map<String, BookSourceEntity> _store = {};

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
    if (enabled == null) return list;
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
  group('LegadoSourceImporter', () {
    late _MemoryBookSourceRepository repository;
    late LegadoSourceImporter importer;

    setUp(() {
      repository = _MemoryBookSourceRepository();
      importer = LegadoSourceImporter(repository);
    });

    test('可导入 legado 书源数组', () async {
      final payload = [
        {
          'bookSourceUrl': 'https://openlibrary.org',
          'bookSourceName': 'OpenLibrary',
          'searchUrl': 'https://openlibrary.org/search.json?q={{key}}',
          'ruleSearch': {'bookList': 'docs', 'name': 'title'},
          'enabled': true,
        },
      ];

      final result = await importer.importFromJsonString(jsonEncode(payload));

      expect(result.successCount, 1);
      expect(result.skippedCount, 0);
      final sources = await repository.getBookSources();
      expect(sources, hasLength(1));
      expect(sources.first.bookSourceUrl, 'https://openlibrary.org');
      expect(sources.first.ruleSearch, isNotNull);
    });

    test('缺失关键字段会被跳过', () async {
      final payload = [
        {'bookSourceName': 'NoUrl'},
      ];

      final result = await importer.importFromJsonString(jsonEncode(payload));

      expect(result.successCount, 0);
      expect(result.skippedCount, 1);
      final sources = await repository.getBookSources();
      expect(sources, isEmpty);
    });
  });
}
