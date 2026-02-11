import 'dart:convert';

import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';

class LegadoRuleExecutionResult {
  const LegadoRuleExecutionResult({
    required this.requestUrl,
    required this.responseUrl,
    required this.body,
    required this.redirected,
  });

  final String requestUrl;
  final String responseUrl;
  final String body;
  final bool redirected;
}

class LegadoRuleExecutionContext {
  const LegadoRuleExecutionContext({required LegadoHttpGateway httpGateway})
    : _httpGateway = httpGateway;

  final LegadoHttpGateway _httpGateway;

  Future<LegadoRuleExecutionResult?> execute({
    required BookSourceEntity source,
    required String? rawUrl,
    required String baseUrl,
    Map<String, String> replacements = const {},
  }) async {
    final requestUrl = buildRequestUrl(
      rawUrl: rawUrl,
      baseUrl: baseUrl,
      replacements: replacements,
    );
    if (requestUrl == null || requestUrl.isEmpty) {
      return null;
    }

    final response = await _httpGateway.getResponse(
      requestUrl,
      headers: parseHeader(source.header),
    );

    final responseUrl = response.url.trim().isEmpty ? requestUrl : response.url;
    return LegadoRuleExecutionResult(
      requestUrl: requestUrl,
      responseUrl: responseUrl,
      body: response.body,
      redirected: response.redirected,
    );
  }

  String? buildRequestUrl({
    required String? rawUrl,
    required String baseUrl,
    Map<String, String> replacements = const {},
  }) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    var rendered = rawUrl.trim();
    for (final entry in replacements.entries) {
      rendered = rendered.replaceAll('{{${entry.key}}}', entry.value);
    }

    return resolveUrlWithBase(rawUrl: rendered, baseUrl: baseUrl);
  }

  Map<String, String>? parseHeader(String? rawHeader) {
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

  String? resolveUrlWithBase({
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
