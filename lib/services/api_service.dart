import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://rumahseduh.shbhosting999.my.id/api',
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
    required File imageFile,
  }) async {
    try {
      String fileName = basename(imageFile.path);
      FormData formData = FormData.fromMap({
        "name": name,
        "category": category,
        "price": price,
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await dio.post(
        '/products',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $bearerToken",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
        ),
      );
      print('Response Status: ${response.statusCode}');
      print(response.data);
      return response.statusCode == 201;
    } catch (e) {
  if (e is DioError) {
    print("Dio Error: ${e.response?.data ?? e.message}");
  } else {
    print("General Error: $e");
  }
  return false;
}
  }
}

