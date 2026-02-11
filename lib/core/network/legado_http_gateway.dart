import 'package:dio/dio.dart';
import 'package:soupbag/core/network/mock_legado_api.dart';

class LegadoHttpGateway {
  LegadoHttpGateway(this._dio);

  final Dio _dio;

  Future<String> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.scheme == 'mock') {
      return MockLegadoApi.respond(uri);
    }

    final response = await _dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        headers: headers,
      ),
    );
    return response.data ?? '';
  }
}
