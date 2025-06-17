import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<List<dynamic>> fetchOrders() async {
    final response = await http.get(Uri.parse('https://seduh.dev-web2.babelprov.go.id/api/orders'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data order');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPendapatan() async {
    final response = await http.get(Uri.parse('https://seduh.dev-web2.babelprov.go.id/api/orders'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
        "tanggal": item['tanggal'],
        "jumlah": int.parse(item['jumlah'].toString()),
      }).toList();
    } else {
      throw Exception('Gagal memuat data pendapatan');
    }
  }
}