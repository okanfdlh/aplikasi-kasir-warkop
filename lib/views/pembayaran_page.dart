import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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

  double totalHarga = 0;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    totalHarga = args['totalHarga'] ?? 0;
    items = List<Map<String, dynamic>>.from(args['items'] ?? []);
  }

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  Future<void> submitCashOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token'); // pastikan key-nya sesuai saat login

  final url = Uri.parse("http://10.0.0.2:8000/api/order/cash");

  final Map<String, dynamic> body = {
    "name": namaController.text,
    "no_meja": mejaController.text,
    "phone": teleponController.text,
    "note": noteController.text,
    "items": items,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      Get.snackbar("Sukses", "Pesanan berhasil disimpan!",
          backgroundColor: Colors.green[100], colorText: Colors.black);
      Get.offAllNamed('/order/struk', arguments: json.decode(response.body));
    } else {
      print(response.body);
      Get.snackbar("Gagal", "Pesanan gagal disimpan!",
          backgroundColor: Colors.red[100], colorText: Colors.black);
    }
  } catch (e) {
    Get.snackbar("Error", e.toString(),
        backgroundColor: Colors.red[100], colorText: Colors.black);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Pembayaran"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Total yang harus dibayar:", style: TextStyle(fontSize: 16)),
              Text(formatRupiah(totalHarga),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800])),
              SizedBox(height: 24),

              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Customer", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: teleponController,
                decoration: InputDecoration(labelText: "Nomor Telepon", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Telepon tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: mejaController,
                decoration: InputDecoration(labelText: "No Meja", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Meja tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: noteController,
                decoration: InputDecoration(labelText: "Catatan", border: OutlineInputBorder()),
                maxLines: 2,
              ),
              Spacer(),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitCashOrder();
                  }
                },
                child: Text("Bayar Cash"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green[700],
                ),
              ),
            ],
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
