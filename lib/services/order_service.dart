import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<List<dynamic>> fetchOrders() async {
    final response = await http.get(Uri.parse('http://192.168.1.4:8000/api/orders'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data order');
    }
  }
}
