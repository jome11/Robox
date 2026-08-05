import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> signup(String name, String email, String password);
  Future<void> setNewPassword(String newPassword);
  Future<void> updateProfile({String? name, String? email});
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  @override
  Future<UserModel?> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/login');
    print('AUTH_LOG: Attempting login to: $url');
    print('AUTH_LOG: Payload: {"email": "$email"}'); // Don't log password

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 45));

      print('AUTH_LOG: Response Status: ${response.statusCode}');
      print('AUTH_LOG: Response Body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _storage.write(key: 'jwt_token', value: data['token'] as String);

        final user = data['user'] as Map<String, dynamic>;
        return UserModel(
          id: user['id'].toString(),
          name: user['name']?.toString() ?? 'Unknown',
          email: user['email']?.toString() ?? '',
          role: user['role'] == 'admin' ? UserRole.admin : UserRole.worker,
          mustChangePassword: user['mustChangePassword'] == true || user['mustChangePassword'] == 1,
        );
      }

      if (data['error'] == 'ACCOUNT_PENDING') {
        throw Exception('ACCOUNT_PENDING');
      }

      return null;
    } catch (e) {
      print('AUTH_LOG: Exception during login: $e');
      rethrow;
    }
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/signup');
    print('AUTH_LOG: Attempting signup to: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 45));

      print('AUTH_LOG: Signup Response Status: ${response.statusCode}');
      print('AUTH_LOG: Signup Response Body: ${response.body}');

      if (response.statusCode == 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['error'] == 'EMAIL_EXISTS') throw Exception('EMAIL_EXISTS');
      if (data['error'] == 'EMAIL_PENDING') throw Exception('EMAIL_PENDING');

      throw Exception('SIGNUP_FAILED');
    } catch (e) {
      print('AUTH_LOG: Exception during signup: $e');
      rethrow;
    }
  }

  @override
  Future<void> setNewPassword(String newPassword) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/account/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'newPassword': newPassword}),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception('PASSWORD_CHANGE_FAILED');
    }
  }

  @override
  Future<void> updateProfile({String? name, String? email}) async {
    final token = await _storage.read(key: 'jwt_token');
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/account/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) return;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == 'EMAIL_EXISTS') throw Exception('EMAIL_EXISTS');
    throw Exception('PROFILE_UPDATE_FAILED');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/account/profile'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) {
        await _storage.delete(key: 'jwt_token');
        return null;
      }

      final user = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel(
        id: user['id'].toString(),
        name: user['name']?.toString() ?? 'Unknown',
        email: user['email']?.toString() ?? '',
        role: user['role'] == 'admin' ? UserRole.admin : UserRole.worker,
        mustChangePassword: user['mustChangePassword'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}