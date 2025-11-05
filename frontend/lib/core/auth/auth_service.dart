import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

class AuthService {
  static const String _tokenKey = 'access_token';

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await DioClient.dio.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'full_name': fullName},
    );
    return Map<String, dynamic>.from(response.data);
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await DioClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = Map<String, dynamic>.from(response.data);
    final token = data['access_token'] as String?;
    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<Map<String, dynamic>?> me() async {
    try {
      final response = await DioClient.dio.get('/auth/me');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_tokenKey) ?? '').isNotEmpty;
  }
}
