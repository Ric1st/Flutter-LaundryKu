import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminProvider extends ChangeNotifier {
  final _supabase = SupabaseService.client;

  bool isAdmin = false;
  bool isLoading = false;

  Future<void> checkAdminRole(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response =
          await _supabase
              .from('customers')
              .select('role')
              .eq('id', userId)
              .single();

      isAdmin = response['role'] == 'Admin';
    } catch (e) {
      debugPrint('Check admin role error: $e');
      isAdmin = false;
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isAdmin = false;
    notifyListeners();
  }
}
