import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/orders.dart';
import 'supabase_service.dart';

class OrderApi {
  final _client = SupabaseService.client;

  Future<List<Order>> getOrdersByCustomer(String customerId) async {
    final response = await _client
        .from('orders')
        .select('''
          id,
          customer_id,
          weight,
          service_type,
          price,
          status,
          photo_url,
          date,
          payments ( id )
        ''')
        .eq('customer_id', customerId)
        .order('date', ascending: false);

    return response.map<Order>((json) {
      final isPaid = json['payments'] != null;

      return Order(
        id: json['id'],
        customerId: json['customer_id'],
        serviceType: json['service_type'],
        weight: json['weight'],
        price: json['price'],
        status: isPaid ? 'selesai' : json['status'],
        photoURL: json['photo_url'],
        isPaid: isPaid,
        date: DateTime.parse(json['date']),
      );
    }).toList();
  }
}
