import 'package:dio/dio.dart';
import 'package:soupbag/core/network/mock_legado_api.dart';

class LegadoHttpResponse {
  const LegadoHttpResponse({
    required this.url,
    required this.body,
    this.redirected = false,
  });

  final String url;
  final String body;
  final bool redirected;
}

class LegadoHttpGateway {
  LegadoHttpGateway(this._dio);

  final Dio _dio;

  Future<LegadoHttpResponse> getResponse(
    String url, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.scheme == 'mock') {
      return LegadoHttpResponse(url: url, body: MockLegadoApi.respond(uri));
    }

    final response = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain, headers: headers),
    );

    final responseUrl = response.realUri.toString().trim().isNotEmpty
        ? response.realUri.toString()
        : response.requestOptions.uri.toString();

    final isRedirected = response.redirects.isNotEmpty || response.isRedirect;
    return LegadoHttpResponse(
      url: responseUrl,
      body: response.data ?? '',
      redirected: isRedirected,
    );
  }

  Future<String> get(String url, {Map<String, String>? headers}) async {
    final response = await getResponse(url, headers: headers);
    return response.body;
  }
}
