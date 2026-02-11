import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class ParsedLegadoBookInfo {
  const ParsedLegadoBookInfo({
    this.name,
    this.author,
    this.intro,
    this.kind,
    this.wordCount,
    this.latestChapter,
    this.updateTime,
    this.bookUrl,
    this.tocUrl,
    this.coverUrl,
    this.downloadUrls = const [],
    this.canRenameRule = false,
  });

  final String? name;
  final String? author;
  final String? intro;
  final String? kind;
  final String? wordCount;
  final String? latestChapter;
  final String? updateTime;
  final String? bookUrl;
  final String? tocUrl;
  final String? coverUrl;
  final List<String> downloadUrls;
  final bool canRenameRule;
}

class LegadoBookInfoAnalyzer {
  const LegadoBookInfoAnalyzer();

  Map<String, dynamic> decodeRules(String rawRuleBookInfo) {
    dynamic cursor = rawRuleBookInfo;
    for (var index = 0; index < 2; index++) {
      if (cursor is String) {
        final trimmed = cursor.trim();
        if (trimmed.isEmpty) {
          return const {};
        }
        try {
          cursor = jsonDecode(trimmed);
        } catch (_) {
          return const {};
        }
        continue;
      }

      if (cursor is Map<String, dynamic>) {
        return cursor;
      }
      if (cursor is Map) {
        return cursor.map((key, value) => MapEntry('$key', value));
      }
      return const {};
    }
    return const {};
  }

  String? buildInfoUrl({
    required Map<String, dynamic> rules,
    required String fallbackBookUrl,
    required String sourceBaseUrl,
  }) {
    final template =
        _asRuleString(rules['url']) ??
        _asRuleString(rules['infoUrl']) ??
        fallbackBookUrl;
    final trimmedTemplate = template.trim();
    if (trimmedTemplate.isEmpty) {
      return null;
    }

    final rendered = trimmedTemplate
        .replaceAll('{{bookUrl}}', Uri.encodeComponent(fallbackBookUrl))
        .replaceAll('{{bookUrlRaw}}', fallbackBookUrl);

    return _resolveUrlWithBase(rawUrl: rendered, baseUrl: sourceBaseUrl);
  }

  ParsedLegadoBookInfo parseResponse({
    required String responseBody,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final body = responseBody.trim();
    if (body.isEmpty) {
      return ParsedLegadoBookInfo(
        canRenameRule: _asRuleString(rules['canReName']) != null,
      );
    }

    final canRenameRule = _asRuleString(rules['canReName']) != null;

    if (body.startsWith('{') || body.startsWith('[')) {
      final decoded = _decodeAnyJson(body);
      if (decoded == null) {
        return ParsedLegadoBookInfo(canRenameRule: canRenameRule);
      }

      final initRule = _asRuleString(rules['init']);
      final root = initRule == null || initRule.isEmpty
          ? decoded
          : (_readPath(decoded, initRule) ?? decoded);

      final bookUrl = _toText(_readPath(root, _asRuleString(rules['bookUrl'])));
      final tocUrl = _toText(_readPath(root, _asRuleString(rules['tocUrl'])));
      final coverUrl = _toText(
        _readPath(root, _asRuleString(rules['coverUrl'])),
      );

      return ParsedLegadoBookInfo(
        name: _toText(_readPath(root, _asRuleString(rules['name']) ?? 'name')),
        author: _toText(
          _readPath(root, _asRuleString(rules['author']) ?? 'author'),
        ),
        intro: _toText(
          _readPath(root, _asRuleString(rules['intro']) ?? 'intro'),
        ),
        kind: _toJoinedText(
          _readPath(root, _asRuleString(rules['kind'])),
          separator: ',',
        ),
        wordCount: _toText(_readPath(root, _asRuleString(rules['wordCount']))),
        latestChapter: _toText(
          _readPath(root, _asRuleString(rules['lastChapter'])),
        ),
        updateTime: _toText(
          _readPath(root, _asRuleString(rules['updateTime'])),
        ),
        bookUrl: _resolveUrlWithBase(rawUrl: bookUrl, baseUrl: pageUrl),
        tocUrl: _resolveUrlWithBase(rawUrl: tocUrl, baseUrl: pageUrl),
        coverUrl: _resolveUrlWithBase(rawUrl: coverUrl, baseUrl: pageUrl),
        downloadUrls: _resolveUrlListWithBase(
          rawUrls: _toStringList(
            _readPath(root, _asRuleString(rules['downloadUrls'])),
          ),
          baseUrl: pageUrl,
        ),
        canRenameRule: canRenameRule,
      );
    }

    final document = html_parser.parse(body);
    final initRule = _asRuleString(rules['init']);
    final initElement = initRule == null || initRule.isEmpty
        ? document.body
        : document.querySelector(initRule);
    final scopeElement = initElement ?? document.body;
    if (scopeElement == null) {
      return ParsedLegadoBookInfo(canRenameRule: canRenameRule);
    }

    final rootRule =
        _asRuleString(rules['bookInfo']) ?? _asRuleString(rules['bookList']);
    final rootElement = rootRule == null || rootRule.isEmpty
        ? scopeElement
        : scopeElement.querySelector(rootRule);
    if (rootElement == null) {
      return ParsedLegadoBookInfo(canRenameRule: canRenameRule);
    }

    final bookUrl = _extractFromHtml(
      rootElement,
      _asRuleString(rules['bookUrl']),
    );
    final tocUrl = _extractFromHtml(
      rootElement,
      _asRuleString(rules['tocUrl']),
    );
    final coverUrl = _extractFromHtml(
      rootElement,
      _asRuleString(rules['coverUrl']),
    );

    return ParsedLegadoBookInfo(
      name: _extractFromHtml(rootElement, _asRuleString(rules['name']) ?? 'h1'),
      author: _extractFromHtml(rootElement, _asRuleString(rules['author'])),
      intro: _extractFromHtml(rootElement, _asRuleString(rules['intro'])),
      kind: _extractFromHtml(rootElement, _asRuleString(rules['kind'])),
      wordCount: _extractFromHtml(
        rootElement,
        _asRuleString(rules['wordCount']),
      ),
      latestChapter: _extractFromHtml(
        rootElement,
        _asRuleString(rules['lastChapter']),
      ),
      updateTime: _extractFromHtml(
        rootElement,
        _asRuleString(rules['updateTime']),
      ),
      bookUrl: _resolveUrlWithBase(rawUrl: bookUrl, baseUrl: pageUrl),
      tocUrl: _resolveUrlWithBase(rawUrl: tocUrl, baseUrl: pageUrl),
      coverUrl: _resolveUrlWithBase(rawUrl: coverUrl, baseUrl: pageUrl),
      downloadUrls: _resolveUrlListWithBase(
        rawUrls: _extractListFromHtml(
          rootElement,
          _asRuleString(rules['downloadUrls']),
        ),
        baseUrl: pageUrl,
      ),
      canRenameRule: canRenameRule,
    );
  }

  dynamic _decodeAnyJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
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

  List<String> _extractListFromHtml(dom.Element element, String? rule) {
    if (rule == null || rule.trim().isEmpty) {
      return const [];
    }

    final trimmed = rule.trim();
    if (trimmed.startsWith('@')) {
      final value = element.attributes[trimmed.substring(1)]?.trim();
      if (value == null || value.isEmpty) {
        return const [];
      }
      return [value];
    }

    final atIndex = trimmed.lastIndexOf('@');
    if (atIndex > 0) {
      final selector = trimmed.substring(0, atIndex).trim();
      final attr = trimmed.substring(atIndex + 1).trim();
      final elements = selector.isEmpty
          ? <dom.Element>[element]
          : element.querySelectorAll(selector);
      if (elements.isEmpty) {
        return const [];
      }

      final values = <String>[];
      for (final current in elements) {
        if (attr.isEmpty || attr == 'text') {
          final text = current.text.trim();
          if (text.isNotEmpty) {
            values.add(text);
          }
          continue;
        }
        final attrValue = current.attributes[attr]?.trim();
        if (attrValue != null && attrValue.isNotEmpty) {
          values.add(attrValue);
        }
      }
      return values;
    }

    final elements = element.querySelectorAll(trimmed);
    if (elements.isEmpty) {
      final single = _extractFromHtml(element, trimmed);
      if (single == null || single.isEmpty) {
        return const [];
      }
      return [single];
    }

    final values = <String>[];
    for (final current in elements) {
      final text = current.text.trim();
      if (text.isNotEmpty) {
        values.add(text);
      }
    }
    return values;
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

  List<String> _resolveUrlListWithBase({
    required List<String> rawUrls,
    required String baseUrl,
  }) {
    if (rawUrls.isEmpty) {
      return const [];
    }

    final values = <String>[];
    for (final rawUrl in rawUrls) {
      final resolved = _resolveUrlWithBase(rawUrl: rawUrl, baseUrl: baseUrl);
      if (resolved != null && resolved.isNotEmpty) {
        values.add(resolved);
      }
    }
    return values;
  }

  dynamic _readPath(dynamic root, String? path) {
    if (path == null || path.isEmpty) {
      return root;
    }

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
      if (match == null) {
        return null;
      }

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

  String? _toJoinedText(dynamic value, {required String separator}) {
    final values = _toStringList(value);
    if (values.isEmpty) {
      return null;
    }
    return values.join(separator);
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) {
      return const [];
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? const [] : [trimmed];
    }
    if (value is num || value is bool) {
      return [value.toString()];
    }
    if (value is List) {
      final values = <String>[];
      for (final current in value) {
        final text = _toText(current);
        if (text != null && text.isNotEmpty) {
          values.add(text);
        }
      }
      return values;
    }
    return const [];
  }

  String? _asRuleString(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
}
