import 'dart:async';
import 'package:coffeeorder/controllers/menu_controller.dart'
    as MyMenuController;
import 'package:coffeeorder/controllers/total_pendapatan_controller.dart';
import 'package:coffeeorder/views/dashboard/dashboard_fragments/home_fragment.dart';
import 'package:coffeeorder/views/dashboard/components/custom_snackbar_exit.dart';
import 'package:coffeeorder/views/menu/menu_page.dart';
import 'package:coffeeorder/views/menu/tambah_menu_page.dart';
import 'package:coffeeorder/views/profile/profile_page.dart';
import 'package:coffeeorder/views/stock/stock_page.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  static DashboardPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<DashboardPageState>();

  int indexMenu = 0;
  String token = '';
  List<Map<String, dynamic>> menu = [];

  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
    loadTokenAndMenu();
  }

  Future<void> loadTokenAndMenu() async {
    // Load token dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    // Buat menu setelah token tersedia
    menu = [
      {
        'icon': 'assets/ic_home_border.png',
        'icon_active': 'assets/ic_home_filled.png',
        'fragment': const HomeFragment(),
      },
      {
        'icon': 'assets/ic_menu.png',
        'icon_active': 'assets/ic_menu.png',
        'fragment': MenuPage(),
      },
      {
        'icon': 'assets/ic_plus.png',
        'icon_active': 'assets/ic_plus.png',
        'fragment': TambahMenuPage(bearerToken: token),
      },
      {
        'icon': 'assets/ic_stock.png',
        'icon_active': 'assets/ic_stock.png',
        'fragment': StokPage(),
      },
      {
        'icon': 'assets/ic_user.png',
        'icon_active': 'assets/ic_user.png',
        'fragment': ProfilePage(),
      },
    ];

    // Update UI setelah menu siap
    setState(() {});
  }

  // Fungsi navigasi internal
  void goToDashboard() => setState(() => indexMenu = 0);
  void goToMenu() => setState(() => indexMenu = 1);
  void goToOrder() => setState(() => indexMenu = 2);
  void goToPendapatan() => setState(() => indexMenu = 3);
  void goToStatistic() => setState(() => indexMenu = 3);

  // Method untuk custom snackbar
  void _showCustomExitSnackbar() {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CustomExitSnackbar(
        onDismiss: () {
          overlayEntry?.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss setelah 2 detik
    Timer(const Duration(seconds: 2), () {
      overlayEntry?.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Jika menu belum siap, tampilkan loading
    if (menu.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          _showCustomExitSnackbar(); // panggil snackbar custom
          return false; // cegah keluar dulu
        }
        return true; // keluar kalau tekan 2x
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 247, 243),
        body: menu[indexMenu]['fragment'] as Widget,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xffE0E0E0),
                width: 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: List.generate(menu.length, (index) {
              Map item = menu[index];
              bool isActive = indexMenu == index;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    indexMenu = index;

                    if (index == 0) {
                      final menuController =
                          Get.find<MyMenuController.MenuController>();
                      final pendapatanController =
                          Get.find<TotalPendapatanController>();

                      menuController.fetchBestSellers();
                      menuController.fetchsellersLastWeekProducts();
                      pendapatanController
                          .fetchTotalPendapatan(); // kalau ada method ini
                    }

                    setState(() {}); // update UI
                  },
                  child: SizedBox(
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(20),
                        ImageIcon(
                          AssetImage(item[isActive ? 'icon_active' : 'icon']),
                          size: 24,
                          color: Color(isActive ? 0xff024924 : 0xffA2A2A2),
                        ),
                        if (isActive) const Gap(6),
                        if (isActive)
                          Container(
                            height: 5,
                            width: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xff024924),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
