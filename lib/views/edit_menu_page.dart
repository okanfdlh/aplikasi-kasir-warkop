import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EditMenuPage extends StatefulWidget {
  final Product product;

  EditMenuPage({required this.product});

  @override
  _EditMenuPageState createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late TextEditingController nameController;
  late TextEditingController priceController;
  File? _selectedImage;

  List<String> categories = ['coffee', 'non_coffee', 'makanan', 'cemilan'];
  late String selectedCategory;

  @override
  @override
void initState() {
  super.initState();
  nameController = TextEditingController(text: widget.product.name);
  priceController = TextEditingController(text: widget.product.price.toString());
  selectedCategory = widget.product.category;

  loadToken(); // ambil token saat init
}

Future<void> loadToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null && token.isNotEmpty) {
    setState(() {
      apiService.bearerToken = token;
    });
  } else {
    Get.snackbar('Error', 'Token tidak ditemukan, silakan login ulang.');
    Get.offAllNamed('/login'); // ganti dengan rute login kamu
  }
}

  Future<void> pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  } else {
    print('No image selected');
  }
}


  Future<void> updateProduct() async {
  if (_formKey.currentState!.validate()) {
    try {
      dio.Response response;

      if (_selectedImage != null) {
        final formData = dio.FormData.fromMap({
          '_method': 'PUT',
          'name': nameController.text.trim(),
          'category': selectedCategory,
          'price': priceController.text.trim(),
          'image': await dio.MultipartFile.fromFile(
            _selectedImage!.path,
            filename: _selectedImage!.path.split('/').last,
          ),
        });

        response = await apiService.dio.post(
          'https://rumahseduh.shbhosting999.my.id/api/products/${widget.product.id}?_method=PUT',
          data: formData,
          options: dio.Options(
            headers: {
              "Authorization": "Bearer ${apiService.bearerToken}",
              "Accept": "application/json",
            },
          ),
        );
      } else {
        response = await apiService.dio.put(
          'https://rumahseduh.shbhosting999.my.id/api/products/${widget.product.id}',
          data: {
            'name': nameController.text.trim(),
            'category': selectedCategory,
            'price': priceController.text.trim(),
          },
          options: dio.Options(
            headers: {
              "Authorization": "Bearer ${apiService.bearerToken}",
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          ),
        );
      }

      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        Get.snackbar('Sukses', 'Produk berhasil diperbarui', snackPosition: SnackPosition.BOTTOM);
        
        // Delay before navigating back to MenuPage
        Future.delayed(Duration(seconds: 2), () {
          // Navigate back to MenuPage and reload the page
          Get.offAllNamed('/menu_page'); // Assuming '/menu_page' is the route name for MenuPage
        });
      } else {
        Get.snackbar('Gagal', 'Status: ${response.statusCode}', snackPosition: SnackPosition.BOTTOM);
      }

    } catch (e) {
      if (e is dio.DioError && e.response != null) {
        print("Error Response Data: ${e.response!.data}");
        Get.snackbar('Error', '${e.response!.data}');
      } else {
        Get.snackbar('Error', e.toString());
      }
    }
  }
  print("Form Data:");
  print("name: ${nameController.text.trim()}");
  print("category: $selectedCategory");
  print("price: ${priceController.text}");
  print("image: ${_selectedImage?.path}");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Produk'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Kategori wajib dipilih' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : widget.product.image.isNotEmpty
                      ? Image.network('https://rumahseduh.shbhosting999.my.id/storage/${widget.product.image}', height: 150)
                      : Container(height: 150, color: Colors.grey[300]),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Pilih Gambar Baru'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProduct,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
