import 'package:flutter/foundation.dart';

/// Tiny app-wide signal so screens that don't share state (like
/// StockScreen and FinancialManagementScreen, which live on separate
/// bottom-nav tabs) can tell each other "inventory changed, refresh."
class StockRefreshNotifier extends ChangeNotifier {
  StockRefreshNotifier._();
  static final StockRefreshNotifier instance = StockRefreshNotifier._();

  void notifyRestocked() => notifyListeners();
}
