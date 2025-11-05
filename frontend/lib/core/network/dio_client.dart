import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio([String? baseUrl]) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? "",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('DIO: $obj'),
      ),
    );

    // Attach auth token if exists (user or admin)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final userToken = prefs.getString('access_token');
            final adminToken = prefs.getString('admin_access_token');

            if (adminToken != null && adminToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $adminToken';
            } else if (userToken != null && userToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $userToken';
            }
          } catch (_) {}
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');
            await prefs.remove('admin_access_token');
            await prefs.remove('admin_role');
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static void updateBaseUrl(String newBaseUrl) {
    // Ensure the URL has a protocol
    String url = newBaseUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    print('DioClient: Updating base URL to $url');

    // Create a new Dio instance with the updated base URL
    _dio = _createDio(url);
  }

  static Future<bool> testConnection() async {
    try {
      final response = await dio.get('/');
      print(
        'DioClient: Connection test successful - Status: ${response.statusCode}',
      );
      return true;
    } catch (e) {
      print('DioClient: Connection test failed - $e');
      return false;
    }
  }

  static void reset() {
    _dio = null;
  }
}
