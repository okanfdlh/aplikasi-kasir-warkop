import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:coba1/views/login_page.dart';
import 'package:coba1/views/auth_check.dart';
import 'package:coba1/views/home_page.dart';
import 'package:coba1/views/menu_page.dart';
import 'package:coba1/views/transaksi_page.dart';
import 'package:coba1/views/tambah_menu_page.dart';
import 'package:coba1/views/profil_page.dart';
import 'package:coba1/views/pendapatan_page.dart';
import 'package:coba1/views/pembayaran_page.dart';
import 'package:coba1/views/log_history_page.dart';

import '../widgets/bar_chart_widget.dart';
import 'package:animate_do/animate_do.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi lokal
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  Timer.periodic(Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance && !(await service.isForegroundService())) return;

    final response = await http.get(
      Uri.parse('https://rumahseduh.shbhosting999.my.id/api/order'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final selesai = data.where((e) => e['status'] == 'Selesai');
      if (selesai.isNotEmpty) {
        await flutterLocalNotificationsPlugin.show(
          888,
          'Orderan Selesai',
          'Ada ${selesai.length} orderan baru!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'order_channel', // channelId
              'Order Notif',   // channelName
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    }
  });
}

// @pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
// @pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Inisialisasi notifikasi di awal
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => AuthCheck()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/menu', page: () => MenuPage()),
        GetPage(name: '/transaksi', page: () => OrdersPage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/pembayaran', page: () => PembayaranPage()),
        GetPage(name: '/laporan_pendapatan', page: () => PendapatanPage()),
        GetPage(name: '/log_history', page: () => LogHistoryPage()),
        GetPage(
          name: '/TambahMenuPage',
          page: () => TambahMenuPage(
            bearerToken: Get.arguments,
          ),
        ),
      ],
    );
  }
}
