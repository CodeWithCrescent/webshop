import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';

class DioClient {
  static Future<Dio> create(FlutterSecureStorage? storage) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token;

        // Prevent reading from storage on web
        if (!kIsWeb && storage != null) {
          try {
            token = await storage.read(key: 'access_token');
          } catch (e) {
            debugPrint('Secure storage read error: $e');
          }
        }

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle token refresh or logout
        }
        return handler.next(error);
      },
    ));

    return dio;
  }
}
