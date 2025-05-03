import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuController extends GetxController {
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var categories = <String>[].obs;
  var selectedCategory = "Semua".obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  // 🔄 Ambil semua produk dari API
  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse("https://seduh.dev-web2.babelprov.go.id/api/products"));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          final loadedProducts = data.map<Product>((item) => Product.fromJson(item)).toList();
          if (!isClosed) {
            products.value = loadedProducts;
            categories.value = ["Semua"] + products.map((p) => p.category).toSet().toList();
            selectedCategory.value = "Semua";
            filterProducts();
            print("Data berhasil dimuat: ${products.length} item.");
          }
        } else {
          print("Data yang diterima bukan List");
        }
      } else {
        print("Gagal mengambil data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🔁 Filter produk berdasarkan kategori
  void filterProducts() {
    if (selectedCategory.value == "Semua") {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(
        products.where((p) => p.category == selectedCategory.value).toList(),
      );
    }
  }

  // 🔍 Cari produk berdasarkan nama atau kategori
  void searchProducts(String query) {
    if (query.isEmpty) {
      filterProducts();
    } else {
      filteredProducts.assignAll(
        products.where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  // ❌ Hapus produk berdasarkan ID
  Future<void> deleteProduct(int id) async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("Token tidak ditemukan. User mungkin belum login.");
        return;
      }

      final response = await http.delete(
        Uri.parse("https://seduh.dev-web2.babelprov.go.id/api/products/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        products.removeWhere((product) => product.id == id);
        filteredProducts.removeWhere((product) => product.id == id);
        print("Produk berhasil dihapus");
      } else {
        print("Gagal menghapus produk. Status Code: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("Error deleting product: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🆕 Perbarui produk dalam daftar
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

  // 🔄 Refresh manual
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
}
