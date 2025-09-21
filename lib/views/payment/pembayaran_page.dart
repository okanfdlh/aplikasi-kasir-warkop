import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PembayaranPage extends StatefulWidget {
  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController mejaController = TextEditingController();
  final apiService = ApiService();

  double totalHarga = 0;
  List<Map<String, dynamic>> items = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    totalHarga = args['totalHarga'] ?? 0;
    items = List<Map<String, dynamic>>.from(args['items'] ?? []);
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  Future<void> submitCashOrder() async {
    final Map<String, dynamic> data = {
      "name": namaController.text,
      "customer_meja": mejaController.text, // ini string
      "phone": teleponController.text,
      "note": noteController.text,
      "items": items, // pastikan List<Map<String, dynamic>>
    };

    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.post(
        '/api/order/cash',
        data: data, // 👈 langsung kirim map, dio auto JSON encode
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json", // 👈 penting
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data; // dio return Map langsung

        if (responseData['order'] != null) {
          Get.snackbar("Sukses", "Pesanan berhasil disimpan!",
              backgroundColor: Colors.green[100], colorText: Colors.black);

          final result = await Get.toNamed('/transaksi');
          if (result == true && mounted) {
            setState(() {});
          }
        } else {
          // Kalau respon sukses tapi order null
          print("Respon tidak valid: ${response.data}");
          Get.snackbar("Gagal", "Respon tidak valid",
              backgroundColor: Colors.red[100], colorText: Colors.black);
        }
      } else {
        // Kalau status bukan 200 (misalnya 400 dari stok tidak cukup)
        final responseData = response.data;

        String errorMessage = "Pesanan gagal.";
        if (responseData is Map && responseData['errors'] != null) {
          // Gabungkan array errors jadi string
          errorMessage = (responseData['errors'] as List).join("\n");
        } else if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        print("Status: ${response.statusCode}");
        print("Response data: $responseData");

        Get.snackbar("Gagal", errorMessage,
            backgroundColor: Colors.red[100], colorText: Colors.black);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red[100], colorText: Colors.black);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    print("Data yang dikirim: ${jsonEncode(data)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        title: const Text(
          'Pembayaran',
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Total yang harus dibayar:",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        formatRupiah(totalHarga),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                      labelText: "Nama Customer", border: OutlineInputBorder()),
                  validator: (value) =>
                      value!.isEmpty ? "Nama tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: teleponController,
                  decoration: const InputDecoration(
                      labelText: "Nomor Telepon", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? "Telepon tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mejaController,
                  decoration: const InputDecoration(
                      labelText: "No Meja", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Meja tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                      labelText: "Catatan", border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 32), // pengganti Spacer
                MyButton(
                  text: "Bayar Cash",
                  isLoading: isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      submitCashOrder();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    mejaController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
