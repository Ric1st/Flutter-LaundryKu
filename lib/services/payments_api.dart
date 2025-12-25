import '../services/supabase_service.dart';

class PaymentsApi {
  final _api = SupabaseService.client;

  Future<Map<String, dynamic>> fetchFinance(String filter) async {
    final now = DateTime.now().toUtc();
    late DateTime startDate;

    if (filter == 'weekly') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (filter == 'monthly') {
      startDate = DateTime.utc(now.year, now.month, 1);
    } else {
      startDate = DateTime.utc(now.year, 1, 1);
    }

    final response = await _api
        .from('payments')
        .select('''
          paid_date,
          amount,
          orders (
            id,
            status
          )
        ''')
        .gte('paid_date', startDate.toIso8601String());

    final orders = await _api.from('orders').select('id');

    final int totalOrders = orders.length;
    int completedOrders = 0;
    int totalIncome = 0;

    final Map<String, int> chart = {};

    for (final item in response) {
      final order = item['orders'];
      if (order == null) continue;

      if (order['status'] == 'completed') {
        final int amount = (item['amount'] ?? 0) as int;

        completedOrders++;
        totalIncome += amount;

        final date = DateTime.parse(item['paid_date']).toLocal();

        String key;
        if (filter == 'weekly') {
          key = '${date.day}/${date.month}';
        } else if (filter == 'monthly') {
          key = '${date.day}';
        } else {
          key = '${date.month}';
        }

        chart[key] = (chart[key] ?? 0) + amount;
      }
    }

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'totalIncome': totalIncome,
      'chart': chart,
    };
  }
}
