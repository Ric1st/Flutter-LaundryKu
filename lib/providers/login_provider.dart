import 'package:flutter/material.dart';
import '../services/customer_api.dart';
import '../screens/user/user_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/login_screen.dart';

class LoginProvider extends ChangeNotifier {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final registerNameController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerAddressController = TextEditingController();

  final CustomerApi _api = CustomerApi();

  bool isLoading = false;
  String? errorMessage;

  String? customerId;
  String? role;
  String? address;

  Future<void> login(BuildContext context) async {
    notifyListeners();

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _show(context, 'Nama dan No Telepon wajib diisi');
      return;
    }

    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final customer = await _api.login(name, phone);

      if (customer == null) {
        _show(context, 'Login gagal. Data tidak ditemukan');
        return;
      } else {
        customerId = customer.id;
        role = customer.role;
        address = customer.address;
        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserScreen()),
          );
        }
      }
    } catch (e) {
      _show(context, 'Terjadi kesalahan saat login');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(BuildContext context) async {
    final name = registerNameController.text.trim();
    final phone = registerPhoneController.text.trim();
    final address = registerAddressController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _show(context, 'Nama dan No Telepon wajib diisi');
      return;
    }

    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      await _api.registerCustomer(
        name: name,
        phone: phone,
        address: address,
        role: 'User',
      );

      _clearRegister();
      _show(context, 'Registrasi berhasil, silakan login');
      Navigator.pop(context);
    } catch (e) {
      _show(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _clearRegister() {
    registerNameController.clear();
    registerPhoneController.clear();
    registerAddressController.clear();
  }

  void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    registerNameController.dispose();
    registerPhoneController.dispose();
    registerAddressController.dispose();
    super.dispose();
  }

  void logout(BuildContext context) {
    customerId = null;
    role = null;
    address = null;

    nameController.clear();
    phoneController.clear();

    notifyListeners();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false, 
    );
  }
}
