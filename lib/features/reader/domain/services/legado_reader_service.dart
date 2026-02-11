import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class LegadoBookInfo {
  const LegadoBookInfo({
    required this.sourceUrl,
    required this.sourceName,
    required this.name,
    required this.author,
    required this.bookUrl,
    required this.tocUrl,
    this.coverUrl,
    this.intro,
  });

  final String sourceUrl;
  final String sourceName;
  final String name;
  final String author;
  final String bookUrl;
  final String tocUrl;
  final String? coverUrl;
  final String? intro;
}

class LegadoReaderService {
  LegadoReaderService({
    required LegadoHttpGateway httpGateway,
    required BookSourceRepository sourceRepository,
    required BookshelfRepository bookshelfRepository,
  }) : _httpGateway = httpGateway,
       _sourceRepository = sourceRepository,
       _bookshelfRepository = bookshelfRepository;

  final LegadoHttpGateway _httpGateway;
  final BookSourceRepository _sourceRepository;
  final BookshelfRepository _bookshelfRepository;

  Future<LegadoBookInfo> fetchBookInfo({
    required String sourceUrl,
    required String fallbackName,
    String? fallbackAuthor,
    String? fallbackBookUrl,
    String? fallbackCoverUrl,
    String? fallbackIntro,
  }) async {
    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final sourceName = source?.bookSourceName ?? sourceUrl;

    var name = fallbackName.trim().isEmpty ? '未命名书籍' : fallbackName.trim();
    var author = (fallbackAuthor ?? '').trim();
    var bookUrl = (fallbackBookUrl ?? '').trim();
    var tocUrl = '';
    var coverUrl = (fallbackCoverUrl ?? '').trim();
    var intro = (fallbackIntro ?? '').trim();

    if (bookUrl.isEmpty) {
      bookUrl = 'generated://book/${DateTime.now().millisecondsSinceEpoch}';
    }
    tocUrl = bookUrl;

    final rawRuleBookInfo = source?.ruleBookInfo;
    if (source != null &&
        rawRuleBookInfo != null &&
        rawRuleBookInfo.trim().isNotEmpty) {
      final rules = _decodeJson(rawRuleBookInfo);
      final infoUrlTemplate =
          _asString(rules['url']) ?? _asString(rules['infoUrl']) ?? bookUrl;
      final infoUrl = _buildInfoUrl(
        infoUrlTemplate: infoUrlTemplate,
        fallbackBookUrl: bookUrl,
        sourceBaseUrl: source.bookSourceUrl,
      );

      if (infoUrl != null && infoUrl.isNotEmpty) {
        try {
          final body = await _httpGateway.get(
            infoUrl,
            headers: _parseHeader(source.header),
          );

          final parsed = _parseBookInfoResponse(
            responseBody: body,
            rules: rules,
            pageUrl: infoUrl,
          );

          final parsedName = _asString(parsed['name']);
          final parsedAuthor = _asString(parsed['author']);
          final parsedIntro = _asString(parsed['intro']);
          final parsedCoverUrl = _asString(parsed['coverUrl']);
          final parsedBookUrl = _asString(parsed['bookUrl']);
          final parsedTocUrl = _asString(parsed['tocUrl']);

          if (parsedName != null && parsedName.isNotEmpty) {
            name = parsedName;
          }
          if (parsedAuthor != null && parsedAuthor.isNotEmpty) {
            author = parsedAuthor;
          }
          if (parsedIntro != null && parsedIntro.isNotEmpty) {
            intro = parsedIntro;
          }
          if (parsedBookUrl != null && parsedBookUrl.isNotEmpty) {
            bookUrl = parsedBookUrl;
          }
          if (parsedTocUrl != null && parsedTocUrl.isNotEmpty) {
            tocUrl = parsedTocUrl;
          }
          if (parsedCoverUrl != null && parsedCoverUrl.isNotEmpty) {
            coverUrl = parsedCoverUrl;
          }
        } catch (_) {
          // 详情抓取失败时保留搜索结果兜底信息
        }
      }
    }

    if (tocUrl.trim().isEmpty) {
      tocUrl = bookUrl;
    }

    return LegadoBookInfo(
      sourceUrl: sourceUrl,
      sourceName: sourceName,
      name: name,
      author: author,
      bookUrl: bookUrl,
      tocUrl: tocUrl,
      coverUrl: coverUrl.trim().isEmpty ? null : coverUrl,
      intro: intro.trim().isEmpty ? null : intro,
    );
  }

  Future<BookEntity> addSearchResultToBookshelf({
    required String sourceUrl,
    required String name,
    required String? author,
    required String? bookUrl,
    required String? coverUrl,
    required String? intro,
    String? tocUrl,
  }) async {
    final realBookUrl = (bookUrl == null || bookUrl.trim().isEmpty)
        ? 'generated://book/${DateTime.now().millisecondsSinceEpoch}'
        : bookUrl.trim();

    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final now = DateTime.now().millisecondsSinceEpoch;

    final book = BookEntity(
      bookUrl: realBookUrl,
      tocUrl: (tocUrl == null || tocUrl.trim().isEmpty)
          ? realBookUrl
          : tocUrl.trim(),
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

    final tocUrl = tocUrlTemplate.replaceAll(
      '{{bookUrl}}',
      Uri.encodeComponent(bookUrl),
    );

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
    if (source == null ||
        ruleContentRaw == null ||
        ruleContentRaw.trim().isEmpty) {
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

  String? _buildInfoUrl({
    required String infoUrlTemplate,
    required String fallbackBookUrl,
    required String sourceBaseUrl,
  }) {
    final template = infoUrlTemplate.trim();
    if (template.isEmpty) {
      return null;
    }

    final rendered = template
        .replaceAll('{{bookUrl}}', Uri.encodeComponent(fallbackBookUrl))
        .replaceAll('{{bookUrlRaw}}', fallbackBookUrl);

    return _resolveUrlWithBase(rawUrl: rendered, baseUrl: sourceBaseUrl);
  }

  Map<String, String?> _parseBookInfoResponse({
    required String responseBody,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final body = responseBody.trim();
    if (body.isEmpty) {
      return const {};
    }

    if (body.startsWith('{') || body.startsWith('[')) {
      final root = _decodeAnyJson(body);
      if (root == null) {
        return const {};
      }

      final parsed = <String, String?>{
        'name': _toText(_readPath(root, _asString(rules['name']) ?? 'name')),
        'author': _toText(
          _readPath(root, _asString(rules['author']) ?? 'author'),
        ),
        'intro': _toText(_readPath(root, _asString(rules['intro']) ?? 'intro')),
        'bookUrl': _toText(
          _readPath(root, _asString(rules['bookUrl']) ?? 'bookUrl'),
        ),
        'tocUrl': _toText(
          _readPath(root, _asString(rules['tocUrl']) ?? 'tocUrl'),
        ),
        'coverUrl': _toText(
          _readPath(root, _asString(rules['coverUrl']) ?? 'coverUrl'),
        ),
      };

      return {
        'name': parsed['name'],
        'author': parsed['author'],
        'intro': parsed['intro'],
        'bookUrl': _resolveUrlWithBase(
          rawUrl: parsed['bookUrl'],
          baseUrl: pageUrl,
        ),
        'tocUrl': _resolveUrlWithBase(
          rawUrl: parsed['tocUrl'],
          baseUrl: pageUrl,
        ),
        'coverUrl': _resolveUrlWithBase(
          rawUrl: parsed['coverUrl'],
          baseUrl: pageUrl,
        ),
      };
    }

    final document = html_parser.parse(body);
    final rootRule =
        _asString(rules['bookInfo']) ?? _asString(rules['bookList']) ?? '';
    final rootElement = rootRule.trim().isEmpty
        ? document.body
        : document.querySelector(rootRule.trim());
    if (rootElement == null) {
      return const {};
    }

    final name = _extractFromHtml(
      rootElement,
      _asString(rules['name']) ?? 'h1',
    );
    final author = _extractFromHtml(rootElement, _asString(rules['author']));
    final intro = _extractFromHtml(rootElement, _asString(rules['intro']));
    final parsedBookUrl = _extractFromHtml(
      rootElement,
      _asString(rules['bookUrl']),
    );
    final parsedTocUrl = _extractFromHtml(
      rootElement,
      _asString(rules['tocUrl']),
    );
    final parsedCoverUrl = _extractFromHtml(
      rootElement,
      _asString(rules['coverUrl']),
    );

    return {
      'name': name,
      'author': author,
      'intro': intro,
      'bookUrl': _resolveUrlWithBase(rawUrl: parsedBookUrl, baseUrl: pageUrl),
      'tocUrl': _resolveUrlWithBase(rawUrl: parsedTocUrl, baseUrl: pageUrl),
      'coverUrl': _resolveUrlWithBase(rawUrl: parsedCoverUrl, baseUrl: pageUrl),
    };
  }

  String? _extractFromHtml(dom.Element element, String? rule) {
    if (rule == null || rule.trim().isEmpty) {
      return null;
    }

    final trimmed = rule.trim();
    if (trimmed == 'text') {
      final text = element.text.trim();
      return text.isEmpty ? null : text;
    }

    if (trimmed.startsWith('@')) {
      final attrValue = element.attributes[trimmed.substring(1)]?.trim();
      return attrValue == null || attrValue.isEmpty ? null : attrValue;
    }

    final atIndex = trimmed.lastIndexOf('@');
    if (atIndex > 0) {
      final selector = trimmed.substring(0, atIndex).trim();
      final attr = trimmed.substring(atIndex + 1).trim();
      final target = selector.isEmpty
          ? element
          : element.querySelector(selector);
      if (target == null) {
        return null;
      }
      if (attr.isEmpty || attr == 'text') {
        final text = target.text.trim();
        return text.isEmpty ? null : text;
      }
      final attrValue = target.attributes[attr]?.trim();
      return attrValue == null || attrValue.isEmpty ? null : attrValue;
    }

    final selected = element.querySelector(trimmed);
    if (selected != null) {
      final text = selected.text.trim();
      return text.isEmpty ? null : text;
    }

    return null;
  }

  String? _resolveUrlWithBase({
    required String? rawUrl,
    required String baseUrl,
  }) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final trimmed = rawUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return trimmed;
    }

    final base = Uri.tryParse(baseUrl);
    if (base == null) {
      return trimmed;
    }

    return base.resolve(trimmed).toString();
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
        if (index == null ||
            cursor is! List ||
            index < 0 ||
            index >= cursor.length) {
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
