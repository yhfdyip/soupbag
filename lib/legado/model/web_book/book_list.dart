import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class ParsedLegadoBookListItem {
  const ParsedLegadoBookListItem({
    required this.name,
    required this.bookUrl,
    this.author,
    this.coverUrl,
    this.intro,
    this.kind,
    this.wordCount,
    this.latestChapter,
  });

  final String name;
  final String bookUrl;
  final String? author;
  final String? coverUrl;
  final String? intro;
  final String? kind;
  final String? wordCount;
  final String? latestChapter;
}

class LegadoBookListAnalyzer {
  const LegadoBookListAnalyzer();

  Map<String, dynamic> decodeRules(String rawRuleSearch) {
    dynamic cursor = rawRuleSearch;
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

  List<ParsedLegadoBookListItem> parse({
    required String responseBody,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final body = responseBody.trim();
    if (body.isEmpty) {
      return const [];
    }

    if (body.startsWith('{') || body.startsWith('[')) {
      return _parseJsonResponse(body: body, rules: rules, pageUrl: pageUrl);
    }

    return _parseHtmlResponse(body: body, rules: rules, pageUrl: pageUrl);
  }

  List<ParsedLegadoBookListItem> _parseJsonResponse({
    required String body,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final root = _decodeAnyJson(body);
    if (root == null) {
      return const [];
    }

    final listRuleResult = _normalizeListRule(_asRuleString(rules['bookList']));
    final dynamic rawList =
        listRuleResult.rule == null || listRuleResult.rule!.isEmpty
        ? root
        : _readPath(root, listRuleResult.rule!);

    final items = _normalizeEntryList(rawList, fallback: root);
    if (items.isEmpty) {
      return const [];
    }

    final books = <ParsedLegadoBookListItem>[];
    for (final entry in items) {
      final parsed = _parseJsonItem(
        entry: entry,
        rules: rules,
        pageUrl: pageUrl,
      );
      if (parsed != null) {
        books.add(parsed);
      }
    }

    if (listRuleResult.reverse) {
      return books.reversed.toList(growable: false);
    }
    return books;
  }

  ParsedLegadoBookListItem? _parseJsonItem({
    required dynamic entry,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final name = _toText(
      _readPath(entry, _asRuleString(rules['name']) ?? 'name'),
    );
    if (name == null || name.isEmpty) {
      return null;
    }

    final bookUrlRaw = _toText(
      _readPath(entry, _asRuleString(rules['bookUrl']) ?? 'bookUrl'),
    );
    final resolvedBookUrl =
        _resolveUrlWithBase(rawUrl: bookUrlRaw, baseUrl: pageUrl) ?? pageUrl;

    final coverUrlRaw = _toText(
      _readPath(entry, _asRuleString(rules['coverUrl'])),
    );

    return ParsedLegadoBookListItem(
      name: name,
      author: _toText(
        _readPath(entry, _asRuleString(rules['author']) ?? 'author'),
      ),
      bookUrl: resolvedBookUrl,
      coverUrl: _resolveUrlWithBase(rawUrl: coverUrlRaw, baseUrl: pageUrl),
      intro: _toText(
        _readPath(entry, _asRuleString(rules['intro']) ?? 'intro'),
      ),
      kind: _toJoinedText(
        _readPath(entry, _asRuleString(rules['kind'])),
        separator: ',',
      ),
      wordCount: _toText(_readPath(entry, _asRuleString(rules['wordCount']))),
      latestChapter: _toText(
        _readPath(entry, _asRuleString(rules['lastChapter'])),
      ),
    );
  }

  List<ParsedLegadoBookListItem> _parseHtmlResponse({
    required String body,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final document = html_parser.parse(body);
    final listRuleResult = _normalizeListRule(_asRuleString(rules['bookList']));

    final elements = listRuleResult.rule == null || listRuleResult.rule!.isEmpty
        ? <dom.Element>[if (document.body != null) document.body!]
        : document.querySelectorAll(listRuleResult.rule!);

    if (elements.isEmpty) {
      return const [];
    }

    final books = <ParsedLegadoBookListItem>[];
    for (final element in elements) {
      final parsed = _parseHtmlItem(
        element: element,
        rules: rules,
        pageUrl: pageUrl,
      );
      if (parsed != null) {
        books.add(parsed);
      }
    }

    if (listRuleResult.reverse) {
      return books.reversed.toList(growable: false);
    }
    return books;
  }

  ParsedLegadoBookListItem? _parseHtmlItem({
    required dom.Element element,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final nameRule = _asRuleString(rules['name']) ?? 'h1';
    final name = _extractFromHtml(element, nameRule);
    if (name == null || name.isEmpty) {
      return null;
    }

    final bookUrlRaw = _extractFromHtml(
      element,
      _asRuleString(rules['bookUrl']) ?? '@href',
    );
    final resolvedBookUrl =
        _resolveUrlWithBase(rawUrl: bookUrlRaw, baseUrl: pageUrl) ?? pageUrl;

    final coverUrlRaw = _extractFromHtml(
      element,
      _asRuleString(rules['coverUrl']),
    );

    return ParsedLegadoBookListItem(
      name: name,
      author: _extractFromHtml(element, _asRuleString(rules['author'])),
      bookUrl: resolvedBookUrl,
      coverUrl: _resolveUrlWithBase(rawUrl: coverUrlRaw, baseUrl: pageUrl),
      intro: _extractFromHtml(element, _asRuleString(rules['intro'])),
      kind: _toJoinedText(
        _extractListFromHtml(element, _asRuleString(rules['kind'])),
        separator: ',',
      ),
      wordCount: _extractFromHtml(element, _asRuleString(rules['wordCount'])),
      latestChapter: _extractFromHtml(
        element,
        _asRuleString(rules['lastChapter']),
      ),
    );
  }

  _ListRuleResult _normalizeListRule(String? rawRule) {
    if (rawRule == null || rawRule.isEmpty) {
      return const _ListRuleResult(rule: null, reverse: false);
    }

    var rule = rawRule.trim();
    var reverse = false;
    if (rule.startsWith('-')) {
      reverse = true;
      rule = rule.substring(1).trim();
    }
    if (rule.startsWith('+')) {
      rule = rule.substring(1).trim();
    }

    return _ListRuleResult(rule: rule.isEmpty ? null : rule, reverse: reverse);
  }

  List<dynamic> _normalizeEntryList(
    dynamic rawList, {
    required dynamic fallback,
  }) {
    if (rawList is List) {
      return rawList;
    }
    if (rawList is Map || rawList is Map<String, dynamic>) {
      return [rawList];
    }
    if (fallback is List) {
      return fallback;
    }
    if (fallback is Map || fallback is Map<String, dynamic>) {
      return [fallback];
    }
    return const [];
  }

  dynamic _decodeAnyJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
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

  String? _toText(dynamic value) {
    if (value == null) {
      return null;
    }
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
    if (value is List) {
      final parts = value
          .map(_toText)
          .whereType<String>()
          .where((text) => text.isNotEmpty)
          .toList(growable: false);
      if (parts.isEmpty) {
        return null;
      }
      return parts.join(separator);
    }

    return _toText(value);
  }

  String? _asRuleString(dynamic value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
}

class _ListRuleResult {
  const _ListRuleResult({required this.rule, required this.reverse});

  final String? rule;
  final bool reverse;
}
