import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> signup(String name, String email, String password);
  Future<void> forgotPassword(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/forgot-password');
    print('AUTH_LOG: Requesting password reset for: $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      print('AUTH_LOG: Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['error'] == 'USER_NOT_FOUND') throw Exception('USER_NOT_FOUND');
        throw Exception('FORGOT_PASSWORD_FAILED');
      }
    } catch (e) {
      print('AUTH_LOG: Exception during forgotPassword: $e');
      rethrow;
    }
  }

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
      ).timeout(const Duration(seconds: 10));

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
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) return;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] == 'EMAIL_EXISTS') throw Exception('EMAIL_EXISTS');
    if (data['error'] == 'EMAIL_PENDING') throw Exception('EMAIL_PENDING');

    throw Exception('SIGNUP_FAILED');
  }
}
