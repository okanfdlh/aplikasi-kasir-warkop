// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart'; // 👉 Tambahkan ini
// import '../models/product_model.dart';
// import '../services/api_service.dart';


// class EditMenuPage extends StatefulWidget {
//   final Product product;

//   EditMenuPage({required this.product});

//   @override
//   _EditMenuPageState createState() => _EditMenuPageState();
// }

// class _EditMenuPageState extends State<EditMenuPage> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService apiService = ApiService();

//   late TextEditingController nameController;
//   late TextEditingController categoryController;
//   late TextEditingController priceController;
//   late TextEditingController imageController;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.product.name);
//     categoryController = TextEditingController(text: widget.product.category);
//     priceController = TextEditingController(text: widget.product.price.toString());
//     imageController = TextEditingController(text: widget.product.image);
//   }

//   void updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final response = await apiService.dio.put(
//           '/products/${widget.product.id}',
//           data: {
//             "name": nameController.text,
//             "category": categoryController.text,
//             "price": double.parse(priceController.text),
//             "image": imageController.text,
//           },
//           options: Options(
//             headers: {
//               "Authorization": "Bearer ${apiService.bearerToken}",
//               "Accept": "application/json",
//               "Content-Type": "application/json",
//             },
//           ),
//         );

//         if (response.statusCode == 200) {
//           Get.snackbar('Success', 'Produk berhasil diperbarui');
//           Get.back();
//         } else {
//           Get.snackbar('Error', 'Gagal memperbarui produk');
//         }
//       } catch (e) {
//         Get.snackbar('Error', 'Terjadi kesalahan: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Produk'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Nama Produk'),
//                 validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: categoryController,
//                 decoration: InputDecoration(labelText: 'Kategori'),
//                 validator: (value) => value!.isEmpty ? 'Kategori wajib diisi' : null,
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: priceController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Harga'),
//                 validator: (value) => value!.isEmpty ? 'Harga wajib diisi' : null,
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: imageController,
//                 decoration: InputDecoration(labelText: 'URL Gambar'),
//                 validator: (value) => value!.isEmpty ? 'URL gambar wajib diisi' : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: updateProduct,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 child: Text('Simpan Perubahan'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
