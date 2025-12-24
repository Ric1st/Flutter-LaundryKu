import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class PaymentProvider extends ChangeNotifier {
  bool isLoading = false;

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
}
