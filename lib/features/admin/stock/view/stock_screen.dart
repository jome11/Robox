import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/inventory_item.dart';
import '../../../../data/repositories/stock_repository.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/stock_refresh_notifier.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final StockRepository _stockRepository = StockRepositoryImpl();
  List<InventoryItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStock();
    StockRefreshNotifier.instance.addListener(_loadStock);
  }

  @override
  void dispose() {
    StockRefreshNotifier.instance.removeListener(_loadStock);
    super.dispose();
  }

  Future<void> _loadStock() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _stockRepository.getStock();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load inventory. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 0);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStock,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inventory', style: AppTextStyles.headline),
              const SizedBox(height: 4),
              Text('Live monitoring of machines and filaments.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(_error!, style: AppTextStyles.body.copyWith(color: Colors.red)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _loadStock, child: const Text('Retry')),
                    ],
                  ),
                )
              else if (_items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No inventory data found.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                  ),
                )
              else
                ..._items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                currencyFormat.format(item.price),
                                style: AppTextStyles.label.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${item.quantity}',
                                style: AppTextStyles.headline.copyWith(fontSize: 24, color: AppColors.primary)),
                            Text('UNITS', style: AppTextStyles.label.copyWith(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
