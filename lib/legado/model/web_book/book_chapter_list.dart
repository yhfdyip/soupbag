import 'dart:convert';

import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';

class LegadoBookChapterListAnalyzer {
  const LegadoBookChapterListAnalyzer();

  Map<String, dynamic> decodeRules(String rawRuleToc) {
    try {
      final decoded = jsonDecode(rawRuleToc);
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

  String? buildTocUrl({
    required Map<String, dynamic> rules,
    required String bookUrl,
    String? tocUrl,
    required String sourceBaseUrl,
  }) {
    final template = _asRuleString(rules['url']);
    if (template == null || template.isEmpty) {
      return null;
    }

    final normalizedTocUrl = (tocUrl ?? '').trim();
    final rendered = template
        .replaceAll('{{bookUrl}}', Uri.encodeComponent(bookUrl))
        .replaceAll('{{bookUrlRaw}}', bookUrl)
        .replaceAll('{{tocUrl}}', Uri.encodeComponent(normalizedTocUrl))
        .replaceAll('{{tocUrlRaw}}', normalizedTocUrl);

    return _resolveUrlWithBase(rawUrl: rendered, baseUrl: sourceBaseUrl);
  }

  List<ChapterEntity> parseChapterList({
    required String responseBody,
    required Map<String, dynamic> rules,
    required String bookUrl,
    required String pageUrl,
    required int updateTime,
  }) {
    final root = _decodeAnyJson(responseBody);
    if (root == null) {
      return const [];
    }

    final chapterListPath = _asRuleString(rules['chapterList']) ?? 'chapters';
    final chapterNamePath = _asRuleString(rules['chapterName']) ?? 'title';
    final chapterUrlPath = _asRuleString(rules['chapterUrl']) ?? 'url';

    final chapterListRaw = _readPath(root, chapterListPath);
    if (chapterListRaw is! List) {
      return const [];
    }

    final chapters = <ChapterEntity>[];
    for (var index = 0; index < chapterListRaw.length; index++) {
      final entry = chapterListRaw[index];
      final chapterName = _toText(_readPath(entry, chapterNamePath));
      if (chapterName == null || chapterName.isEmpty) {
        continue;
      }

      final chapterUrl = _toText(_readPath(entry, chapterUrlPath));
      chapters.add(
        ChapterEntity(
          bookUrl: bookUrl,
          chapterIndex: index,
          title: chapterName,
          chapterUrl:
              _resolveUrlWithBase(rawUrl: chapterUrl, baseUrl: pageUrl) ?? '',
          updateTime: updateTime,
        ),
      );
    }

    return chapters;
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
