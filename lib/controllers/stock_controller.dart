import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockController extends GetxController {
  // 🔹 List global (buat kategori & pencarian)
  final products = <Product>[].obs;

  // 🔹 List per tab
  final allProducts = <Product>[].obs;
  final todayProducts = <Product>[].obs;
  final emptyProducts = <Product>[].obs;

  // 🔹 Filter kategori
  final categories = <String>[].obs;
  final selectedCategory = "Semua".obs;

  // 🔹 Loading state
  final isLoading = true.obs;

  final apiService = ApiService();

  @override
  void onInit() {
    // default load tab pertama (semua stok)
    fetchStock(filter: "all");
    super.onInit();
  }

  /// 🔹 Fetch data sesuai filter tab (all, today, empty)
  Future<void> fetchStock({String filter = "all"}) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get(
        '/api/stock',
        queryParameters: {'filter': filter},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> rawProducts = responseData['data'];
          final loadedProducts = rawProducts
              .map<Product>((item) => Product.fromJson(item))
              .toList();

          if (!isClosed) {
            // simpan data ke list sesuai tab
            switch (filter) {
              case "today":
                todayProducts.assignAll(loadedProducts);
                break;
              case "empty":
                emptyProducts.assignAll(loadedProducts);
                break;
              case "all":
              default:
                allProducts.assignAll(loadedProducts);
                break;
            }

            // simpan ke products global buat kategori + pencarian
            products.assignAll(loadedProducts);

            // update kategori
            categories.value = ["Semua"] +
                products
                    .map((p) => p.categoryName ?? "Tidak diketahui")
                    .toSet()
                    .toList();

            selectedCategory.value = "Semua";
          }
        }
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 🔹 Pencarian lokal di list global (allProducts/today/empty bisa dipilih manual)
  List<Product> searchProducts(String query, {String filter = "all"}) {
    final source = filter == "today"
        ? todayProducts
        : filter == "empty"
            ? emptyProducts
            : allProducts;

    if (query.isEmpty) return source;

    return source
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
