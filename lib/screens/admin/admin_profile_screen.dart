import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import '../../services/supabase_service.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final login = context.read<LoginProvider>();

    nameController = TextEditingController(text: login.nameController.text);
    phoneController = TextEditingController(text: login.phoneController.text);
    addressController = TextEditingController(text: login.address ?? '');
  }

  Future<bool> isPhoneUsed({
    required String newPhone,
    required String currentUserId,
  }) async {
    final result = await SupabaseService.client
        .from('customers')
        .select('id')
        .eq('phone', newPhone)
        .neq('id', currentUserId)
        .limit(1);

    return result.isNotEmpty;
  }

  Future<void> _saveProfile() async {
    final login = context.read<LoginProvider>();
    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();
    final newAddress = addressController.text.trim();

    final phoneUsed = await isPhoneUsed(
      newPhone: newPhone,
      currentUserId: login.customerId!,
    );

    if (phoneUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon sudah digunakan user lain'),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    if (login.customerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User tidak valid')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await SupabaseService.client
          .from('customers')
          .update({'name': newName, 'phone': newPhone, 'address': newAddress})
          .eq('id', login.customerId!);

      login.nameController.text = newName;
      login.phoneController.text = newPhone;
      login.address = newAddress;
      login.notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E60CE),
        title: const Text(
          'Profil Admin',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 72,
                  color: Color(0xFF5E60CE),
                ),
                const SizedBox(height: 24),

                _field('Nama', nameController),
                const SizedBox(height: 16),

                _field(
                  'No Telepon',
                  phoneController,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _field('Alamat', addressController, maxLines: 2),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E60CE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'SIMPAN PERUBAHAN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
