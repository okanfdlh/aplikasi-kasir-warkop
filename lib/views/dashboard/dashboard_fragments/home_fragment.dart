import 'package:coffeeorder/controllers/cart_controller.dart';
import 'package:coffeeorder/controllers/total_pendapatan_controller.dart';
import 'package:coffeeorder/views/cart/cart_page.dart';
import 'package:coffeeorder/views/dashboard/dashboard_page.dart';
import 'package:coffeeorder/views/menu/components/product_card.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:coffeeorder/controllers/menu_controller.dart'
    as MyMenuController;

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  String categorySelected = 'Semua Menu';
  final MyMenuController.MenuController menuController =
      Get.put(MyMenuController.MenuController());
  final TotalPendapatanController totalPendapatanController =
      Get.put(TotalPendapatanController());

  String storeName = "RUMAH SEDUH";
  String storeAddress = "Jl. Parit Pekir Sebelah SDN 13\nSungailiat - Bangka";
  String? storeImagePath;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _saveFcmToken();
    Get.put(CartController());
    categorySelected = menuController.selectedCategory.value;
    menuController.fetchBestSellers();
    menuController.fetchsellersLastWeekProducts();
    totalPendapatanController.fetchTotalPendapatan();
  }

  Future<void> _saveFcmToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print("FCM Token: $fcmToken");
      // TODO: kirim ke backend lo juga
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // biar putih bersih di belakang
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              buildBackground(), // ini header 280px
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Gap(68),
                    buildHeader(),
                    const Gap(30),
                    buildSearch(),
                    const Gap(24),
                    _buildInfoCard(context),
                    const Gap(24),
                    _buildGraphicCard(),
                    const Gap(24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white, // konten tetap putih
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Top Menu ⭐',
                                  style: TextStyle(
                                    color: Color(0xff024924),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => DashboardPageState.of(context)
                                      ?.goToMenu(),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Menu lainnya',
                                        style: TextStyle(
                                          color: Color(0xff024924),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Color(0xff024924),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          buildGridCoffee(),
                          const Gap(16),
                        ],
                      ),
                    ),
                    const Gap(16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      height: 210,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff024924),
            Color.fromARGB(255, 1, 44, 22),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24), // radius kiri bawah
          bottomRight: Radius.circular(24), // radius kanan bawah
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        // 👉 Gambar Warung
        ClipRRect(
          borderRadius: BorderRadius.circular(8), // biar pojok rounded
          child: Image.asset(
            'assets/icon/app_icon.png', // ganti dengan gambar lo
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        ),

        const Gap(12),

        // 👉 Nama Warung
        const Expanded(
          child: Text(
            'Rumah Seduh',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xffD8D8D8),
            ),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Color(0xffA2A2A2),
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor:
                      Colors.transparent, // biar cardnya keliatan floating
                  builder: (context) =>
                      const AddressCard(), // panggil class card
                );
              },
              child: Row(
                children: [
                  const Text(
                    'Bangka Belitung, Sungailiat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xffD8D8D8),
                    ),
                  ),
                  const Gap(4),
                  Image.asset(
                    'assets/ic_arrow_down.png',
                    height: 14,
                    width: 14,
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 3, 90, 45),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                ImageIcon(
                  AssetImage('assets/ic_search.png'),
                  color: Colors.white,
                ),
                Gap(8),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Cari Menu',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: Color(0xffA2A2A2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 90, 45),
            borderRadius: BorderRadius.circular(12),
          ),
          // Tombol keranjang
          alignment: Alignment.center,
          child: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () => Get.to(() => CartPage()),
          ),
        ),
        const Gap(16),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 90, 45),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.notifications,
            size: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget buildBannerPromo() {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(16),
  //     child: Image.asset(
  //       'assets/banner.png',
  //       width: double.infinity,
  //       height: 140,
  //       fit: BoxFit.cover,
  //     ),
  //   );
  // }

  Widget _buildInfoCard(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return InkWell(
      borderRadius:
          BorderRadius.circular(16), // biar ripple ngikutin sudut card
      onTap: () => DashboardPageState.of(context)?.goToPendapatan(),

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff024924),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Omset Hari ini',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  return Text(
                    currency.format(
                      totalPendapatanController
                          .totalPendapatan.value.totalToday,
                      // .totalPendapatan.value.totalThisMonth,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                })
              ],
            ),
            const Text('Versi 1.0', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

// 1. Tambahkan method untuk mengonversi data API menjadi data chart
  List<FlSpot> _convertToChartData() {
    // Buat map untuk menghitung total penjualan per hari dalam seminggu
    Map<int, int> dailySales = {
      1: 0, // Senin
      2: 0, // Selasa
      3: 0, // Rabu
      4: 0, // Kamis
      5: 0, // Jumat
      6: 0, // Sabtu
      0: 0, // Minggu (DateTime.weekday minggu = 7, tapi kita pakai 0)
    };

    // Proses data dari sellersLastWeekProducts
    for (var product in menuController.sellersLastWeekProducts) {
      try {
        // Parse tanggal penjualan terakhir
        DateTime lastSoldDate = product.lastSoldAt!;

        // Dapatkan hari dalam seminggu (1=Senin, 7=Minggu)
        int weekday = lastSoldDate.weekday;
        int chartIndex = weekday == 7 ? 0 : weekday; // Minggu jadi index 0

        // Tambahkan total_sold ke hari yang sesuai
        int totalSold = product.totalSold;
        dailySales[chartIndex] = (dailySales[chartIndex] ?? 0) + totalSold;
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Konversi ke List<FlSpot> untuk chart
    // Index 0=Senin, 1=Selasa, ..., 6=Minggu
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      int dayIndex = i == 6 ? 0 : i + 1; // Minggu (0) dipindah ke index 6
      spots.add(FlSpot(i.toDouble(), dailySales[dayIndex]?.toDouble() ?? 0));
    }

    return spots;
  }

// 2. Method untuk menghitung maxY secara dinamis
  double _getMaxY() {
    List<FlSpot> spots = _convertToChartData();
    if (spots.isEmpty) return 25;

    double maxValue =
        spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // Tambahkan buffer 20% dan minimal 5
    return (maxValue * 1.2).clamp(5.0, double.infinity);
  }

// 3. Widget chart yang sudah diupdate
  Widget _buildGraphicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penjualan Minggu Lalu',
                style: TextStyle(
                  color: Color(0xff024924),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => DashboardPageState.of(context)?.goToStatistic(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selengkapnya',
                      style: TextStyle(
                        color: Color(0xff024924),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xff024924),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tambahkan loading indicator
          Obx(
            () => menuController.isLoading.value
                ? const SizedBox(
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff024924),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 250,
                    child: menuController.sellersLastWeekProducts.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada data penjualan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: _getMaxY(),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                                horizontalInterval: _getMaxY() / 5,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    interval: _getMaxY() / 5,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const days = [
                                        "Sen",
                                        "Sel",
                                        "Rab",
                                        "Kam",
                                        "Jum",
                                        "Sab",
                                        "Min"
                                      ];
                                      int index = value.toInt();
                                      if (index >= 0 && index < days.length) {
                                        return Text(
                                          days[index],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _convertToChartData(),
                                  isCurved: false,
                                  color: const Color(0xff024924),
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: const Color(0xff024924),
                                        strokeColor: Colors.white,
                                        strokeWidth: 2,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xff024924)
                                            .withOpacity(0.3),
                                        const Color(0xff024924)
                                            .withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
          )
        ],
      ),
    );
  }

  // Widget buildCategories() {
  //   final categories = menuController.categories;

  //   return SizedBox(
  //     height: 29,
  //     child: ListView.builder(
  //       itemCount: categories.length,
  //       scrollDirection: Axis.horizontal,
  //       physics: const BouncingScrollPhysics(),
  //       itemBuilder: (context, index) {
  //         String category = categories[index];
  //         bool isActive = categorySelected == category;
  //         return GestureDetector(
  //           onTap: () {
  //             setState(() {
  //               categorySelected = category;
  //             });
  //             menuController.selectedCategory.value = category;
  //             menuController.filterProducts();
  //           },
  //           child: Container(
  //             margin: EdgeInsets.only(
  //               left: index == 0 ? 24 : 8,
  //               right: index == categories.length - 1 ? 24 : 8,
  //             ),
  //             decoration: BoxDecoration(
  //               color: isActive
  //                   ? const Color(0xff024924)
  //                   : const Color.fromARGB(255, 220, 255, 217)
  //                       .withValues(alpha: 0.35),
  //               borderRadius: BorderRadius.circular(6),
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 8),
  //             alignment: Alignment.center,
  //             child: Text(
  //               category,
  //               style: TextStyle(
  //                 fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
  //                 fontSize: 14,
  //                 color: isActive ? Colors.white : const Color(0xff313131),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget buildGridCoffee() {
    return Obx(() {
      if (menuController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (menuController.bestSellerProducts.isEmpty) {
        return const Center(child: Text("Belum ada produk terjual"));
      }

      return GridView.builder(
        itemCount: menuController.bestSellerProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 270, // agak lebih tinggi biar muat tombol
          crossAxisSpacing: 15,
          mainAxisSpacing: 24,
        ),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final product = menuController.bestSellerProducts[index];

          return ProductCard(
            product: product,
            onPesan: (quantity) {
              final CartController cartController = Get.put(
                CartController(),
              );
              cartController.addToCart(
                menuController.bestSellerProducts[index],
                quantity,
              );

              Get.rawSnackbar(
                message:
                    "$quantity ${menuController.bestSellerProducts[index].name} dimasukkan ke keranjang",
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.black,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              );
            },
          );
        },
      );
    });
  }
}

// Class kebutuhan lain
class AddressCard extends StatelessWidget {
  const AddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 100), // floating effect
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Alamat Lengkap',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Jl. Parit Pekir, Sungailiat, Bangka Belitung, Indonesia',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
