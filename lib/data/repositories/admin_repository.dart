import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/pending_request_model.dart';

abstract class AdminRepository {
  Future<List<PendingRequestModel>> getPendingRequests();
  Future<void> approveRequest(String id);
  Future<void> rejectRequest(String id);
  Future<List<Map<String, String>>> getWorkers();
  Future<String> resetWorkerPassword(String workerId);
  Future<void> deactivateWorker(String workerId);
  Future<String> getFinancialInsight();
}

class AdminRepositoryImpl implements AdminRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<PendingRequestModel>> getPendingRequests() async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/admin/pending-requests');
    print('ADMIN_LOG: Fetching pending requests from: $url');

    final response = await http.get(url, headers: headers);

    print('ADMIN_LOG: Pending Requests Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('ADMIN_LOG: Error Body: ${response.body}');
      throw Exception('FAILED_TO_LOAD_REQUESTS');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return PendingRequestModel(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        requestedDate: DateTime.parse(map['requestedDate'] as String),
      );
    }).toList();
  }

  @override
  Future<void> approveRequest(String id) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/pending-requests/$id/approve'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('APPROVE_FAILED');
    }
  }

  @override
  Future<void> rejectRequest(String id) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/pending-requests/$id/reject'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('REJECT_FAILED');
    }
  }

  @override
  Future<List<Map<String, String>>> getWorkers() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/workers'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('FAILED_TO_LOAD_WORKERS');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final workers = data['workers'] as List<dynamic>;
    return workers.map((w) => {
      'id': (w as Map<String, dynamic>)['id'].toString(),
      'name': w['name']?.toString() ?? 'Unknown',
      'email': w['email']?.toString() ?? '',
    }).toList();
  }

  @override
  Future<String> resetWorkerPassword(String workerId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$workerId/reset-password'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('PASSWORD_RESET_FAILED');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['newPassword'] as String;
  }

  @override
  Future<void> deactivateWorker(String workerId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$workerId/deactivate'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('DEACTIVATE_FAILED');
    }
  }

  /// Calls the backend, which asks Gemini for a short plain-language
  /// summary based on aggregated income/expense totals — no raw
  /// transaction data leaves the backend. Call this on-demand (e.g. a
  /// "Generate Insights" button), not on every dashboard load, to stay
  /// within the Gemini free tier's rate limits.
  @override
  Future<String> getFinancialInsight() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/insights'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('INSIGHT_GENERATION_FAILED');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['insight'] as String;
  }
}