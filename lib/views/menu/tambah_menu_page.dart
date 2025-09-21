import 'dart:io';
import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/controllers/category_controller.dart';
import 'package:coffeeorder/models/category_model.dart';
import 'package:coffeeorder/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/menu_controller.dart' as MyMenuController;

class TambahMenuPage extends StatefulWidget {
  final String bearerToken;
  const TambahMenuPage({super.key, required this.bearerToken});

  @override
  // ignore: library_private_types_in_public_api
  _TambahMenuPageState createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final MyMenuController.MenuController menuController = Get.put(
    MyMenuController.MenuController(),
  );
  final CategoryController categoryController = Get.put(CategoryController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  Category? selectedCategory;

  bool isLoading = false;
  File? pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  // Picking image from gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  // Adding new product
  Future<void> tambahProduk() async {
    // Basic validation
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty ||
        pickedImage == null ||
        selectedCategory == null) {
      Get.snackbar(
        "Gagal menambahkan produk!", // title
        "Semua kolom harus diisi", // message
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
      return;
    }

    setState(() {
      isLoading = true;
    });

    double priceDouble = double.tryParse(
            priceController.text.replaceAll('.', '').replaceAll(',', '.')) ??
        0.0;

    // Price validation to avoid zero or invalid price
    if (priceDouble <= 0.0) {
      Get.snackbar(
        "Gagal menambahkan produk!", // title
        "Harga tidak valid.", // message
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    int stockInt = int.parse(stockController.text);

    bool success = await menuController.tambahProduk(
      name: nameController.text,
      price: priceDouble,
      stock: stockInt,
      product_category_id: selectedCategory!.id,
      imageFile: pickedImage!,
    );
    print("Bearer Token: ${widget.bearerToken}");

    if (success) {
      Get.rawSnackbar(
        message: "Menu berhasil ditambahkan.",
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
      // ignore: use_build_context_synchronously
      DashboardPageState.of(context)?.goToMenu();
    } else {
      Get.snackbar(
        "Gagal menambahkan produk!", // title
        "Terjadi kesalahan saat menyimpan.", // message
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

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Tambah Menu',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff024924),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(nameController, "Nama Produk", "ex. Americano",
                  Icons.fastfood),
              _buildTextField(
                  priceController, "Harga (Rp)", "ex. 12000", Icons.sell,
                  isNumber: true),
              _buildTextField(
                  stockController, "Stok", "ex. 10", Icons.conveyor_belt,
                  isNumber: true),
              _buildCategoryDropdown("Kategori Produk"),
              const SizedBox(height: 10),
              pickedImage != null
                  ? Image.file(pickedImage!, height: 150, fit: BoxFit.cover)
                  : const Text("Belum ada gambar yang dipilih"),
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
              const SizedBox(height: 20),
              MyButton(
                text: "Tambah Produk",
                isLoading: isLoading,
                onPressed: tambahProduk, // fungsi tetap sama
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for text fields
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
