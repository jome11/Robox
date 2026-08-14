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
    required PaymentMethod paymentMethod,
    List<IncomeCategory> categories,
    List<String> subCategories,
    String? customCategory,
    int? quantity,
    String? description,
  });
  Future<void> updateTransaction(String transactionId, {String? title, double? amount, String? description});
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

  /// The backend stores multiple categories as a comma-separated string in
  /// a single "category" column, e.g. "threeDPrint,filament".
  List<IncomeCategory> _parseCategories(dynamic raw) {
    if (raw == null) return const [];
    final str = raw as String;
    if (str.isEmpty) return const [];
    return str
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .map((name) => IncomeCategory.values.firstWhere(
          (c) => c.name == name,
      orElse: () => IncomeCategory.other,
    ))
        .toList();
  }

  /// The backend stores multiple specific types as a comma-separated string
  /// in a single "sub_category" column, e.g. "PLA FILAMENT,ABS FILAMENT".
  List<String> _parseSubCategories(dynamic raw) {
    if (raw == null) return const [];
    final str = raw as String;
    if (str.isEmpty) return const [];
    return str.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  TransactionModel _fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.parse(json['date'] as String),
      categories: _parseCategories(json['category']),
      subCategories: _parseSubCategories(json['subCategory']),
      customCategory: json['customCategory'] as String?,
      paymentMethod: PaymentMethod.fromLabel(json['paymentMethod'] as String?),
      quantity: json['quantity'] as int?,
      edited: json['edited'] as bool? ?? false,
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
    required PaymentMethod paymentMethod,
    List<IncomeCategory> categories = const [],
    List<String> subCategories = const [],
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
        'category': categories.isEmpty ? null : categories.map((c) => c.name).join(','),
        'subCategory': subCategories.isEmpty ? null : subCategories.join(','),
        'customCategory': customCategory,
        'paymentMethod': paymentMethod.label,
        'quantity': quantity,
        'description': description,
      }),
    );
    if (response.statusCode != 200) throw Exception('CREATE_TRANSACTION_FAILED');
  }

  @override
  Future<void> updateTransaction(String transactionId, {String? title, double? amount, String? description}) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (amount != null) body['amount'] = amount;
    if (description != null) body['description'] = description;

    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/transactions/$transactionId/description'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) throw Exception('UPDATE_TRANSACTION_FAILED');
  }
}