import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.12:8000',
    followRedirects: true,
    validateStatus: (status) => true,
  ));

  String? xsrfToken;

  // Ambil CSRF Token
  Future<void> getCsrfToken() async {
    try {
      Response response = await dio.get('/sanctum/csrf-cookie');

      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        for (var cookie in cookies) {
          if (cookie.contains('XSRF-TOKEN')) {
            xsrfToken = cookie.split(';')[0].split('=')[1];
            dio.options.headers['X-XSRF-TOKEN'] = xsrfToken;
            dio.options.headers['Cookie'] = cookies.join("; ");
            print("CSRF Token Retrieved: $xsrfToken");
          }
        }
      } else {
        print("CSRF Token not found in cookies");
      }
    } catch (e) {
      print("Error getting CSRF token: $e");
    }
  }

  // Tambah Produk
  Future<bool> tambahProduk({
    required String name,
    required String image,
    required double price,
    required String category,
  }) async {
    try {
      Response response = await dio.post(
        '/api/menu/tambah',
        options: Options(
          headers: {
            'X-XSRF-TOKEN': xsrfToken, // Kirim token CSRF
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Cookie': dio.options.headers['Cookie'], // Kirim cookies session Laravel
          },
        ),
        data: {
          "name": name,
          "image": image,
          "price": price,
          "category": category,
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      return response.statusCode == 201;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
