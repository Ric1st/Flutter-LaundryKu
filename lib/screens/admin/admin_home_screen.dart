import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import '../../providers/order_provider.dart';
import 'add_order_screen.dart';
import 'admin_order_detail_screen.dart';
import 'admin_profile_screen.dart';
import 'finance_report_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

Color _statusColor(String status) {
  switch (status) {
    case 'all':
      return const Color(0xFF5E60CE);
    case 'pending':
      return Colors.orange;
    case 'processing':
      return Colors.blue;
    case 'ready':
      return Colors.green;
    case 'completed':
      return Colors.teal;
    default:
      return Colors.grey;
  }
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<String> statusFilters = [
    'all',
    'pending',
    'processing',
    'ready',
    'completed',
  ];

  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.read<LoginProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final orders =
        selectedStatus == 'all'
            ? orderProvider.allOrders
            : orderProvider.allOrders
                .where((o) => o.status == selectedStatus)
                .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E60CE),
        title: Row(
          children: [
            const Icon(Icons.local_laundry_service, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Halo, ${loginProvider.nameController.text}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
                );
              } else if (value == 'report') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminFinanceDashboard(),
                  ),
                );
              } else if (value == 'logout') {
                loginProvider.logout(context);
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'profile', child: Text('Profil')),
                  PopupMenuItem(value: 'report', child: Text('Keuangan')),
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5E60CE),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOrderScreen()),
          );

          if (mounted) {
            context.read<OrderProvider>().loadAllOrders();
          }
        },
      ),

      body:
          orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  await orderProvider.loadAllOrders();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            statusFilters.map((status) {
                              final isSelected = selectedStatus == status;
                              final color = _statusColor(status);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: color,
                                  backgroundColor: color.withOpacity(0.12),
                                  onSelected: (_) {
                                    setState(() {
                                      selectedStatus = status;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (orders.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Text(
                            'Tidak ada order',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...orders.map((order) => _AdminOrderCard(order: order)),
                  ],
                ),
              ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final order;

  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDetailOrderScreen(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.serviceType} - ${order.weight} Kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Customer: ${order.customerName ?? '-'}',
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp ${order.price}',
                    style: const TextStyle(
                      color: Color(0xFF5E60CE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
