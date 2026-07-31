import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> signup(String name, String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  @override
  Future<UserModel?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      await _storage.write(key: 'jwt_token', value: data['token'] as String);

      final user = data['user'] as Map<String, dynamic>;
      return UserModel(
        id: user['id'] as String,
        name: user['name'] as String,
        email: user['email'] as String,
        role: user['role'] == 'admin' ? UserRole.admin : UserRole.worker,
      );
    }

    if (data['error'] == 'ACCOUNT_PENDING') {
      throw Exception('ACCOUNT_PENDING');
    }

    return null; // INVALID_CREDENTIALS or anything else -> null, same as before
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
