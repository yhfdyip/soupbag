import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class LegadoBookContentAnalyzer {
  const LegadoBookContentAnalyzer();

  Map<String, dynamic> decodeRules(String rawRuleContent) {
    try {
      final decoded = jsonDecode(rawRuleContent);
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

  String? parseContent({
    required String responseBody,
    required Map<String, dynamic> rules,
    required String pageUrl,
  }) {
    final body = responseBody.trim();
    if (body.isEmpty) {
      return null;
    }

    final contentRule = _asRuleString(rules['content']) ?? 'content';

    if (body.startsWith('{') || body.startsWith('[')) {
      final root = _decodeAnyJson(body);
      if (root == null) {
        return null;
      }
      return _toText(_readPath(root, contentRule));
    }

    final document = html_parser.parse(body);
    final root = document.body;
    if (root == null) {
      return null;
    }

    return _extractFromHtml(root, contentRule, pageUrl: pageUrl);
  }

  dynamic _decodeAnyJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  dynamic _readPath(dynamic root, String path) {
    if (path.isEmpty) {
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

  String? _extractFromHtml(
    dom.Element element,
    String rule, {
    required String pageUrl,
  }) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) {
      final text = element.text.trim();
      return text.isEmpty ? null : text;
    }

    if (trimmed == 'text') {
      final text = element.text.trim();
      return text.isEmpty ? null : text;
    }

    if (trimmed.startsWith('@')) {
      final value = element.attributes[trimmed.substring(1)]?.trim();
      return value == null || value.isEmpty ? null : value;
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
      if (attrValue == null || attrValue.isEmpty) {
        return null;
      }
      return _resolveUrlWithBase(rawUrl: attrValue, baseUrl: pageUrl) ??
          attrValue;
    }

    final target = element.querySelector(trimmed);
    if (target == null) {
      return null;
    }

    final text = target.text.trim();
    return text.isEmpty ? null : text;
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
