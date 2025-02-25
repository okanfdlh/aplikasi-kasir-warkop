import 'package:flutter/material.dart';
import 'package:coba1/views/menu_page.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.green, // Warna utama aplikasi
        fontFamily: 'Roboto', // Font modern
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kasir Rumah Seduh",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),

            _buildMenuButton(
              icon: Icons.menu_book,
              label: "Daftar Menu",
              context: context,
              page: MenuPage(),
            ),

            _buildMenuButton(
              icon: Icons.receipt_long,
              label: "Transaksi",
              context: context,
              page: TransaksiPage(),
            ),

            _buildMenuButton(
              icon: Icons.add_box,
              label: "Tambah Menu",
              context: context,
              page: TambahMenuPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required BuildContext context, required Widget page}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade800,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
      ),
    );
  }
}
