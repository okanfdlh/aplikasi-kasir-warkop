import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/order_service.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  Map<String, String> orderStatus = {}; // Menyimpan status lokal

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final data = await OrderService.fetchOrders();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        // Filter hanya status "Selesai" dan urutkan berdasarkan created_at terbaru
        orders = data
            .where((order) => order['status'] == 'Selesai')
            .toList()
          ..sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

        // Ambil status dari storage, jika tidak ada default ke "Belum Dibuat"
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
          title: Text("Detail Pesanan"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Order ID: ${order['order_id']}"),
              Text("Nama: ${order['customer_name']}"),
              Text("Meja: ${order['customer_meja'].isEmpty ? 'N/A' : order['customer_meja']}"),
              Text("No HP: ${order['customer_phone']}"),
              Text("Total Harga: Rp${order['total_price']}"),
              Text("Status Pembayaran: ${order['payment_status']}"),
              SizedBox(height: 10),
              Text("Detail Orderan:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...order['order_items'].map<Widget>((item) {
                return Text("- ${item['product_name']} (${item['quantity']}x)");
              }).toList(),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800, // Warna tombol hijau gelap
                foregroundColor: Colors.white, // Warna teks putih
              ),
              child: Text("Tutup"),
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
      appBar: AppBar(title: Text('Daftar Orderan Selesai')),
      body: orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                String orderId = order['order_id'];

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      order['customer_name'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: $orderId"),
                        Text("No. meja: ${order['customer_meja']}"),
                        Text("Total: Rp${order['total_price']}"),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              value: orderStatus[orderId],
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
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => showOrderDetails(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800, // Warna tombol hijau gelap
                        foregroundColor: Colors.white, // Warna teks putih
                      ),
                      child: Text("Detail Pesanan"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
