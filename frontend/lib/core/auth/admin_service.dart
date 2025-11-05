import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

class AdminService {
  static const String _tokenKey = 'admin_access_token';
  static const String _roleKey = 'admin_role';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await DioClient.dio.post(
      '/admin/login',
      data: {'username': email, 'password': password},
    );
    final data = Map<String, dynamic>.from(response.data);
    final token = data['access_token'] as String?;
    final role = data['role'] as String?;

    if (token != null && token.isNotEmpty && role == 'admin') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_roleKey, role ?? "admin");
    }
    return data;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }

  static Future<bool> hasAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final role = prefs.getString(_roleKey);
    return (token ?? '').isNotEmpty && role == 'admin';
  }

  // Roadmaps
  static Future<List<dynamic>> getAllRoadmaps() async {
    final response = await DioClient.dio.get('/admin/roadmaps');
    return List<dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> createRoadmap(
    Map<String, dynamic> data,
  ) async {
    final response = await DioClient.dio.post('/admin/roadmaps', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> updateRoadmap(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await DioClient.dio.put('/admin/roadmaps/$id', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> deleteRoadmap(int id) async {
    final response = await DioClient.dio.delete('/admin/roadmaps/$id');
    return Map<String, dynamic>.from(response.data);
  }

  // Dashboard stats
  static Future<Map<String, dynamic>> getStats() async {
    final res = await DioClient.dio.get('/admin/dashboard/stats');
    return Map<String, dynamic>.from(res.data);
  }

  // Analytics
  static Future<List<dynamic>> getPopularCareers() async {
    final res = await DioClient.dio.get('/admin/analytics/popular-careers');
    return List<dynamic>.from(res.data);
  }

  // Users
  static Future<List<dynamic>> getUsers() async {
    final res = await DioClient.dio.get('/admin/users');
    return List<dynamic>.from(res.data);
  }

  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> body,
  ) async {
    final res = await DioClient.dio.post('/admin/users', data: body);
    return Map<String, dynamic>.from(res.data);
  }

  static Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> body,
  ) async {
    final res = await DioClient.dio.put('/admin/users/$id', data: body);
    return Map<String, dynamic>.from(res.data);
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final res = await DioClient.dio.delete('/admin/users/$id');
    return Map<String, dynamic>.from(res.data);
  }

  static Future<Map<String, dynamic>> getUserDetail(int id) async {
    final res = await DioClient.dio.get('/admin/users/$id');
    return Map<String, dynamic>.from(res.data);
  }
}
