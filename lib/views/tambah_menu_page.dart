import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class TambahMenuPage extends StatefulWidget {
  final String bearerToken;
  const TambahMenuPage({Key? key, required this.bearerToken}) : super(key: key);

  @override
  _TambahMenuPageState createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  late final ApiService apiService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<String> categories = ['coffee', 'non_coffee', 'makanan', 'cemilan'];
  String? selectedCategory;
  bool isLoading = false;
  File? pickedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    apiService.setBearerToken(widget.bearerToken);
    selectedCategory = categories.first;
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
        pickedImage == null ||
        selectedCategory == null) {
      _showSnackbar("Semua kolom harus diisi!", Colors.red);
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
      _showSnackbar("Harga tidak valid!", Colors.red);
      setState(() {
        isLoading = false;
      });
      return;
    }

    bool success = await apiService.tambahProduk(
      name: nameController.text,
      price: priceDouble,
      category: selectedCategory!,
      imageFile: pickedImage!,
    );

    // Success or failure message
    if (success) {
      _showSnackbar("Produk berhasil ditambahkan!", Colors.green);
      _clearFields();
      Navigator.pop(context, true);  // Indicating success to parent page
    } else {
      _showSnackbar("Gagal menambahkan produk!", Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

  // Snackbar to show messages
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Clear fields after success
  void _clearFields() {
    nameController.clear();
    priceController.clear();
    pickedImage = null;
    selectedCategory = categories.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Menu"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, "Nama Produk", Icons.fastfood),
              _buildTextField(priceController, "Harga", Icons.attach_money, isNumber: true),
              _buildCategoryDropdown(),
              SizedBox(height: 12),
              Text("Gambar Produk", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              pickedImage != null
                  ? Image.file(pickedImage!, height: 150)
                  : Text("Belum ada gambar yang dipilih"),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.green),
                      SizedBox(height: 8),
                      Text(
                        "Pilih Gambar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      ),
    );
  }

  // Helper method for text fields
  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon,
      {bool isNumber = false}) {
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

  // Helper method for category dropdown
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
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
