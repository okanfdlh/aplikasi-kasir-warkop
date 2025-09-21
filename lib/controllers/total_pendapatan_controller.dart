import 'package:coffeeorder/models/total_pendapatan_model.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalPendapatanController extends GetxController {
  var totalPendapatan = TotalPendapatan(totalToday: 0, totalThisMonth: 0).obs;
  var isLoading = false.obs;

  final apiService = ApiService();

  Future<void> fetchTotalPendapatan() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get(
        '/api/orders/total-price',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        totalPendapatan.value = TotalPendapatan.fromJson(data);
      } else {
        totalPendapatan.value =
            TotalPendapatan(totalToday: 0, totalThisMonth: 0);
      }
    } catch (e, st) {
      print("fetchTotalPendapatan error: $e\n$st");
      totalPendapatan.value = TotalPendapatan(totalToday: 0, totalThisMonth: 0);
    } finally {
      isLoading(false);
    }
  }
}
