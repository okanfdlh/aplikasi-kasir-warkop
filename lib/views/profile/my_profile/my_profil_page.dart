import 'dart:io';
import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/controllers/warung_controller.dart';
import 'package:coffeeorder/models/warung_model.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditWarungPage extends StatefulWidget {
  const EditWarungPage({super.key});

  @override
  State<EditWarungPage> createState() => _EditWarungPageState();
}

class _EditWarungPageState extends State<EditWarungPage> {
  Warung? warung;
  final WarungController warungController = Get.put(WarungController());

  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController teleponController;

  File? pickedImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Get.put(WarungController());
    namaController = TextEditingController();
    alamatController = TextEditingController();
    teleponController = TextEditingController();
    fetchMyWarung();
  }

  Future<void> fetchMyWarung() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await ApiService().dio.get(
            '/api/warungs',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['data'];
        if (rawData.isNotEmpty) {
          setState(() {
            warung = Warung.fromJson(rawData.first);
            namaController.text = warung!.namaWarung;
            alamatController.text = warung!.alamat;
            teleponController.text = warung!.nomorTelepon;
          });
        }
      }
    } catch (e) {
      print("Error fetch warung: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => pickedImage = File(pickedFile.path));
    }
  }

  Future<void> updateWarung() async {
    if (namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        teleponController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Semua kolom harus diisi',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await warungController.updateWarung(
      id: warung!.id,
      namaWarung: namaController.text,
      alamat: alamatController.text,
      nomorTelepon: teleponController.text,
      gambarFile: pickedImage,
    );

    setState(() => isLoading = false);

    if (success) {
      Get.snackbar('Sukses', 'Warung berhasil diperbarui',
          snackPosition: SnackPosition.TOP);
      Navigator.of(context).pop(true);
    } else {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat menyimpan',
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Warung',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna panah kembali
        ),
        backgroundColor: const Color(0xff024924),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : warung == null
              ? const Center(child: Text('Data warung tidak ditemukan'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildTextField(namaController, 'Nama Warung'),
                      _buildTextField(alamatController, 'Alamat'),
                      _buildTextField(teleponController, 'Nomor Telepon',
                          isNumber: true),
                      const SizedBox(height: 10),
                      pickedImage != null
                          ? Image.file(pickedImage!,
                              height: 150, fit: BoxFit.cover)
                          : warung!.gambarWarung != null
                              ? Image.network(
                                  '${ApiService.baseUrl}/storage/${warung!.gambarWarung}',
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : const Text('Belum ada gambar'),
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 198, 202, 200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              SizedBox(height: 8),
                              Text('Ketuk untuk memilih gambar'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        text: 'Simpan Perubahan',
                        isLoading: isLoading,
                        onPressed: updateWarung,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
