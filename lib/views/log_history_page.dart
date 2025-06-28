import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/order_service.dart';

class LogHistoryPage extends StatefulWidget {
  @override
  _LogHistoryPageState createState() => _LogHistoryPageState();
}

class _LogHistoryPageState extends State<LogHistoryPage> {
  List<dynamic> allOrders = [];
  Map<String, List<dynamic>> groupedByDate = {};
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      loadOrders();
    });
  }

  Future<void> loadOrders() async {
    try {
      final data = await OrderService.fetchOrders();
      final selesaiOrders = data.where((o) => o['status'] == 'Selesai').toList();
      final Map<String, List<dynamic>> grouped = {};

      for (var order in selesaiOrders) {
        final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(order['created_at']));
        grouped.putIfAbsent(dateStr, () => []).add(order);
      }

      setState(() {
        allOrders = selesaiOrders;
        groupedByDate = grouped;
      });
    } catch (e) {
      print('Error load history: $e');
    }
  }

  List<String> getAvailableYears() =>
      groupedByDate.keys.map((d) => DateTime.parse(d).year.toString()).toSet().toList()..sort((a, b) => b.compareTo(a));

  List<String> getAvailableMonths() {
    if (selectedYear == null) return [];
    return groupedByDate.keys
        .where((d) => DateTime.parse(d).year.toString() == selectedYear)
        .map((d) => DateTime.parse(d).month.toString().padLeft(2, '0'))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  List<String> getAvailableDays() {
    if (selectedYear == null || selectedMonth == null) return [];
    return groupedByDate.keys
        .where((d) =>
            DateTime.parse(d).year.toString() == selectedYear &&
            DateTime.parse(d).month.toString().padLeft(2, '0') == selectedMonth)
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  List<dynamic> getFilteredOrders() =>
      selectedDay != null ? groupedByDate[selectedDay!] ?? [] : [];

  @override
  Widget build(BuildContext context) {
    final orders = getFilteredOrders();
    final themeColor = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log History Pesanan"),
        backgroundColor: themeColor,
      ),
      body: Column(
        children: [
          Container(
            color: themeColor.withOpacity(0.05),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildDropdown(
                  hint: "Tahun",
                  value: selectedYear,
                  items: getAvailableYears(),
                  onChanged: (val) => setState(() {
                    selectedYear = val;
                    selectedMonth = null;
                    selectedDay = null;
                  }),
                ),
                const SizedBox(width: 8),
                _buildDropdown(
                  hint: "Bulan",
                  value: selectedMonth,
                  items: getAvailableMonths().map((m) => m).toList(),
                  displayText: (val) => DateFormat.MMMM('id_ID').format(DateTime(0, int.parse(val))),
                  onChanged: (val) => setState(() {
                    selectedMonth = val;
                    selectedDay = null;
                  }),
                ),
                const SizedBox(width: 8),
                _buildDropdown(
                  hint: "Tanggal",
                  value: selectedDay,
                  items: getAvailableDays(),
                  displayText: (val) => DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(val)),
                  onChanged: (val) => setState(() => selectedDay = val),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text("Tidak ada data"))
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          title: Text(order['customer_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Meja: ${order['customer_meja']} | Total: Rp${order['total_price']}", style: TextStyle(color: Colors.grey.shade700)),
                          trailing: const Icon(Icons.receipt_long, color: Colors.green),
                          onTap: () => _showDetail(order),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    String Function(String)? displayText,
    required void Function(String?) onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: Text(hint),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(displayText?.call(item) ?? item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _showDetail(dynamic order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text("Detail Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.person, "Nama", order['customer_name']),
              _buildInfoRow(Icons.table_restaurant, "Meja", order['customer_meja']),
              _buildInfoRow(Icons.phone, "No HP", order['customer_phone']),
              _buildInfoRow(Icons.attach_money, "Total", "Rp${order['total_price']}"),
              _buildInfoRow(Icons.payment, "Pembayaran", order['payment_status']),
              const SizedBox(height: 16),
              const Text("🧾 Item Pesanan:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order['order_items'].map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['product_name'], style: const TextStyle(fontSize: 14)),
                      Text("${item['quantity']}x", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: const Text("Tutup"),
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.green.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                    text: value.isEmpty ? "-" : value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
