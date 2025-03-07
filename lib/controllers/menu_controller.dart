import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';

class MenuController extends GetxController {
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var categories = <String>[].obs;
  var selectedCategory = "".obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  void fetchProducts() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse("http://192.168.1.10:8000//api/products"));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        products.value = data.map<Product>((item) => Product.fromJson(item)).toList();
        
        // Ambil kategori unik dari produk
        categories.value = ["Semua"] + products.map((p) => p.category).toSet().toList();

        // Default: tampilkan semua produk
        selectedCategory.value = "Semua";
        filterProducts();
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
      filteredProducts.assignAll(products.where((p) => p.category == selectedCategory.value).toList());
    }
  }
}

  var products = <Product>[].obs;
  var isLoading = true.obs;




  void fetchProducts() async {
  try {
    isLoading(true);
    var response = await http.get(Uri.parse("http://192.168.1.10:8000//api/products"));
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      products.value = data.map<Product>((item) => Product.fromJson(item)).toList();
      print("Data berhasil dimuat: ${products.length} item.");
    } else {
      print("Gagal mengambil data. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching products: $e");
  } finally {
    isLoading(false);
  }
}

