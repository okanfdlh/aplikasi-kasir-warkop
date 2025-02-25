import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class TambahMenuPage extends StatefulWidget {
  @override
  _TambahMenuPageState createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  bool isLoading = false;

  Future<void> tambahProduk() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        categoryController.text.isEmpty ||
        imageController.text.isEmpty) {
      _showSnackbar("Semua kolom harus diisi!", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Konfigurasi koneksi MySQL
      final settings = ConnectionSettings(
        host: '192.168.1.10', // Gunakan IP lokal jika menggunakan emulator
        port: 3306, // Port default MySQL
        user: 'root', // Sesuaikan dengan Laragon
        password: '', // Jika MySQL tidak memiliki password
        db: 'rumahseduh', // Ganti dengan nama database kamu
      );

      final conn = await MySqlConnection.connect(settings);

      // Query untuk menambahkan produk
      await conn.query(
        'INSERT INTO products (name, price, category, image) VALUES (?, ?, ?, ?)',
        [nameController.text, priceController.text, categoryController.text, imageController.text],
      );

      await conn.close();

      _showSnackbar("Produk berhasil ditambahkan!", Colors.green);
      _clearFields();
    } catch (e) {
      _showSnackbar("Gagal menambahkan produk: $e", Colors.red);
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
    categoryController.clear();
    imageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Menu"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, "Nama Produk", Icons.fastfood),
            _buildTextField(priceController, "Harga", Icons.attach_money, isNumber: true),
            _buildTextField(categoryController, "Kategori", Icons.category),
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
}
