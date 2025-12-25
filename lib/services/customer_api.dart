import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customers.dart';
import 'supabase_service.dart';

class CustomerApi {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Customer>> getAllCustomers() async {
    final res = await _client.from('customers').select();
    return (res as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer?> login(String name, String phone) async {
    final res =
        await _client
            .from('customers')
            .select()
            .eq('name', name)
            .eq('phone', phone)
            .maybeSingle();

    if (res == null) return null;
    return Customer.fromJson(res);
  }

  Future<bool> isPhoneExists(String phone) async {
    final res =
        await _client
            .from('customers')
            .select('id')
            .eq('phone', phone)
            .maybeSingle();

    return res != null;
  }

  Future<void> registerCustomer({
    required String name,
    required String phone,
    required String address,
    required String role,
  }) async {
    final exists = await isPhoneExists(phone);
    if (exists) {
      throw Exception('Nomor telepon sudah terdaftar');
    }

    await _client.from('customers').insert({
      'name': name,
      'phone': phone,
      'address': address,
      'role': role,
    });
  }

  Future<void> update(Customer customer) async {
    await _client
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id);
  }
}
