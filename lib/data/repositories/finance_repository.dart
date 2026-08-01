import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';

abstract class FinanceRepository {
  Future<List<TransactionModel>> getMyTransactions();
  Future<List<TransactionModel>> getAllTransactions(); // admin only
  Future<void> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    IncomeCategory? category,
    String? subCategory,
    String? customCategory,
    int? quantity,
    String? description,
  });
  Future<void> updateDescription(String transactionId, String description);
}

class FinanceRepositoryImpl implements FinanceRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  TransactionModel _fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] == null
          ? null
          : IncomeCategory.values.firstWhere(
              (c) => c.name == json['category'],
              orElse: () => IncomeCategory.other,
            ),
      subCategory: json['subCategory'] as String?,
      customCategory: json['customCategory'] as String?,
      quantity: json['quantity'] as int?,
      description: json['description'] as String?,
      addedBy: json['addedBy'] as String?,
    );
  }

  @override
  Future<List<TransactionModel>> getMyTransactions() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/transactions/mine'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('FAILED_TO_LOAD_TRANSACTIONS');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['transactions'] as List<dynamic>;
    return list.map((t) => _fromJson(t as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/transactions'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('FAILED_TO_LOAD_TRANSACTIONS');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['transactions'] as List<dynamic>;
    return list.map((t) => _fromJson(t as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    IncomeCategory? category,
    String? subCategory,
    String? customCategory,
    int? quantity,
    String? description,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/transactions'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'category': category?.name,
        'subCategory': subCategory,
        'customCategory': customCategory,
        'quantity': quantity,
        'description': description,
      }),
    );
    if (response.statusCode != 200) throw Exception('CREATE_TRANSACTION_FAILED');
  }

  @override
  Future<void> updateDescription(String transactionId, String description) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/transactions/$transactionId/description'),
      headers: headers,
      body: jsonEncode({'description': description}),
    );
    if (response.statusCode != 200) throw Exception('UPDATE_DESCRIPTION_FAILED');
  }
}
