import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportController extends GetxController {
  final isLoading = true.obs;

  // 🔹 Data report
  final summary = {}.obs;
  final bestSeller = [].obs;
  final categorySales = [].obs;
  final dailySales = [].obs;
  final stockAudit = {}.obs;

  final apiService = ApiService();

  @override
  void onInit() {
    fetchReports();
    super.onInit();
  }

  Future<void> fetchReports() async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // 🔄 Ambil semua report paralel
      final responses = await Future.wait([
        apiService.dio.get('/api/reports/sales-summary',
            options: Options(headers: headers)),
        apiService.dio.get('/api/reports/best-seller',
            options: Options(headers: headers)),
        apiService.dio.get('/api/reports/sales-by-category',
            options: Options(headers: headers)),
        apiService.dio.get('/api/reports/daily-sales',
            options: Options(headers: headers)),
        apiService.dio.get('/api/reports/stock-audit',
            options: Options(headers: headers)),
      ]);

      // 🔹 Assign hasil ke state
      summary.value = responses[0].data ?? {};
      bestSeller.value = responses[1].data ?? [];
      categorySales.value = responses[2].data ?? [];
      dailySales.value = responses[3].data ?? [];
      stockAudit.value = responses[4].data ?? {};
    } catch (e) {
      print("❌ Error fetchReports: $e");
    } finally {
      isLoading(false);
    }
  }
}
