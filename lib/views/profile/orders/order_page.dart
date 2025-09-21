import 'dart:async';
import 'package:coffeeorder/controllers/order_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String filter = 'Hari Ini';
  final OrderController orderController = Get.put(OrderController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Set<String> notifiedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadNotifiedOrders();
    orderController.fetchOrders().then((_) {
      _handleOrders(orderController.orders);
    });

    // Tambahin listener FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleFCMMessage(message);
    });
  }

  void _handleFCMMessage(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      final orderId = message.data['order_id'];
      final status = message.data['status'];
      final customerName = message.data['customer_name'];

      if (status == "selesai" && !notifiedOrderIds.contains(orderId)) {
        await _showOrderNotification(orderId, customerName);
        notifiedOrderIds.add(orderId);
        await _saveNotifiedOrders();
      }

      // update tampilan list tanpa refresh berkala
      await orderController.fetchOrders();
    }
  }

  @override
  void dispose() {
    // Gak perlu _timer?.cancel();
    super.dispose();
  }

  /// === Notifikasi ===
  Future<void> _initializeNotifications() async {
    // Minta izin jika Android 13+
    await _requestNotificationPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> _requestNotificationPermission() async {
    if (await Permission.notification.isGranted) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> _showOrderNotification(
    String orderId,
    String customerName,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_channel_id',
      'Order Notifications',
      channelDescription: 'Notifikasi untuk pesanan yang selesai',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Pesanan Selesai!',
      'Pesanan atas nama $customerName telah selesai.',
      platformChannelSpecifics,
    );
  }

  /// === Simpan & Load Notifikasi ===
  Future<void> _saveNotifiedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifiedOrderIds', notifiedOrderIds.toList());
  }

  Future<void> _loadNotifiedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('notifiedOrderIds') ?? [];
    notifiedOrderIds = saved.toSet();
  }

  /// === Handle Order & Notifikasi ===
  void _handleOrders(List<dynamic> newOrders) async {
    final prefs = await SharedPreferences.getInstance();

    for (var order in newOrders) {
      final id = order['order_id'];
      final status = order['status'];

      // Ambil status lama dari prefs
      final prevStatus = prefs.getString(id);

      // Kalau status berubah ke "Selesai" dan belum pernah notif
      if (status == "Selesai" && prevStatus != "Selesai") {
        if (!notifiedOrderIds.contains(id)) {
          await _showOrderNotification(id, order['customer_name']);
          notifiedOrderIds.add(id);
          await _saveNotifiedOrders(); // simpan biar persistent
        }
      }

      // Update status terbaru ke prefs
      await prefs.setString(id, status);
    }
  }

  /// === UI ===
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Belum Dibuat':
        return Colors.orange.shade400;
      case 'Sedang Dibuat':
        return Colors.blue.shade400;
      case 'Selesai':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Belum Dibuat':
        return Icons.schedule;
      case 'Sedang Dibuat':
        return Icons.local_dining;
      case 'Selesai':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff024924),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // warna panah kembali
        ),
      ),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = orderController.orders;

        if (orders.isEmpty) {
          return const Center(child: Text("Belum ada pesanan."));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(
                  _getStatusIcon(order['status']),
                  color: _getStatusColor(order['status']),
                ),
                title: Text("Order #${order['order_id']}"),
                subtitle: Text("Atas nama: ${order['customer_name']}"),
                trailing: Text(
                  order['status'],
                  style: TextStyle(
                    color: _getStatusColor(order['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _showOrderDetailDialog(order),
              ),
            );
          },
        );
      }),
    );
  }

  /// Dialog detail pesanan
  void _showOrderDetailDialog(dynamic order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detail Pesanan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Order ID: ${order['order_id']}"),
            Text("Nama: ${order['customer_name']}"),
            Text("Meja: ${order['customer_meja'] ?? '-'}"),
            Text("Total: Rp${order['total_price']}"),
            Text("Status: ${order['status']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
