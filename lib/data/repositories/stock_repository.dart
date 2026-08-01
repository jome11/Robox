import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/inventory_item.dart';

abstract class StockRepository {
  Future<List<InventoryItem>> getStock();
  Future<void> restock(List<Map<String, dynamic>> items);
}

class StockRepositoryImpl implements StockRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<InventoryItem>> getStock() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/stock'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('FAILED_TO_LOAD_STOCK');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['stock'] as List<dynamic>;
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return InventoryItem(
        name: map['itemName'] as String,
        quantity: map['quantity'] as int,
        price: (map['price'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> restock(List<Map<String, dynamic>> items) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/stock/restock'),
      headers: headers,
      body: jsonEncode({'items': items}),
    );

    if (response.statusCode != 200) {
      throw Exception('RESTOCK_FAILED');
    }
  }
}
