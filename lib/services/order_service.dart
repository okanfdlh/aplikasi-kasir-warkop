import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pendapatan_model.dart';

class OrderService {
  static const baseUrl = 'rumahseduh.shbhosting999.my.id/';

  static Future<List<dynamic>> fetchOrders() async {
    final response = await http.get(Uri.parse('https://$baseUrl/api/orders'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data order');
    }
  }

  static Future<List<PendapatanModel>> fetchPendapatan({
    String type = 'day',
    int? year,
    int? month,
    int? day,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final query = {
      'type': type,
      'year': year?.toString() ?? DateTime.now().year.toString(),
      if (month != null) 'month': month.toString(),
      if (day != null) 'day': day.toString(),
    };
    final uri = Uri.http(baseUrl, '/api/pendapatan', query);
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    print('📥 Pendapatan URI: $uri');
    print('📤 Status: ${res.statusCode}');
print('📤 Body: ${res.body}');

    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.map((item) => PendapatanModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data pendapatan');
    }
  }

  static Future<List<ProdukTerlarisModel>> fetchProdukTerlaris({
    int? year,
    int? month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final query = {
      if (year != null) 'year': year.toString(),
      if (month != null) 'month': month.toString(),
    };
    final uri = Uri.http(baseUrl, '/api/produk-terlaris', query);
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    print('📥 Produk URI: $uri');
    print('📤 Status: ${res.statusCode}');
    print('📤 Body: ${res.body}');

    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.map((item) => ProdukTerlarisModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil produk terlaris');
    }
  }
}
