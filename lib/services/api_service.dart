import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://rumahseduh.shbhosting999.my.id/';
  // static const String baseUrl = 'http://192.168.1.80:8000';
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
}
