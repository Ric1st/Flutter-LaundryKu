import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/payments_api.dart';

class PaymentProvider extends ChangeNotifier {
  final _api = PaymentsApi();

  bool isLoading = false;

  String filter = 'weekly';
  int totalOrders = 0;
  int completedOrders = 0;
  int totalIncome = 0;

  Map<String, int> chartData = {};

  Future<void> createPayment({
    required String orderId,
    required int amount,
    required String paymentMethod,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await SupabaseService.client.from('payments').insert({
        'order_id': orderId,
        'amount': amount,
        'payment_method': paymentMethod,
      });

      await loadReport();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> checkPaymentExists(String orderId) async {
    try {
      final result =
          await SupabaseService.client
              .from('payments')
              .select('id')
              .eq('order_id', orderId)
              .maybeSingle();

      return result != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPaymentByOrderId(String orderId) async {
    try {
      final result =
          await SupabaseService.client
              .from('payments')
              .select()
              .eq('order_id', orderId)
              .maybeSingle();

      return result;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadReport() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _api.fetchFinance(filter);

      totalOrders = data['totalOrders'];
      completedOrders = data['completedOrders'];
      totalIncome = data['totalIncome'];
      chartData = Map<String, int>.from(data['chart']);
    } catch (e) {
      debugPrint('FINANCE ERROR: $e');
      chartData = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeFilter(String value) {
    filter = value;
    loadReport();
  }

  int get maxChartValue {
    if (chartData.isEmpty) return 0;
    return chartData.values.reduce((a, b) => a > b ? a : b);
  }
}
