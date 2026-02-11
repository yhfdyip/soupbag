import 'dart:convert';

import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class LegadoSourceImportResult {
  const LegadoSourceImportResult({
    required this.successCount,
    required this.skippedCount,
    required this.messages,
  });

  final int successCount;
  final int skippedCount;
  final List<String> messages;
}

class LegadoSourceImporter {
  LegadoSourceImporter(this._repository);

  final BookSourceRepository _repository;

  Future<LegadoSourceImportResult> importFromJsonString(String rawJson) async {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) {
      return const LegadoSourceImportResult(
        successCount: 0,
        skippedCount: 0,
        messages: ['导入内容为空'],
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      return const LegadoSourceImportResult(
        successCount: 0,
        skippedCount: 1,
        messages: ['JSON 格式不合法'],
      );
    }

    final entries = _normalizeEntries(decoded);
    final sources = <BookSourceEntity>[];
    final messages = <String>[];

    for (var i = 0; i < entries.length; i++) {
      final element = entries[i];
      if (element is! Map<String, dynamic>) {
        messages.add('第 ${i + 1} 条不是对象，已跳过');
        continue;
      }

      final source = _mapToSource(element);
      if (source.bookSourceUrl.isEmpty || source.bookSourceName.isEmpty) {
        messages.add('第 ${i + 1} 条缺少 bookSourceUrl/bookSourceName，已跳过');
        continue;
      }
      sources.add(source);
    }

    if (sources.isNotEmpty) {
      await _repository.saveBookSources(sources);
    }

    final skippedCount = entries.length - sources.length;
    return LegadoSourceImportResult(
      successCount: sources.length,
      skippedCount: skippedCount,
      messages: messages,
    );
  }

  List<dynamic> _normalizeEntries(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      return [decoded];
    }
    return [];
  }

  BookSourceEntity _mapToSource(Map<String, dynamic> json) {
    return BookSourceEntity(
      bookSourceUrl: _asString(json['bookSourceUrl']) ?? '',
      bookSourceName: _asString(json['bookSourceName']) ?? '',
      bookSourceGroup: _asString(json['bookSourceGroup']),
      bookSourceType: _asInt(json['bookSourceType']),
      bookUrlPattern: _asString(json['bookUrlPattern']),
      customOrder: _asInt(json['customOrder']),
      enabled: _asBool(json['enabled'], defaultValue: true),
      enabledExplore: _asBool(json['enabledExplore'], defaultValue: true),
      jsLib: _asString(json['jsLib']),
      enabledCookieJar: _asBool(json['enabledCookieJar'], defaultValue: true),
      concurrentRate: _asString(json['concurrentRate']),
      header: _toJsonString(json['header']),
      loginUrl: _asString(json['loginUrl']),
      loginUi: _toJsonString(json['loginUi']),
      loginCheckJs: _asString(json['loginCheckJs']),
      coverDecodeJs: _asString(json['coverDecodeJs']),
      bookSourceComment: _asString(json['bookSourceComment']),
      variableComment: _asString(json['variableComment']),
      lastUpdateTime: _asInt(json['lastUpdateTime']),
      respondTime: _asInt(json['respondTime'], defaultValue: 180000),
      weight: _asInt(json['weight']),
      exploreUrl: _asString(json['exploreUrl']),
      exploreScreen: _toJsonString(json['exploreScreen']),
      ruleExplore: _toJsonString(json['ruleExplore']),
      searchUrl: _asString(json['searchUrl']),
      ruleSearch: _toJsonString(json['ruleSearch']),
      ruleBookInfo: _toJsonString(json['ruleBookInfo']),
      ruleToc: _toJsonString(json['ruleToc']),
      ruleContent: _toJsonString(json['ruleContent']),
      ruleReview: _toJsonString(json['ruleReview']),
    );
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    return null;
  }

  int _asInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  bool _asBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == '1' || normalized == 'true') return true;
      if (normalized == '0' || normalized == 'false') return false;
    }
    return defaultValue;
  }

  String? _toJsonString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    try {
      return jsonEncode(value);
    } catch (_) {
      return null;
    }
  }
}
