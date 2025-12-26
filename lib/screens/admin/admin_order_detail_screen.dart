import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/orders.dart';
import '../../providers/order_provider.dart';
import 'take_photo_screen.dart';

class AdminDetailOrderScreen extends StatefulWidget {
  final String orderId;
  const AdminDetailOrderScreen({super.key, required this.orderId});

  @override
  State<AdminDetailOrderScreen> createState() => _AdminDetailOrderScreenState();
}

class _AdminDetailOrderScreenState extends State<AdminDetailOrderScreen> {
  String selectedPayment = 'cash';
  bool isProcessing = false;

  int _stepIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'ready':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _setOfflinePaymentAndComplete(Order order) async {
    if (order.photoURL == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload foto laundry terlebih dahulu!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final provider = context.read<OrderProvider>();
    setState(() => isProcessing = true);
    try {
      await provider.createOfflinePayment(
        orderId: order.id,
        amount: order.price,
        method: selectedPayment,
      );

      await provider.updateOrderStatus(orderId: order.id, status: 'completed');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran dicatat dan order selesai')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mencatat payment: $e')));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _checkQrisThenComplete(Order order) async {
    if (order.photoURL == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload foto laundry terlebih dahulu!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final provider = context.read<OrderProvider>();
    setState(() => isProcessing = true);
    try {
      final exists = await provider.hasPayment(order.id);
      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Belum ada pembayaran QRIS untuk order ini'),
          ),
        );
        return;
      }

      await provider.updateOrderStatus(orderId: order.id, status: 'completed');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order selesai (QRIS terdeteksi)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    final order = provider.allOrders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order tidak ditemukan'),
    );

    final hasPhoto = order.photoURL != null;
    final currentStep = _stepIndex(order.status);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5E60CE),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Customer', order.customerName ?? order.customerId),
                  _infoRow('Layanan', order.serviceType),
                  _infoRow('Berat', '${order.weight} Kg'),
                  _infoRow('Harga', 'Rp ${order.price}'),
                  _infoRow('Status', order.status.toUpperCase()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color:
                                index <= currentStep
                                    ? const Color(0xFF5E60CE)
                                    : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            'Pending',
                            'Processing',
                            'Ready',
                            'Completed',
                          ][index],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (order.status == 'ready') ...[
            if (!hasPhoto) ...[
              Card(
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Upload foto laundry diperlukan sebelum menyelesaikan order!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Pilih Metode Pembayaran (untuk melengkapi pembayaran):',
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPayment,
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Text('Cash (Bayar tunai & catat)'),
                ),
                DropdownMenuItem(
                  value: 'kupon',
                  child: Text('Kupon (Catat kupon)'),
                ),
                DropdownMenuItem(
                  value: 'qris',
                  child: Text('QRIS (cek payment di DB)'),
                ),
              ],
              onChanged: (v) => setState(() => selectedPayment = v ?? 'cash'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
          ],

          if (order.photoURL != null) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Foto Laundry',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(order.photoURL!, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (order.status == 'pending')
            _actionButton(
              label: 'Ubah ke Processing',
              onPressed: () async {
                await provider.updateOrderStatus(
                  orderId: order.id,
                  status: 'processing',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status diperbarui')),
                );
              },
            ),
          if (order.status == 'processing')
            _actionButton(
              label: 'Ubah ke Ready',
              onPressed: () async {
                await provider.updateOrderStatus(
                  orderId: order.id,
                  status: 'ready',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status diperbarui')),
                );
              },
            ),

          if (order.status == 'ready') ...[
            _actionButton(
              label: 'Ambil / Upload Foto Laundry',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TakePhotoScreen(orderId: order.id),
                  ),
                );
                if (mounted) {
                  await provider.loadAllOrders();
                }
              },
              color: const Color(0xFF5E60CE),
            ),

            const SizedBox(height: 12),

            if (selectedPayment == 'cash' || selectedPayment == 'kupon')
              _actionButton(
                label:
                    isProcessing
                        ? 'Memproses...'
                        : 'Selesaikan Order (Catat ${selectedPayment.toUpperCase()})',
                color: hasPhoto ? Colors.green : Colors.grey,
                onPressed:
                    isProcessing || !hasPhoto
                        ? null
                        : () => _setOfflinePaymentAndComplete(order),
              )
            else
              _actionButton(
                label:
                    isProcessing
                        ? 'Memeriksa QRIS...'
                        : 'Selesaikan Order (Periksa QRIS)',
                color: hasPhoto ? Colors.green : Colors.grey,
                onPressed:
                    isProcessing || !hasPhoto
                        ? null
                        : () => _checkQrisThenComplete(order),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback? onPressed,
    Color color = const Color(0xFF5E60CE),
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
