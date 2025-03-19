import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://seduh.dev-web2.babelprov.go.id/api',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));

  String? bearerToken;

  void setBearerToken(String token) {
    bearerToken = token;
    dio.options.headers["Authorization"] = "Bearer $token";
  }

    Future<bool> tambahProduk({
    required String name,
    required String category,
    required double price,
    required String image,
  }) async {
    try {
      // ✅ Cetak URL dan token untuk debugging
      print('URL: ${dio.options.baseUrl}/products');
      print('Token: $bearerToken');
      
      final response = await dio.post(
        '/products',
        data: {
          "name": name,
          "category": category,
          "price": price,
          "image": image,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $bearerToken",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );
      print(response.data);
      return response.statusCode == 201;
    } catch (e) {
      print("Tambah Produk Error: $e");
      return false;
    }
  }
}
