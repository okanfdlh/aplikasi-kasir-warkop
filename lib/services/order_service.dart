import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<List<dynamic>> fetchOrders() async {
    final response = await http.get(Uri.parse('https://rumahseduh.wuaze.com/api/orders'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data order');
    }
  }
}
