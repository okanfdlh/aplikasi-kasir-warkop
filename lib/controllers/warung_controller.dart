import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../models/warung_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarungController extends GetxController {
  final warungs = <Warung>[].obs;
  final isLoading = false.obs;

  final apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchWarungs();
  }

  Future<void> fetchWarungs() async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await apiService.dio.get(
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
        final List<Warung> fetchedWarungs =
            rawData.map((item) => Warung.fromJson(item)).toList();
        warungs.value = fetchedWarungs;
      }
    } catch (e) {
      print("Error fetch warungs: $e");
    } finally {
      isLoading(false);
    }
  }

  // Contoh tambah warung
  Future<bool> tambahWarung({
    required String namaWarung,
    required String alamat,
    required String nomorTelepon,
    required String gambarPath,
  }) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      FormData formData = FormData.fromMap({
        'nama_warung': namaWarung,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
        'gambar_warung': await MultipartFile.fromFile(
          gambarPath,
          filename: gambarPath.split('/').last,
        ),
      });

      final response = await apiService.dio.post(
        '/api/warungs',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 201) {
        // Reload list setelah tambah
        await fetchWarungs();
        return true;
      }
      return false;
    } catch (e) {
      print("Error tambah warung: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Di dalam class WarungController
  Future<bool> updateWarung({
    required int id,
    required String namaWarung,
    required String alamat,
    required String nomorTelepon,
    File? gambarFile, // optional, kalau tidak diganti
  }) async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      FormData formData;

      if (gambarFile != null) {
        formData = FormData.fromMap({
          '_method':
              'PUT', // untuk method override jika backend menggunakan POST
          'nama_warung': namaWarung,
          'alamat': alamat,
          'nomor_telepon': nomorTelepon,
          'gambar_warung': await MultipartFile.fromFile(
            gambarFile.path,
            filename: gambarFile.path.split('/').last,
          ),
        });

        await apiService.dio.post(
          '/api/warungs/$id',
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          }),
        );
      } else {
        // tanpa gambar
        formData = FormData.fromMap({
          '_method': 'PUT',
          'nama_warung': namaWarung,
          'alamat': alamat,
          'nomor_telepon': nomorTelepon,
        });

        await apiService.dio.post(
          '/api/warungs/$id',
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          }),
        );
      }

      await fetchWarungs(); // reload list warung
      return true;
    } catch (e) {
      print("Error update warung: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
