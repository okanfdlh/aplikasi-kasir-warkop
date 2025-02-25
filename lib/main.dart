import 'package:flutter/material.dart';
import 'package:coba1/views/menu_page.dart';  // Sesuaikan dengan struktur folder
import 'package:coba1/views/transaksi_page.dart';
import 'package:coba1/views/tambah_menu_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kasir")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()));
              },
              child: Text("Daftar Menu"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TransaksiPage()));
              },
              child: Text("Transaksi"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TambahMenuPage()));
              },
              child: Text("Tambah Menu"),
            ),
          ],
        ),
      ),
    );
  }
}
