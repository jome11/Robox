import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/leaderboard_entry_model.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntryModel>> getLeaderboard();
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<LeaderboardEntryModel>> getLeaderboard() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/leaderboard'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('FAILED_TO_LOAD_LEADERBOARD');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['leaderboard'] as List<dynamic>;
    return list.map((item) => LeaderboardEntryModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
