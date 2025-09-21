import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:coffeeorder/controllers/report_controller.dart';

class PendapatanPage extends StatefulWidget {
  const PendapatanPage({Key? key}) : super(key: key);

  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  final ReportController controller = Get.put(ReportController());

  @override
  void initState() {
    super.initState();
    controller.fetchReports();
  }

  String formatCurrency(dynamic v) {
    double val;
    if (v == null) {
      val = 0;
    } else if (v is num) {
      val = v.toDouble();
    } else {
      val = double.tryParse(v.toString()) ?? 0;
    }
    // Pakai Intl untuk format IDR
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Pendapatan"),
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        // Obx memantau semua Rx yang dipakai di closure ini
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchReports,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildBestSeller(),
                const SizedBox(height: 16),
                _buildCategoryChart(),
                const SizedBox(height: 16),
                _buildDailySalesChart(),
                const SizedBox(height: 16),
                _buildStockAudit(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 🔹 Ringkasan Penjualan
  Widget _buildSummaryCard() {
    // ignore: invalid_use_of_protected_member
    final s = controller.summary.value;
    final totalSales = s['total_sales'];
    final totalOrders = s['total_orders'] ?? 0;
    final avgOrder = s['avg_order'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem("Total Penjualan", formatCurrency(totalSales)),
            _summaryItem("Total Order", "${totalOrders.toString()}"),
            _summaryItem("Rata2 Order", formatCurrency(avgOrder)),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // 🔹 Produk Terlaris
  Widget _buildBestSeller() {
    final List best = List.from(controller.bestSeller);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ExpansionTile(
        title: const Text("Produk Terlaris"),
        children: best.isEmpty
            ? [
                const ListTile(
                  title: Text("Belum ada data best seller"),
                )
              ]
            : best.map<Widget>((item) {
                final name = item['product_name'] ?? '-';
                final qty = item['quantity'] ?? 0;
                final revenue = item['revenue'];
                return ListTile(
                  leading: const Icon(Icons.local_dining, color: Colors.teal),
                  title: Text(name),
                  subtitle: Text("Terjual: ${qty.toString()}"),
                  trailing: Text(formatCurrency(revenue)),
                );
              }).toList(),
      ),
    );
  }

  // 🔹 Penjualan per Kategori (Pie Chart)
  Widget _buildCategoryChart() {
    final categories = List.from(controller.categorySales);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Penjualan per Kategori",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const SizedBox(
                  height: 120,
                  child: Center(child: Text("Tidak ada data kategori"))),
            if (categories.isNotEmpty)
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 30,
                    sections: categories
                        .asMap()
                        .entries
                        .map<PieChartSectionData>((e) {
                      final idx = e.key;
                      final item = e.value;
                      final valueNum = item['total_sales'] is num
                          ? (item['total_sales'] as num).toDouble()
                          : double.tryParse('${item['total_sales']}') ?? 0.0;
                      final title = item['category'] ?? 'Lainnya';
                      final color =
                          Colors.primaries[idx % Colors.primaries.length];
                      return PieChartSectionData(
                        value: valueNum,
                        title: title,
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        color: color,
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 Tren Harian (Line Chart pakai index tanggal bulan)
  Widget _buildDailySalesChart() {
    final daily = List.from(controller.dailySales);

    if (daily.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const SizedBox(
          height: 140,
          child: Center(child: Text("Tidak ada data tren harian")),
        ),
      );
    }

    final spots = <FlSpot>[];
    final days = <int>[];

    for (var i = 0; i < daily.length; i++) {
      final item = daily[i];
      final raw = item['total_sales'];
      final y = raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0.0;

      // Ambil hari dari field date ("2025-09-19" -> 19)
      final dateStr = item['date'];
      final parsedDate = DateTime.tryParse(dateStr);
      final dayNum = parsedDate?.day ?? (i + 1);

      spots.add(FlSpot(dayNum.toDouble(), y));
      days.add(dayNum);
    }

    // Cari max Y biar auto-scale
    double maxY = 0;
    for (final s in spots) {
      if (s.y > maxY) maxY = s.y;
    }
    maxY = maxY == 0 ? 1 : maxY;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tren Penjualan Harian",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: maxY / 5,
                        getTitlesWidget: (value, meta) {
                          return Text("Rp ${value.toInt()}",
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            1, // tampilkan tiap 5 hari biar gak terlalu rapat
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        // getTitlesWidget: (value, meta) {
                        //   if (value % 5 == 0 || value == 1) {
                        //     return Text(
                        //       value.toInt().toString(),
                        //       style: const TextStyle(fontSize: 10),
                        //     );
                        //   }
                        //   return const SizedBox.shrink();
                        // },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Audit Stok
  Widget _buildStockAudit() {
    // ignore: invalid_use_of_protected_member
    final stock = controller.stockAudit.value;
    final lowStock = List.from(stock['low_stock'] ?? []);
    final outOfStock = List.from(stock['out_of_stock'] ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ExpansionTile(
        title: const Text("Audit Stok"),
        children: [
          const ListTile(
            title: Text("Stok Menipis"),
            tileColor: Colors.orangeAccent,
          ),
          if (lowStock.isEmpty)
            const ListTile(title: Text("Tidak ada produk dengan stok menipis")),
          ...lowStock.map<Widget>((p) => ListTile(
                title: Text(p['name'] ?? '-'),
                subtitle: Text(
                    "Sisa: ${p['stock'] ?? 0} (Min: ${p['min_stock'] ?? 0})"),
              )),
          const Divider(),
          const ListTile(
            title: Text("Stok Habis"),
            tileColor: Colors.redAccent,
          ),
          if (outOfStock.isEmpty)
            const ListTile(title: Text("Tidak ada produk habis")),
          ...outOfStock.map<Widget>((p) => ListTile(
                title: Text(p['name'] ?? '-'),
                subtitle: Text("Sisa: ${p['stock'] ?? 0}"),
              )),
        ],
      ),
    );
  }
}
