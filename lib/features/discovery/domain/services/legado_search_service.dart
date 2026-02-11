import 'dart:convert';

import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/core/parser/legado_search_rule_parser.dart';
import 'package:soupbag/features/discovery/domain/models/search_result_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class LegadoSearchService {
  LegadoSearchService({
    required LegadoHttpGateway httpGateway,
    required BookSourceRepository sourceRepository,
    required LegadoSearchRuleParser parser,
  })  : _httpGateway = httpGateway,
        _sourceRepository = sourceRepository,
        _parser = parser;

  final LegadoHttpGateway _httpGateway;
  final BookSourceRepository _sourceRepository;
  final LegadoSearchRuleParser _parser;

  Future<List<SearchResultEntity>> search(
    String keyword, {
    int page = 1,
    int maxSources = 8,
  }) async {
    final key = keyword.trim();
    if (key.isEmpty) {
      return const [];
    }

    final sources = await _sourceRepository.getBookSources(enabled: true);
    final candidates = sources
        .where(
          (source) =>
              source.searchUrl != null &&
              source.searchUrl!.isNotEmpty &&
              source.ruleSearch != null &&
              source.ruleSearch!.isNotEmpty,
        )
        .take(maxSources)
        .toList(growable: false);

    final results = <SearchResultEntity>[];
    final seen = <String>{};

    for (final source in candidates) {
      final searchUrl = _renderSearchUrl(
        source.searchUrl!,
        keyword: key,
        page: page,
      );

      try {
        final body = await _httpGateway.get(
          searchUrl,
          headers: _parseHeader(source.header),
        );

        final parsedItems = _parser.parse(
          responseBody: body,
          ruleSearchJson: source.ruleSearch!,
        );

        for (final item in parsedItems) {
          final identity = '${source.bookSourceUrl}|${item.bookUrl}|${item.name}';
          if (!seen.add(identity)) {
            continue;
          }
          results.add(
            SearchResultEntity(
              sourceUrl: source.bookSourceUrl,
              sourceName: source.bookSourceName,
              name: item.name,
              author: item.author,
              bookUrl: item.bookUrl,
              coverUrl: item.coverUrl,
              intro: item.intro,
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }

    return results;
  }

  String _renderSearchUrl(
    String template, {
    required String keyword,
    required int page,
  }) {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    return template
        .replaceAll('{{key}}', encodedKeyword)
        .replaceAll('{{page}}', '$page');
  }

  Map<String, String>? _parseHeader(String? rawHeader) {
    if (rawHeader == null || rawHeader.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawHeader);
      if (decoded is Map) {
        final map = <String, String>{};
        decoded.forEach((key, value) {
          if (key != null && value != null) {
            map['$key'] = '$value';
          }
        });
        return map.isEmpty ? null : map;
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
