import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:coba1/views/menu_page.dart';
import 'package:coba1/views/transaksi_page.dart';
import 'package:coba1/views/tambah_menu_page.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: AuthCheck(), // Cek apakah user sudah login
    );
  }
}

// 🔑 Cek apakah user sudah login
class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? HomePage() : LoginPage();
  }
}

// 🔑 Halaman Login
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
  Uri.parse('https://rumahseduh.wuaze.com/api/login'),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent': 'FlutterApp/1.0',
  },
  body: {
    'email': emailController.text,
    'password': passwordController.text,
  },
);



print(response.body); // Tambahkan ini untuk melihat respons sebenarnya

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal! Periksa email dan password.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Email tidak boleh kosong" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Password tidak boleh kosong" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text("Login", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🏠 Halaman Utama setelah login
class HomePage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token"); // Hapus token untuk logout
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kasir Rumah Seduh",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 30),

            _buildMenuButton(
              icon: Icons.menu_book,
              label: "Daftar Menu",
              context: context,
              page: MenuPage(),
            ),

            _buildMenuButton(
              icon: Icons.receipt_long,
              label: "Transaksi",
              context: context,
              page: OrdersPage(),
            ),

            _buildMenuButton(
              icon: Icons.add_box,
              label: "Tambah Menu",
              context: context,
              page: TambahMenuPage(),
            ),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required BuildContext context, required Widget page}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade800,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
      ),
    );
  }
}
