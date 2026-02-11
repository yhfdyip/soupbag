import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/features/source_management/application/legado_source_importer.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class _MemoryBookSourceRepository implements BookSourceRepository {
  final Map<String, BookSourceEntity> _store = {};

  @override
  Future<BookSourceEntity?> findBookSourceByUrl(String sourceUrl) async {
    return _store[sourceUrl];
  }

  @override
  Future<List<BookSourceEntity>> getBookSources({bool? enabled}) async {
    final list = _store.values.toList(growable: false);
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
  Stream<List<BookSourceEntity>> watchBookSources({bool? enabled}) {
    return Stream.value(_store.values.toList(growable: false));
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
          'ruleSearch': {
            'bookList': 'docs',
            'name': 'title',
          },
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
        {
          'bookSourceName': 'NoUrl',
        },
      ];

      final result = await importer.importFromJsonString(jsonEncode(payload));

      expect(result.successCount, 0);
      expect(result.skippedCount, 1);
      final sources = await repository.getBookSources();
      expect(sources, isEmpty);
    });
  });
}
