import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/legado/model/web_book/rule_execution_context.dart';

void main() {
  group('LegadoRuleExecutionContext', () {
    late LegadoRuleExecutionContext context;

    setUp(() {
      context = LegadoRuleExecutionContext(
        httpGateway: LegadoHttpGateway(Dio()),
      );
    });

    test('buildRequestUrl 可替换模板并补全相对链接', () {
      final requestUrl = context.buildRequestUrl(
        rawUrl: '/search?key={{key}}&page={{page}}',
        baseUrl: 'https://example.com/base/',
        replacements: {'key': 'abc', 'page': '2'},
      );

      expect(requestUrl, 'https://example.com/search?key=abc&page=2');
    });

    test('parseHeader 可解析 JSON header', () {
      final headers = context.parseHeader('{"User-Agent":"Soupbag","X-A":1}');

      expect(headers, isNotNull);
      expect(headers!['User-Agent'], 'Soupbag');
      expect(headers['X-A'], '1');
    });

    test('execute 可返回统一响应结构', () async {
      final source = BookSourceEntity(
        bookSourceUrl: 'mock://search',
        bookSourceName: 'Mock源',
      );

      final result = await context.execute(
        source: source,
        rawUrl: 'mock://search?key={{key}}&page={{page}}',
        baseUrl: source.bookSourceUrl,
        replacements: {'key': '测试', 'page': '1'},
      );

      expect(result, isNotNull);
      expect(result!.requestUrl, 'mock://search?key=测试&page=1');
      expect(result.responseUrl, 'mock://search?key=测试&page=1');
      expect(result.redirected, isFalse);
      expect(result.body, contains('books'));
    });
  });
}
