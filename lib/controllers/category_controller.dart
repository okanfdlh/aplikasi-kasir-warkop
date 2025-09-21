import 'package:coffeeorder/models/category_model.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryController extends GetxController {
  final categories = <Category>[].obs;
  final isLoading = true.obs;

  final apiService = ApiService();
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await apiService.dio.get(
        '/api/product-categories',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['data'];

        // Pindahkan dari data mentah (raw) ke list objek Category
        final List<Category> fetchedCategories = rawData.map((item) {
          return Category.fromJson(item);
        }).toList();

        // Perbarui list categories yang dapat diamati
        categories.value = fetchedCategories;
      }
    } catch (e) {
      print("Error fetch categories: $e");
    }
  }
}
