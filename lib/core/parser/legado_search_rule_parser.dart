import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class ParsedSearchBook {
  const ParsedSearchBook({
    required this.name,
    this.author,
    this.bookUrl,
    this.coverUrl,
    this.intro,
  });

  final String name;
  final String? author;
  final String? bookUrl;
  final String? coverUrl;
  final String? intro;
}

class LegadoSearchRuleParser {
  List<ParsedSearchBook> parse({
    required String responseBody,
    required String ruleSearchJson,
  }) {
    final rules = _decodeRules(ruleSearchJson);
    if (rules.isEmpty) {
      return const [];
    }

    final body = responseBody.trim();
    if (body.isEmpty) {
      return const [];
    }

    if (body.startsWith('{') || body.startsWith('[')) {
      return _parseJsonResponse(body: body, rules: rules);
    }

    return _parseHtmlResponse(body: body, rules: rules);
  }

  Map<String, dynamic> _decodeRules(String ruleSearchJson) {
    try {
      final decoded = jsonDecode(ruleSearchJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  List<ParsedSearchBook> _parseJsonResponse({
    required String body,
    required Map<String, dynamic> rules,
  }) {
    final dynamic root;
    try {
      root = jsonDecode(body);
    } catch (_) {
      return const [];
    }

    final listRule = _asRuleString(rules['bookList']);
    final dynamic rawList = _readJsonPath(root, listRule);
    if (rawList is! List) {
      return const [];
    }

    final nameRule = _asRuleString(rules['name']);
    final authorRule = _asRuleString(rules['author']);
    final bookUrlRule = _asRuleString(rules['bookUrl']);
    final coverRule = _asRuleString(rules['coverUrl']);
    final introRule = _asRuleString(rules['intro']);

    final books = <ParsedSearchBook>[];
    for (final entry in rawList) {
      final name = _toText(_readJsonPath(entry, nameRule));
      if (name == null || name.isEmpty) {
        continue;
      }
      books.add(
        ParsedSearchBook(
          name: name,
          author: _toText(_readJsonPath(entry, authorRule)),
          bookUrl: _toText(_readJsonPath(entry, bookUrlRule)),
          coverUrl: _toText(_readJsonPath(entry, coverRule)),
          intro: _toText(_readJsonPath(entry, introRule)),
        ),
      );
    }
    return books;
  }

  List<ParsedSearchBook> _parseHtmlResponse({
    required String body,
    required Map<String, dynamic> rules,
  }) {
    final document = html_parser.parse(body);
    final listRule = _asRuleString(rules['bookList']);
    final elements = listRule == null || listRule.isEmpty
        ? <dom.Element>[
            if (document.body != null) document.body!,
          ]
        : document.querySelectorAll(listRule);

    final nameRule = _asRuleString(rules['name']);
    if (nameRule == null || nameRule.isEmpty) {
      return const [];
    }

    final authorRule = _asRuleString(rules['author']);
    final bookUrlRule = _asRuleString(rules['bookUrl']);
    final coverRule = _asRuleString(rules['coverUrl']);
    final introRule = _asRuleString(rules['intro']);

    final books = <ParsedSearchBook>[];
    for (final element in elements) {
      final name = _extractFromHtml(element, nameRule);
      if (name == null || name.isEmpty) {
        continue;
      }
      books.add(
        ParsedSearchBook(
          name: name,
          author: _extractFromHtml(element, authorRule),
          bookUrl: _extractFromHtml(element, bookUrlRule),
          coverUrl: _extractFromHtml(element, coverRule),
          intro: _extractFromHtml(element, introRule),
        ),
      );
    }
    return books;
  }

  dynamic _readJsonPath(dynamic root, String? path) {
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
      final keyMatch = RegExp(r'^([^\[\]]+)(?:\[(\d+)\])?$').firstMatch(segment);
      if (keyMatch == null) {
        return null;
      }

      final key = keyMatch.group(1)!;
      final indexString = keyMatch.group(2);

      if (cursor is Map<String, dynamic>) {
        cursor = cursor[key];
      } else if (cursor is Map) {
        cursor = cursor[key];
      } else if (cursor is List) {
        final directIndex = int.tryParse(key);
        if (directIndex == null || directIndex < 0 || directIndex >= cursor.length) {
          return null;
        }
        cursor = cursor[directIndex];
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

  String? _extractFromHtml(dom.Element element, String? rule) {
    if (rule == null || rule.isEmpty) {
      return null;
    }

    final trimmed = rule.trim();
    if (trimmed == 'text') {
      final text = element.text.trim();
      return text.isEmpty ? null : text;
    }

    if (trimmed.startsWith('@')) {
      final value = element.attributes[trimmed.substring(1)]?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    final atIndex = trimmed.indexOf('@');
    if (atIndex > -1) {
      final selector = trimmed.substring(0, atIndex).trim();
      final attr = trimmed.substring(atIndex + 1).trim();
      final target = selector.isEmpty ? element : element.querySelector(selector);
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

  String? _toText(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is List) {
      final list = value
          .map(_toText)
          .whereType<String>()
          .where((text) => text.isNotEmpty)
          .toList(growable: false);
      if (list.isEmpty) return null;
      return list.join(' ');
    }
    return null;
  }

  String? _asRuleString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
}
