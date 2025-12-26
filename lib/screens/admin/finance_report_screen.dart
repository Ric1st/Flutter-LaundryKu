import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/payment_provider.dart';

class AdminFinanceDashboard extends StatefulWidget {
  const AdminFinanceDashboard({super.key});

  @override
  State<AdminFinanceDashboard> createState() => _AdminFinanceDashboardState();
}

class _AdminFinanceDashboardState extends State<AdminFinanceDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Keuangan',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF5E60CE),
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _filterDropdown(provider),
                  const SizedBox(height: 16),
                  _summarySection(provider),
                  const SizedBox(height: 24),
                  _chartSection(provider),
                ],
              ),
    );
  }

  Widget _filterDropdown(PaymentProvider provider) {
    return DropdownButtonFormField(
      value: provider.filter,
      decoration: const InputDecoration(
        labelText: 'Filter Waktu',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'harian', child: Text('Harian')),
        DropdownMenuItem(value: 'bulanan', child: Text('Bulanan')),
      ],
      onChanged: (value) => provider.changeFilter(value!),
    );
  }

  Widget _summarySection(PaymentProvider provider) {
    return Row(
      children: [
        _summaryCard('Total Order', provider.totalOrders, Colors.blue),
        _summaryCard('Selesai', provider.completedOrders, Colors.green),
        _summaryCard('Pendapatan', provider.totalIncome, Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartSection(PaymentProvider provider) {
    if (provider.chartData.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grafik Pendapatan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          provider.filter == 'harian' ? 'Harian' : 'Bulanan',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: provider.maxChartValue + 20000,
              barTouchData: _barTouchData(),
              titlesData: _titlesData(provider),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: _barGroups(provider),
            ),
          ),
        ),
      ],
    );
  }

  BarTouchData _barTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.black87,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            'Rp ${rod.toY.toInt()}',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
      ),
    );
  }

  FlTitlesData _titlesData(PaymentProvider provider) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 20000,
          getTitlesWidget: (value, _) {
            return Text(
              '${value ~/ 1000}K',
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            final index = value.toInt();
            if (index < 0 || index >= provider.chartData.length) {
              return const SizedBox.shrink();
            }
            return Text(
              provider.chartData.keys.elementAt(index),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _barGroups(PaymentProvider provider) {
    int x = 0;
    return provider.chartData.entries.map((e) {
      final group = BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
      x++;
      return group;
    }).toList();
  }
}
