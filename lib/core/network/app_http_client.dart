import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppHttpClient {
  AppHttpClient({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions()) {
    _configureInterceptors();
  }

  final Dio _dio;

  Dio get client => _dio;

  static BaseOptions _defaultOptions() {
    return BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.plain,
      headers: const {
        'User-Agent': 'Soupbag/0.1',
      },
    );
  }

  void _configureInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout) {
            handler.next(
              error.copyWith(message: '连接超时，请检查网络后重试'),
            );
            return;
          }
          if (error.type == DioExceptionType.receiveTimeout) {
            handler.next(
              error.copyWith(message: '响应超时，请稍后重试'),
            );
            return;
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }
}
