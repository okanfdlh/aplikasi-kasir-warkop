import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pendapatan_model.dart';
// import '../models/produk_terlaris_model.dart';
import '../services/api_service.dart';

class OrderController extends GetxController {
  var orders = <dynamic>[].obs;
  var pendapatan = <PendapatanModel>[].obs;
  var produkTerlaris = <ProdukTerlarisModel>[].obs;
  var isLoading = false.obs;

  final apiService = ApiService();

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get('/api/orders',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ));

      if (response.statusCode == 200 && response.data != null) {
        orders.value = response.data;
      } else {
        orders.clear();
      }
    } catch (e, st) {
      print("fetchOrders error: $e\n$st");
      orders.clear();
    } finally {
      isLoading(false);
    }
  }

  /// Ambil order dengan status "Selesai"
  List<dynamic> get selesaiOrders =>
      orders.where((o) => o['status'] == 'selesai').toList();

  /// Group order selesai berdasarkan tanggal
  Map<String, List<dynamic>> get groupedByDate {
    final Map<String, List<dynamic>> grouped = {};
    for (var order in selesaiOrders) {
      final dateStr =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(order['created_at']));
      grouped.putIfAbsent(dateStr, () => []).add(order);
    }
    return grouped;
  }

  // Future<void> fetchPendapatan({
  //   String type = 'day',
  //   int? year,
  //   int? month,
  //   int? day,
  // }) async {
  //   try {
  //     isLoading(true);
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');

  //     final query = {
  //       'type': type,
  //       'year': year?.toString() ?? DateTime.now().year.toString(),
  //       if (month != null) 'month': month.toString(),
  //       if (day != null) 'day': day.toString(),
  //     };

  //     final response = await apiService.dio.get(
  //       '/api/pendapatan',
  //       queryParameters: query,
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );

  //     // print('📥 Pendapatan URI: /api/pendapatan$params');
  //     print('📤 Status: ${response.statusCode}');
  //     print('📤 Body: ${response.data}');

  //     if (response.statusCode == 200 && response.data != null) {
  //       final List<dynamic> body = response.data;
  //       pendapatan.value =
  //           body.map((item) => PendapatanModel.fromJson(item)).toList();
  //     } else {
  //       pendapatan.clear();
  //     }
  //   } catch (e, st) {
  //     print("fetchPendapatan error: $e\n$st");
  //     pendapatan.clear();
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // Future<void> fetchProdukTerlaris({
  //   int? year,
  //   int? month,
  // }) async {
  //   try {
  //     isLoading(true);
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');

  //     final query = {
  //       if (year != null) 'year': year.toString(),
  //       if (month != null) 'month': month.toString(),
  //     };

  //     final response = await apiService.dio.get(
  //       '/api/produk-terlaris',
  //       queryParameters: query,
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );

  //     // print('📥 Produk URI: /api/produk-terlaris$params');
  //     print('📤 Status: ${response.statusCode}');
  //     print('📤 Body: ${response.data}');

  //     if (response.statusCode == 200 && response.data != null) {
  //       final List<dynamic> body = response.data;
  //       produkTerlaris.value =
  //           body.map((item) => ProdukTerlarisModel.fromJson(item)).toList();
  //     } else {
  //       produkTerlaris.clear();
  //     }
  //   } catch (e, st) {
  //     print("fetchProdukTerlaris error: $e\n$st");
  //     produkTerlaris.clear();
  //   } finally {
  //     isLoading(false);
  //   }
  // }
}
