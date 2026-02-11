import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/network/legado_http_gateway.dart';

void main() {
  group('LegadoHttpGateway', () {
    late LegadoHttpGateway gateway;

    setUp(() {
      gateway = LegadoHttpGateway(Dio());
    });

    test('getResponse 在 mock 协议下返回响应体与最终地址', () async {
      final response = await gateway.getResponse('mock://search?key=测试&page=1');

      expect(response.url, 'mock://search?key=测试&page=1');
      expect(response.redirected, isFalse);
      expect(response.body, contains('books'));
    });

    test('get 保持兼容返回 body', () async {
      final body = await gateway.get('mock://explore?page=2');

      expect(body, contains('推荐 榜单 2-A'));
    });
  });
}
