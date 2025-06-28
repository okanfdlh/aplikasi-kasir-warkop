import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/order_service.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  Map<String, String> orderStatus = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil ulang fetch setiap kali halaman dibuka
    fetchOrders();
  }


  Future<void> fetchOrders() async {
    try {
      final data = await OrderService.fetchOrders();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        orders = data
            .where((order) => order['status'] == 'Selesai')
            .toList()
          ..sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

        for (var order in orders) {
          String orderId = order['order_id'];
          orderStatus[orderId] = prefs.getString(orderId) ?? "Belum Dibuat";
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void showOrderDetails(dynamic order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detail Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🆔 Order ID: ${order['order_id']}"),
              Text("👤 Nama: ${order['customer_name']}"),
              Text("🍽️ Meja: ${order['customer_meja'].isEmpty ? 'N/A' : order['customer_meja']}"),
              Text("📞 No HP: ${order['customer_phone']}"),
              Text("💰 Total Harga: Rp${order['total_price']}"),
              Text("💳 Status Pembayaran: ${order['payment_status']}"),
              const SizedBox(height: 10),
              const Text("🧾 Detail Orderan:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...order['order_items'].map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("- ${item['product_name']} (${item['quantity']}x)"),
                );
              }).toList(),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Tutup"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(orderId, newStatus);

    setState(() {
      orderStatus[orderId] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final order = orders[index];
                String orderId = order['order_id'];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['customer_name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("🆔 Order ID: $orderId"),
                      Text("🍽️ Meja: ${order['customer_meja']}"),
                      Text("💰 Total: Rp${order['total_price']}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("📦 Status: ", style: TextStyle(fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: orderStatus[orderId],
                                icon: const Icon(Icons.arrow_drop_down),
                                style: const TextStyle(color: Colors.black),
                                items: ["Belum Dibuat", "Sedang Dibuat", "Selesai"]
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    updateOrderStatus(orderId, newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => showOrderDetails(order),
                          child: const Text("Detail Pesanan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
