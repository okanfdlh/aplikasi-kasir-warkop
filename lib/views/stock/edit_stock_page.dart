import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/controllers/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditStockPage extends StatefulWidget {
  final Product product;

  final VoidCallback? onProductUpdated;
  const EditStockPage({required this.product, this.onProductUpdated});
  @override
  // ignore: library_private_types_in_public_api
  _EditStockPageState createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  String selectedAction = "increase"; // default
  late TextEditingController nameController;
  late TextEditingController stockControllerFilled;
  final TextEditingController stockController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    stockControllerFilled =
        TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    // jangan lupa dibersihin biar ga leak
    nameController.dispose();
    stockControllerFilled.dispose();
    stockController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => isLoading = true);

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        dio.Response response;

        response = await apiService.dio.put(
          '/api/stock/${widget.product.id}',
          data: {
            'action': selectedAction,
            'quantity': stockController.text.trim(),
            'reason': reasonController.text.trim(),
          },
          options: dio.Options(
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          ),
        );

        // Jangan panggil setState di sini, langsung navigasi
        if (response.statusCode == 200) {
          setState(() => isLoading = false);
          Get.snackbar('Sukses', 'Produk berhasil diperbarui',
              snackPosition: SnackPosition.TOP);
          if (widget.onProductUpdated != null) {
            widget.onProductUpdated!();
          }
          final StockController stockController = Get.put(StockController());
          stockController.fetchStock();
          Navigator.of(context).pop(true);
        } else {
          setState(() => isLoading = false);
          Get.snackbar('Gagal', 'Status: ${response.statusCode}',
              snackPosition: SnackPosition.TOP);
        }
      } catch (e) {
        setState(() => isLoading = false);

        if (e is dio.DioError && e.response != null) {
          print("Error Response Data: ${e.response!.data}");
          Get.snackbar('Error', '${e.response!.data}');
        } else {
          Get.snackbar('Error', e.toString());
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
          'Ubah Stok',
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
              // Card untuk Info Produk dan Stok
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Nama Produk
                    _buildInfoItem(
                      label: "Nama Produk",
                      value: nameController.text.isEmpty
                          ? "-"
                          : nameController.text,
                    ),

                    const SizedBox(height: 12),

                    // Info Stok Saat Ini
                    _buildInfoItem(
                      label: "Stok Saat Ini",
                      value: stockControllerFilled.text.isEmpty
                          ? "0"
                          : "${stockControllerFilled.text} pcs",
                    ),
                  ],
                ),
              ),
              _buildActionDropdown("Aksi"),
              SizedBox(height: 10),
              _buildTextField(
                  stockController, "Stok", "ex. 10", Icons.conveyor_belt,
                  isNumber: true),
              SizedBox(height: 10),
              _buildTextField(
                  reasonController, "Alasan", "ex. Restok barang", Icons.note),
              const SizedBox(height: 10),
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

  // Helper method untuk membuat info item
  Widget _buildInfoItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    String placeholder,
    IconData icon, {
    bool isNumber = false,
    bool isReadOnly = false, // default false
  }) {
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
          TextField(
            controller: controller,
            readOnly: isReadOnly, // biar ga bisa diedit
            enabled: !isReadOnly, // juga bisa matiin fokus
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
                  color: Colors.grey,
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
  Widget _buildActionDropdown(String labelText) {
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
          DropdownButtonFormField<String>(
            value:
                selectedAction, // ini variable String di state: "increase" / "decrease"
            items: const [
              DropdownMenuItem(
                value: "increase",
                child: Text("Tambah Stok"),
              ),
              DropdownMenuItem(
                value: "decrease",
                child: Text("Kurangi Stok"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedAction = value!;
              });
            },
            dropdownColor: const Color(0xffE8F4E8),
            decoration: InputDecoration(
              hintText: "Pilih Aksi",
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
