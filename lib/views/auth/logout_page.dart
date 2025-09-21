import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Konfirmasi Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah kamu yakin ingin logout?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Tutup dialog
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Get.back(); // Tutup dialog
              logout;
            },
            child: const Text("Logout"),
          ),
        ],
      ),
      barrierDismissible: false, // supaya ga bisa klik di luar
    );
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus semua data terkait auth
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('is_logged_in');
    // Tambahkan key lain yang perlu dihapus sesuai aplikasi Anda

    // Atau hapus semua data (optional)
    // await prefs.clear();
  }

  Future<bool> logout(ApiService apiService) async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await apiService.dio.get(
        '/api/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Logout berhasil, clear data lokal
        await _clearLocalData();
        return true;
      } else {
        // Jika error 401 (Unauthorized), token sudah invalid
        // Tetap clear data lokal
        if (response.statusCode == 401) {
          await _clearLocalData();
          return true;
        }

        // Handle error lainnya
        final errorData = response.data;
        throw Exception(errorData['message'] ?? 'Logout gagal');
      }
    } catch (e) {
      print('Error during logout: $e');
      // Jika terjadi error jaringan, tetap clear data lokal
      // untuk memastikan user tidak stuck
      await _clearLocalData();
      throw Exception('Terjadi kesalahan saat logout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: const Color(0xff024924),
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            "Logout",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
