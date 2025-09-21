import 'dart:async';
import 'dart:io';

import 'package:coffeeorder/firebase_option.dart';
import 'package:coffeeorder/models/coffee.dart';
// import 'package:coffeeorder/services/api_service.dart';
import 'package:coffeeorder/views/auth/signup.dart';
// import 'package:coffeeorder/views/auth/welcome.dart';
import 'package:coffeeorder/views/dashboard/dashboard_page.dart';
import 'package:coffeeorder/views/dashboard/detail_page.dart';
import 'package:coffeeorder/views/dashboard/onboard_page.dart';
import 'package:coffeeorder/views/profile/orders/order_page.dart';
// import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:coffeeorder/views/auth/login.dart';
import 'package:coffeeorder/views/auth/auth_check.dart';
import 'package:coffeeorder/views/dashboard/home_page.dart';
import 'package:coffeeorder/views/menu/menu_page.dart';
import 'package:coffeeorder/views/menu/tambah_menu_page.dart';
import 'package:coffeeorder/views/profile/my_profile/my_profil_page.dart';
import 'package:coffeeorder/views/profile/pendapatan/pendapatan_page.dart';
import 'package:coffeeorder/views/payment/pembayaran_page.dart';
import 'package:coffeeorder/views/log_history_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
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

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // final prefs = await SharedPreferences.getInstance();
  // final token = prefs.getString('token');
  // final apiService = ApiService();

  // // load order yang sudah pernah dikasih notif
  // Set<String> notifiedOrders =
  //     prefs.getStringList('notifiedOrderIds')?.toSet() ?? {};

  // Timer.periodic(const Duration(seconds: 15), (timer) async {
  //   if (service is AndroidServiceInstance &&
  //       !(await service.isForegroundService())) return;

  //   try {
  //     final response = await apiService.dio.get(
  //       '/api/orders',
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer $token",
  //           "Accept": "application/json",
  //         },
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       final List data = response.data;

  //       // cari order selesai yang belum dikasih notif
  //       final selesai = data.where((e) =>
  //           e['status'] == 'Selesai' &&
  //           !notifiedOrders.contains(e['order_id']));

  //       for (var order in selesai) {
  //         await flutterLocalNotificationsPlugin.show(
  //           order['order_id'].hashCode,
  //           'Orderan Selesai',
  //           'Pesanan #${order['order_id']} a.n. ${order['customer_name']} selesai.',
  //           const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               'order_channel',
  //               'Order Notif',
  //               importance: Importance.max,
  //               priority: Priority.high,
  //               icon: '@mipmap/ic_launcher',
  //             ),
  //           ),
  //         );

  //         // tandai kalau sudah notif
  //         notifiedOrders.add(order['order_id']);
  //       }

  //       // simpan list terbaru
  //       await prefs.setStringList('notifiedOrderIds', notifiedOrders.toList());
  //     }
  //   } catch (e) {
  //     print('Error fetch order: $e');
  //   }
  // });
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (khusus iOS, Android auto granted)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Inisialisasi notifikasi untuk Android dan iOS
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print(
        '📩 Pesan foreground masuk: ${message.notification?.title} - ${message.notification?.body}');

    if (message.notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'default_channel', // channel ID
        'Notifikasi', // nama channel
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();
      const notifDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title,
        message.notification?.body,
        notifDetails,
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    }
  });

  await initializeDateFormatting('id', null);
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/dashboard', page: () => DashboardPage()),
        GetPage(name: '/onboard', page: () => OnboardPage()),
        GetPage(
            name: '/detail',
            page: () {
              Coffee coffee = Get.arguments as Coffee;
              return DetailPage(coffee: coffee);
            }),
        GetPage(name: '/', page: () => AuthCheck()),
        // GetPage(name: '/welcome', page: () => WelcomePage()),
        GetPage(name: '/signup', page: () => Signup()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/menu', page: () => MenuPage()),
        GetPage(name: '/order', page: () => OrdersPage()),
        GetPage(
          name: '/my_profile',
          page: () => const EditWarungPage(),
        ),
        GetPage(name: '/pembayaran', page: () => PembayaranPage()),
        GetPage(
          name: '/laporan_pendapatan',
          page: () => const PendapatanPage(),
        ),
        GetPage(name: '/log_history', page: () => LogHistoryPage()),
        GetPage(
          name: '/TambahMenuPage',
          page: () => TambahMenuPage(bearerToken: Get.arguments),
        ),
      ],
    );
  }
}
