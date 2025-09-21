import 'dart:io';

import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:path/path.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuController extends GetxController {
  final products = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final bestSellerProducts = <Product>[].obs;
  final sellersLastWeekProducts = <Product>[].obs;
  final totalPendapatan = <Product>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = "Semua".obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  final apiService = ApiService();

  /// 🔄 Ambil semua produk dari API
  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get('/api/products',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ));

      print("URL dipanggil: ${response.realUri}");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> rawProducts = responseData['data'];
          final loadedProducts = rawProducts
              .map<Product>((item) => Product.fromJson(item))
              .toList();

          if (!isClosed) {
            products.value = loadedProducts;
            categories.value = ["Semua"] +
                products
                    .map((p) => p.categoryName ?? "Tidak diketahui")
                    .toSet()
                    .toList();

            selectedCategory.value = "Semua";
            filterProducts();
          }
        } else {
          print("⚠️ Format respons tidak sesuai (tidak ada field 'data').");
        }
      } else {
        print("❌ Gagal mengambil data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> tambahProduk({
    required String name,
    required double price,
    required int stock,
    required File imageFile,
    required int product_category_id,
  }) async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      String fileName = basename(imageFile.path);
      FormData formData = FormData.fromMap({
        "name": name,
        "product_category_id": product_category_id,
        "price": price,
        "stock": stock,
        "image":
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await apiService.dio.post(
        '/api/products',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
        ),
      );
      print('Response Status: ${response.statusCode}');
      print(response.data);
      return response.statusCode == 201;
    } catch (e) {
      if (e is DioError) {
        print("Dio Error: ${e.response?.data ?? e.message}");
      } else {
        print("General Error: $e");
      }
      return false;
    }
  }

  void filterProducts({String query = ""}) {
    if (selectedCategory.value == "Semua" && query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(
        products.where((p) {
          final matchCategory = selectedCategory.value == "Semua" ||
              p.categoryName == selectedCategory.value;
          final matchName = query.isEmpty ||
              p.name.toLowerCase().contains(query.toLowerCase());
          return matchCategory && matchName;
        }).toList(),
      );
    }
  }

  /// 🔍 Cari produk berdasarkan nama atau kategori
  void searchProducts(String query) {
    if (query.isEmpty) {
      filterProducts();
    } else {
      filteredProducts.assignAll(products.where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          (product.categoryName ?? '')
              .toLowerCase()
              .contains(query.toLowerCase())));
    }
  }

  // Best Seller Products
  Future<void> fetchBestSellers() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get(
        '/api/products/best-sellers',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> rawProducts = response.data['data'];
        final loadedProducts =
            rawProducts.map<Product>((item) => Product.fromJson(item)).toList();

        bestSellerProducts.assignAll(loadedProducts);
      } else {
        print("Tidak ada data best seller");
        bestSellerProducts.clear();
      }
    } catch (e) {
      print("Error fetch best sellers: $e");
      bestSellerProducts.clear();
    } finally {
      isLoading(false);
    }
  }

  // penjualan bulan lalu
  Future<void> fetchsellersLastWeekProducts() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get(
        '/api/products/sellers-lastweek',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> raw = response.data['data'] as List<dynamic>;
        final loaded = raw.map((e) {
          return Product.fromJson(Map<String, dynamic>.from(e as Map));
        }).toList();
        sellersLastWeekProducts.assignAll(loaded);
      } else {
        sellersLastWeekProducts.clear();
      }
    } catch (e, st) {
      print("fetchBestSellers error: $e\n$st");
      sellersLastWeekProducts.clear();
    } finally {
      isLoading(false);
    }
  }

  // Hapus produk dari API & update lokal
  Future<void> deleteProduct(int id) async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.delete(
        '/api/products/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print("DELETE Status: ${response.statusCode}");
      print("DELETE Body: ${response.data}");

      if (response.statusCode == 200) {
        products.removeWhere((product) => product.id == id);
        filterProducts(); // 🟢 Ini penting untuk sinkron filteredProducts
        print("✅ Produk berhasil dihapus dari memori");
      } else {
        print("❌ Gagal menghapus produk. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error deleting product: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 🆕 Perbarui produk dalam memori
  void updateProduct(Product updatedProduct) {
    int index = products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      products[index] = updatedProduct;
      filterProducts();
      print("Produk berhasil diperbarui di memori");
    } else {
      print("Produk dengan ID ${updatedProduct.id} tidak ditemukan");
    }
  }

  /// 🔄 Refresh manual
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
}
