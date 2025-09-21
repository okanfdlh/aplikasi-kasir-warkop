import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/controllers/category_controller.dart';
import 'package:coffeeorder/controllers/menu_controller.dart'
    as MyMenuController;
import 'package:coffeeorder/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditMenuPage extends StatefulWidget {
  final Product product;

  final VoidCallback? onProductUpdated;
  const EditMenuPage({required this.product, this.onProductUpdated});
  @override
  // ignore: library_private_types_in_public_api
  _EditMenuPageState createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final CategoryController categoryController = Get.put(CategoryController());
  final ApiService apiService = ApiService();
  bool isLoading = false;

  Category? selectedCategory;

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    stockController =
        TextEditingController(text: widget.product.stock.toString());

    // Cari Category dari controller.categories yang sesuai ID
    selectedCategory = categoryController.categories
        .firstWhereOrNull((c) => c.id == widget.product.productCategoryId);
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected');
    }
  }

  // Ganti method updateProduct() di EditMenuPage dengan ini:

  Future<void> updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => isLoading = true);

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        dio.Response response;

        if (_selectedImage != null) {
          final formData = dio.FormData.fromMap({
            '_method': 'PUT',
            'name': nameController.text.trim(),
            'product_category_id': selectedCategory!.id,
            'price': priceController.text.trim(),
            'stock': stockController.text.trim(),
            'image': await dio.MultipartFile.fromFile(
              _selectedImage!.path,
              filename: _selectedImage!.path.split('/').last,
            ),
          });

          response = await apiService.dio.post(
            '/api/products/${widget.product.id}',
            data: formData,
            options: dio.Options(
              headers: {
                "Authorization": "Bearer $token",
                "Accept": "application/json",
              },
            ),
          );
        } else {
          response = await apiService.dio.put(
            '/api/products/${widget.product.id}',
            data: {
              'name': nameController.text.trim(),
              'product_category_id': selectedCategory!.id,
              'price': priceController.text.trim(),
              'stock': stockController.text.trim(),
            },
            options: dio.Options(
              headers: {
                "Authorization": "Bearer $token",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
            ),
          );
        }

        // Jangan panggil setState di sini, langsung navigasi
        if (response.statusCode == 200) {
          setState(() => isLoading = false);
          Get.rawSnackbar(
            message: "Menu berhasil diperbarui.",
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
          if (widget.onProductUpdated != null) {
            widget.onProductUpdated!();
          }
          final MyMenuController.MenuController menuController =
              Get.find<MyMenuController.MenuController>();
          menuController.fetchProducts();
          Navigator.of(context).pop(true);
        } else {
          setState(() => isLoading = false);
          Get.snackbar(
            'Gagal',
            'Status: ${response.statusCode}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            icon: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);

        if (e is dio.DioError && e.response != null) {
          print("Error Response Data: ${e.response!.data}");
          Get.snackbar(
            'Error',
            '${e.response!.data}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            icon: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
          );
        } else {
          Get.snackbar(
            'Error',
            e.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            icon: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Ubah Menu',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff024924),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // warna panah kembali
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, "Nama Produk", "ex. Americano",
                  Icons.fastfood),
              _buildTextField(
                  priceController, "Harga (Rp)", "ex. 12000", Icons.sell,
                  isNumber: true),
              _buildTextField(
                  stockController, "Stok", "ex. 10", Icons.conveyor_belt,
                  isNumber: true),
              SizedBox(height: 10),
              _buildCategoryDropdown("Kategori Produk"),
              SizedBox(height: 10),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150) // gambar baru dipilih
              else if (widget.product.image.isNotEmpty)
                Image.network(
                  "${ApiService.baseUrl}/storage/${widget.product.image}",
                  height: 150,
                  fit: BoxFit.cover,
                ) // gambar dari database
              else
                const Text("Belum ada gambar yang dipilih"),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 198, 202, 200),
                    border: Border.all(
                        color: const Color.fromARGB(255, 96, 109, 102)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo,
                          size: 40,
                          color: const Color.fromARGB(255, 96, 109, 102)),
                      SizedBox(height: 8),
                      Text(
                        "Ketuk untuk memilih gambar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 96, 109, 102),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              MyButton(
                text: "Simpan Perubahan",
                isLoading: isLoading,
                onPressed: updateProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, // Label di atas field
    String placeholder, // Placeholder/hint di dalam field
    IconData icon, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label di atas field
          Text(
            labelText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff024924),
            ),
          ),
          const SizedBox(height: 6), // jarak antara label dan field
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color.fromARGB(255, 198, 202, 200),
              ),
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.grey, // Warna border normal
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff024924),
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method for category dropdown
  Widget _buildCategoryDropdown(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff024924),
            ),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final categories = categoryController.categories;

            if (categories.isEmpty) {
              return const CircularProgressIndicator();
            }

            // Set selectedCategory jika belum di-set
            selectedCategory ??= categories.firstWhere(
              (c) => c.id == widget.product.productCategoryId,
              orElse: () => categories.first,
            );

            return DropdownButtonFormField<Category>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              dropdownColor: const Color(0xffE8F4E8),
              decoration: InputDecoration(
                hintText: "Pilih Kategori",
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
