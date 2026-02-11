import 'dart:convert';

import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class LegadoReaderService {
  LegadoReaderService({
    required LegadoHttpGateway httpGateway,
    required BookSourceRepository sourceRepository,
    required BookshelfRepository bookshelfRepository,
  })  : _httpGateway = httpGateway,
        _sourceRepository = sourceRepository,
        _bookshelfRepository = bookshelfRepository;

  final LegadoHttpGateway _httpGateway;
  final BookSourceRepository _sourceRepository;
  final BookshelfRepository _bookshelfRepository;

  Future<BookEntity> addSearchResultToBookshelf({
    required String sourceUrl,
    required String name,
    required String? author,
    required String? bookUrl,
    required String? coverUrl,
    required String? intro,
  }) async {
    final realBookUrl = (bookUrl == null || bookUrl.trim().isEmpty)
        ? 'generated://book/${DateTime.now().millisecondsSinceEpoch}'
        : bookUrl.trim();

    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final now = DateTime.now().millisecondsSinceEpoch;

    final book = BookEntity(
      bookUrl: realBookUrl,
      tocUrl: realBookUrl,
      origin: sourceUrl,
      originName: source?.bookSourceName ?? sourceUrl,
      name: name,
      author: author ?? '',
      coverUrl: coverUrl,
      intro: intro,
      durChapterTime: now,
      createdAt: now,
      updatedAt: now,
      lastCheckTime: now,
    );

    await _bookshelfRepository.saveBook(book);
    return book;
  }

  Future<List<ChapterEntity>> fetchChapters({
    required String sourceUrl,
    required String bookUrl,
  }) async {
    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final ruleTocRaw = source?.ruleToc;
    if (source == null || ruleTocRaw == null || ruleTocRaw.trim().isEmpty) {
      return const [];
    }

    final ruleToc = _decodeJson(ruleTocRaw);
    final tocUrlTemplate = _asString(ruleToc['url']);
    final chapterListPath = _asString(ruleToc['chapterList']) ?? 'chapters';
    final chapterNamePath = _asString(ruleToc['chapterName']) ?? 'title';
    final chapterUrlPath = _asString(ruleToc['chapterUrl']) ?? 'url';

    if (tocUrlTemplate == null || tocUrlTemplate.isEmpty) {
      return const [];
    }

    final tocUrl = tocUrlTemplate.replaceAll('{{bookUrl}}', Uri.encodeComponent(bookUrl));

    final body = await _httpGateway.get(
      tocUrl,
      headers: _parseHeader(source.header),
    );

    final dynamic root = _decodeAnyJson(body);
    if (root == null) {
      return const [];
    }

    final dynamic chapterListRaw = _readPath(root, chapterListPath);
    if (chapterListRaw is! List) {
      return const [];
    }

    final chapters = <ChapterEntity>[];
    for (var i = 0; i < chapterListRaw.length; i++) {
      final entry = chapterListRaw[i];
      final name = _toText(_readPath(entry, chapterNamePath));
      final chapterUrl = _toText(_readPath(entry, chapterUrlPath));
      if (name == null || name.isEmpty) {
        continue;
      }
      chapters.add(
        ChapterEntity(
          bookUrl: bookUrl,
          chapterIndex: i,
          title: name,
          chapterUrl: chapterUrl ?? '',
          updateTime: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    return chapters;
  }

  Future<String?> fetchChapterContent({
    required String sourceUrl,
    required String bookUrl,
    required ChapterEntity chapter,
  }) async {
    if (chapter.chapterUrl.trim().isEmpty) {
      return null;
    }

    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final ruleContentRaw = source?.ruleContent;
    if (source == null || ruleContentRaw == null || ruleContentRaw.trim().isEmpty) {
      return null;
    }

    final ruleContent = _decodeJson(ruleContentRaw);
    final contentPath = _asString(ruleContent['content']) ?? 'content';

    final body = await _httpGateway.get(
      chapter.chapterUrl,
      headers: _parseHeader(source.header),
    );

    final dynamic root = _decodeAnyJson(body);
    if (root == null) {
      return null;
    }

    return _toText(_readPath(root, contentPath));
  }

  dynamic _decodeAnyJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }

  dynamic _readPath(dynamic root, String path) {
    if (path.isEmpty) return root;
    final normalized = path.startsWith(r'$.')
        ? path.substring(2)
        : path.startsWith(r'$')
            ? path.substring(1)
            : path;

    final segments = normalized
        .split('.')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    dynamic cursor = root;
    for (final segment in segments) {
      final match = RegExp(r'^([^\[\]]+)(?:\[(\d+)\])?$').firstMatch(segment);
      if (match == null) return null;

      final key = match.group(1)!;
      final indexString = match.group(2);

      if (cursor is Map<String, dynamic>) {
        cursor = cursor[key];
      } else if (cursor is Map) {
        cursor = cursor[key];
      } else if (cursor is List) {
        final index = int.tryParse(key);
        if (index == null || index < 0 || index >= cursor.length) {
          return null;
        }
        cursor = cursor[index];
      } else {
        return null;
      }

      if (indexString != null) {
        final index = int.tryParse(indexString);
        if (index == null || cursor is! List || index < 0 || index >= cursor.length) {
          return null;
        }
        cursor = cursor[index];
      }
    }

    return cursor;
  }

  String? _toText(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is List) {
      final merged = value
          .map(_toText)
          .whereType<String>()
          .where((text) => text.isNotEmpty)
          .join(' ')
          .trim();
      return merged.isEmpty ? null : merged;
    }
    return null;
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  Map<String, String>? _parseHeader(String? rawHeader) {
    if (rawHeader == null || rawHeader.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawHeader);
      if (decoded is Map) {
        final headers = <String, String>{};
        decoded.forEach((key, value) {
          if (key != null && value != null) {
            headers['$key'] = '$value';
          }
        });
        return headers.isEmpty ? null : headers;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
