import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';

abstract class ChatRepository {
  /// Full message history for the group chat tied to [taskId].
  Future<List<ChatMessage>> getMessages(String taskId);

  /// Sends a new text message to the group chat tied to [taskId].
  Future<void> sendMessage(String taskId, String content);
}

class ChatRepositoryImpl implements ChatRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  ChatMessage _fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderRole: json['senderRole'] as String? ?? 'worker',
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Future<List<ChatMessage>> getMessages(String taskId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/tasks/$taskId/messages'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('FAILED_TO_LOAD_MESSAGES');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['messages'] as List<dynamic>;
    return list.map((m) => _fromJson(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> sendMessage(String taskId, String content) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/tasks/$taskId/messages'),
      headers: headers,
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode != 200) throw Exception('SEND_MESSAGE_FAILED');
  }
}
