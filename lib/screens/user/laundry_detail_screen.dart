import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';

class LaundryDetailScreen extends StatefulWidget {
  final order;

  const LaundryDetailScreen({super.key, required this.order});

  @override
  State<LaundryDetailScreen> createState() => _LaundryDetailScreenState();
}

class _LaundryDetailScreenState extends State<LaundryDetailScreen> {
  final GlobalKey _qrKey = GlobalKey();
  String selectedPaymentMethod = 'qris';
  bool isProcessingPayment = false;

  bool get isPaid => widget.order.isPaid == true;

  Future<void> _processPayment() async {
    setState(() => isProcessingPayment = true);

    try {
      final paymentProvider = context.read<PaymentProvider>();

      final exists = await paymentProvider.checkPaymentExists(widget.order.id);
      if (exists) {
        throw Exception('Order ini sudah memiliki pembayaran');
      }

      await paymentProvider.createPayment(
        orderId: widget.order.id,
        amount: widget.order.price,
        paymentMethod: selectedPaymentMethod,
      );

      if (mounted) {
        await context.read<OrderProvider>().loadOrders(widget.order.customerId);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 8),
                  Text('Pembayaran Berhasil'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pembayaran sebesar Rp ${widget.order.price} telah dicatat',
                  ),
                  const SizedBox(height: 8),
                  Text('Metode: ${selectedPaymentMethod.toUpperCase()}'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E60CE),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.order;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E60CE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Cucian',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoCard(orders),
          const SizedBox(height: 32),

          if (orders.status == 'selesai') ...[
            _completedPhotoSection(orders),
          ] else if (!orders.isPaid && orders.status == 'ready') ...[
            _paymentSection(orders),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(order) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Layanan', order.serviceType),
            _infoRow('Berat', '${order.weight} Kg'),
            _infoRow('Harga', 'Rp ${order.price}'),
            const SizedBox(height: 12),
            _statusBadge(order.status),
          ],
        ),
      ),
    );
  }

  Widget _paidCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(width: 16),
            const Text(
              'Pembayaran Lunas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'MENUNGGU';
        break;
      case 'processing':
        color = Colors.blue;
        text = 'DIPROSES';
        break;
      case 'ready':
        color = Colors.green;
        text = 'SIAP';
        break;
      case 'selesai':
        color = Colors.teal;
        text = 'SELESAI';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _paymentSection(order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                _paymentMethodTile(
                  method: 'qris',
                  icon: Icons.qr_code_scanner,
                  label: 'QRIS',
                  color: const Color(0xFF5E60CE),
                ),

                const SizedBox(height: 8),

                _paymentMethodTile(
                  method: 'cash',
                  icon: Icons.money,
                  label: 'Cash',
                  color: Colors.green,
                ),

                const SizedBox(height: 8),

                _paymentMethodTile(
                  method: 'kupon',
                  icon: Icons.confirmation_number,
                  label: 'Kupon',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        if (selectedPaymentMethod == 'qris')
          Center(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Scan QRIS untuk Bayar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: order.id,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),

        Card(
          elevation: 4,
          color: const Color(0xFF5E60CE).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rp ${order.price}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E60CE),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessingPayment ? null : _processPayment,
            icon:
                isProcessingPayment
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.payment, color: Colors.white),
            label: Text(
              isProcessingPayment ? 'Memproses...' : 'Bayar Sekarang',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E60CE),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodTile({
    required String method,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _completedPhotoSection(order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laundry Selesai',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (order.photoURL != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    order.photoURL!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: const Text(
                      'Laundry Belum Diambil',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _paidCard(),
      ],
    );
  }
}
