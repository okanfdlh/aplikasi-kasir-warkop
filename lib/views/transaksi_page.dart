import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final data = await OrderService.fetchOrders();
      setState(() {
        orders = data.where((order) => order['status'] == 'Selesai').toList();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void showOrderDetails(dynamic order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Detail Pesanan"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nama: ${order['customer_name']}", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Order ID: ${order['order_id']}"),
              Text("Meja: ${order['customer_meja'] ?? '-'}"),
              Text("Telepon: ${order['customer_phone']}"),
              Text("Catatan: ${order['notes'] ?? '-'}"),
              Text("Total Harga: Rp ${order['total_price']}", style: TextStyle(color: Colors.green)),
              Text("Status Pembayaran: ${order['status']}", style: TextStyle(color: Colors.blue)),
              Text("Dibuat: ${order['created_at']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
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
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(order['customer_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${order['order_id']}", style: TextStyle(color: Colors.grey[700])),
                        Text("Total: Rp ${order['total_price']}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => showOrderDetails(order),
                      child: Text("Detail Pesanan"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}