import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TambahMenuPage extends StatefulWidget {
  @override
  _TambahMenuPageState createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final ApiService apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> categories = ['coffe', 'nCoffe', 'makanan', 'cemilan'];
  String? selectedCategory;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = categories.first; // Set default kategori pertama
    _fetchCsrfToken();
  }

  Future<void> _fetchCsrfToken() async {
    await apiService.getCsrfToken();
  }

  Future<void> tambahProduk() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = await apiService.tambahProduk(
      name: nameController.text,
      image: imageController.text,
      price: double.parse(priceController.text),
      category: selectedCategory!,
    );

    if (success) {
      _showSnackbar("Produk berhasil ditambahkan!", Colors.green);
      _clearFields();
    } else {
      _showSnackbar("Gagal menambahkan produk!", Colors.red);
    }

    setState(() {
      isLoading = false;
    });
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
    selectedCategory = categories.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Menu"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, "Nama Produk", Icons.fastfood),
              _buildTextField(priceController, "Harga", Icons.attach_money, isNumber: true),
              _buildCategoryDropdown(),
              _buildTextField(imageController, "URL Gambar", Icons.image),
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

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Kolom ini harus diisi";
          }
          if (isNumber) {
            if (double.tryParse(value) == null) {
              return "Masukkan angka yang valid";
            }
          }
          return null;
        },
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
