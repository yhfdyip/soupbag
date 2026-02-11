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
          ruleToc: jsonEncode({
            'url': 'mock://toc?book={{bookUrl}}',
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
