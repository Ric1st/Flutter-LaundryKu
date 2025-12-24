import 'package:flutter/material.dart';
import 'dart:io';
import '../models/orders.dart';
import '../services/order_api.dart';
import '../services/supabase_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderApi _api = OrderApi();
  final _supabase = SupabaseService.client;

  List<Order> currentOrders = [];
  List<Order> historyOrders = [];
  List<Order> allOrders = [];

  bool isLoading = false;

  String? selectedCustomerId;
  String? selectedCustomerName;

  String serviceType = 'reguler';

  final weightController = TextEditingController();
  final priceController = TextEditingController();

  final Map<String, int> servicePrice = {
    'reguler': 10000,
    'express': 15000,
    'kilat': 20000,
  };

  void calculatePrice() {
    final weight = int.tryParse(weightController.text) ?? 0;
    final price = weight * servicePrice[serviceType]!;
    priceController.text = price.toString();
    notifyListeners();
  }

  Future<void> loadOrders(String customerId) async {
    isLoading = true;
    notifyListeners();

    final orders = await _api.getOrdersByCustomer(customerId);

    currentOrders = orders.where((o) => !o.isPaid).toList();

    historyOrders = orders.where((o) => o.isPaid).toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('orders')
          .select('*, customers(name)')
          .order('date', ascending: false);

      allOrders = response.map<Order>((e) => Order.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Load all orders error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(BuildContext context) async {
    if (selectedCustomerId == null ||
        weightController.text.isEmpty ||
        priceController.text.isEmpty) {
      _show(context, 'Lengkapi data order');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      await _supabase.from('orders').insert({
        'customer_id': selectedCustomerId,
        'weight': int.parse(weightController.text),
        'service_type': serviceType,
        'price': int.parse(priceController.text),
        'status': 'pending',
        'photo_url': null,
      });

      _show(context, 'Order berhasil ditambahkan');
      Navigator.pop(context);
    } catch (e) {
      _show(context, 'Gagal menambahkan order');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? photoUrl,
  }) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': status,
            if (photoUrl != null) 'photo_url': photoUrl,
          })
          .eq('id', orderId);

      await loadAllOrders();
    } catch (e) {
      debugPrint('Update status error: $e');
    }
  }

  Future<String> uploadLaundryPhoto({
    required String orderId,
    required File imageFile,
  }) async {
    try {
      final fileName =
          'laundry_${orderId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('laundry-photos')
          .upload(fileName, imageFile);

      final publicUrl = _supabase.storage
          .from('laundry-photos')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('Upload photo error: $e');
      throw Exception('Gagal upload foto');
    }
  }

  void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    weightController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void selectCustomer(String id, String name) {
    selectedCustomerId = id;
    selectedCustomerName = name;
    notifyListeners();
  }

  void resetAddOrderForm() {
    selectedCustomerId = null;
    selectedCustomerName = null;
    serviceType = 'reguler';

    weightController.clear();
    priceController.clear();

    notifyListeners();
  }

  Future<bool> hasPayment(String orderId) async {
    try {
      final res = await _supabase
          .from('payments')
          .select('id')
          .eq('order_id', orderId)
          .limit(1);
      if (res is List) return res.isNotEmpty;
      return false;
    } catch (e) {
      debugPrint('hasPayment error: $e');
      return false;
    }
  }

  Future<void> createOfflinePayment({
    required String orderId,
    required int amount,
    required String method,
  }) async {
    try {
      await _supabase.from('payments').insert({
        'order_id': orderId,
        'amount': amount,
        'payment_method': method.toLowerCase(),
      });
      await loadAllOrders();
    } catch (e) {
      debugPrint('createOfflinePayment error: $e');
      rethrow;
    }
  }
}
