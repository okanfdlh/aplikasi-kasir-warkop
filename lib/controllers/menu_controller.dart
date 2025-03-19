import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';

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

  void fetchProducts() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse("https://seduh.dev-web2.babelprov.go.id/api/products"));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Pastikan data berbentuk List
        if (data is List) {
          products.value = data.map<Product>((item) => Product.fromJson(item)).toList();
          print("Data berhasil dimuat: ${products.length} item.");

          // Ambil kategori unik dari produk
          categories.value = ["Semua"] + products.map((p) => p.category).toSet().toList();

          // Default tampilkan semua produk
          selectedCategory.value = "Semua";
          filterProducts();
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

  void filterProducts() {
    if (selectedCategory.value == "Semua") {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(
        products.where((p) => p.category == selectedCategory.value).toList(),
      );
    }
  }

  // ✅ Fungsi searchProducts
  void searchProducts(String query) {
    if (query.isEmpty) {
      filterProducts(); // tampilkan berdasarkan kategori jika search kosong
    } else {
      filteredProducts.assignAll(
        products.where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase())
        ).toList(),
      );
    }
  }

  // ✅ Fungsi deleteProduct
  void deleteProduct(int id) async {
    try {
      isLoading(true);
      var response = await http.delete(
        Uri.parse("https://seduh.dev-web2.babelprov.go.id/api/products/$id"),
      );

      if (response.statusCode == 200) {
        products.removeWhere((product) => product.id == id);
        filteredProducts.removeWhere((product) => product.id == id);
        print("Produk berhasil dihapus");
      } else {
        print("Gagal menghapus produk. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting product: $e");
    } finally {
      isLoading(false);
    }
  }
}
