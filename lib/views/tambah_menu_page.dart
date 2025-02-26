import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahMenuPage extends StatefulWidget {
  @override
  _TambahMenuPageState createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  List<String> categories = [];
  String? selectedCategory;
  bool isLoading = false;
  bool isCategoryLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.10:8000/api/products'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Mengambil hanya kategori unik
        List<String> fetchedCategories = data
            .map<String>((item) => item['category'].toString())
            .toSet() // Menghilangkan duplikasi
            .toList();

        setState(() {
          categories = fetchedCategories;
          selectedCategory = categories.isNotEmpty ? categories.first : null;
          isCategoryLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil kategori');
      }
    } catch (e) {
      print("Error mengambil kategori: $e");
      setState(() {
        isCategoryLoading = false;
      });
    }
  }

  Future<void> tambahProduk() async {
  if (nameController.text.isEmpty ||
      priceController.text.isEmpty ||
      selectedCategory == null ||
      imageController.text.isEmpty) {
    _showSnackbar("Semua kolom harus diisi!", Colors.red);
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.10:8000/api/products'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "price": priceController.text,
        "category": selectedCategory,
        "image": imageController.text,
      }),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201) {
      _showSnackbar("Produk berhasil ditambahkan!", Colors.green);
      _clearFields();
    } else {
      _showSnackbar("Gagal menambahkan produk: ${response.body}", Colors.red);
    }
  } catch (e) {
    _showSnackbar("Error: $e", Colors.red);
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _clearFields() {
    nameController.clear();
    priceController.clear();
    imageController.clear();
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Menu"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(nameController, "Nama Produk (Contoh: Kopi Susu)", Icons.fastfood),
            _buildTextField(priceController, "Harga (Contoh: 15000)", Icons.attach_money, isNumber: true),
            _buildCategoryDropdown(),
            _buildTextField(imageController, "URL Gambar (Contoh: https://example.com/kopi.jpg)", Icons.image),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : tambahProduk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Tambah Produk", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isCategoryLoading
          ? Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Text("Kategori tidak tersedia", style: TextStyle(color: Colors.red))
              : DropdownButtonFormField<String>(
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
                    prefixIcon: Icon(Icons.category, color: Colors.green),
                    hintText: "Pilih Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
    );
  }
}
