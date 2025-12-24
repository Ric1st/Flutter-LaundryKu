import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../services/supabase_service.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<OrderProvider>().resetAddOrderForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5E60CE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _customerDropdown(context, provider),
            const SizedBox(height: 16),

            TextField(
              controller: provider.weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Berat (Kg)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => provider.calculatePrice(),
            ),

            const SizedBox(height: 16),

            const Text('Jenis Layanan'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _serviceChip(provider, 'reguler', Colors.grey),
                _serviceChip(provider, 'express', Colors.orange),
                _serviceChip(provider, 'kilat', Colors.red),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: provider.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    provider.isLoading
                        ? null
                        : () => provider.addOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E60CE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    provider.isLoading
                        ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'SIMPAN ORDER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerDropdown(BuildContext context, OrderProvider provider) {
    return InkWell(
      onTap: () => _showCustomerPicker(context, provider),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Customer (Cari No. Telp)',
          border: OutlineInputBorder(),
        ),
        child: Text(
          provider.selectedCustomerName ?? 'Pilih customer',
          style: TextStyle(
            color:
                provider.selectedCustomerName == null
                    ? Colors.grey
                    : Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomerPicker(
    BuildContext context,
    OrderProvider provider,
  ) async {
    final searchController = TextEditingController();

    final customers = await SupabaseService.client
        .from('customers')
        .select('id, name, phone')
        .order('name');

    List filtered = List.from(customers);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cari Customer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan No Telepon',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filtered =
                            customers
                                .where(
                                  (c) => c['phone'].toString().contains(value),
                                )
                                .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return ListTile(
                          title: Text(c['name']),
                          subtitle: Text(c['phone']),
                          onTap: () {
                            provider.selectCustomer(c['id'], c['name']);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _serviceChip(OrderProvider provider, String type, Color color) {
    final selected = provider.serviceType == type;

    return ChoiceChip(
      label: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: selected,
      selectedColor: color,
      backgroundColor: color.withOpacity(0.15),
      onSelected: (_) {
        provider.serviceType = type;
        provider.calculatePrice();
        provider.notifyListeners();
      },
    );
  }
}
