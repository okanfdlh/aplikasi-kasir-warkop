import 'dart:ui';
import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/components/my_textfield.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

// ignore: must_be_immutable
class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final apiService = ApiService();

  final double _sigmaX = 5; // from 0-10
  final double _sigmaY = 5; // from 0-10
  final double _opacity = 0.2;
  // final _formKey = GlobalKey<FormState>();

  // sign user in method
  void signUserIn() {
    if (_formKey.currentState!.validate()) {
      print('valid');
    } else {
      print('not valid');
    }
  }

  Future<void> _login(BuildContext context) async {
    setState(() => isLoading = true);
    if (!_formKey.currentState!.validate()) {
      setState(() => isLoading = false);
      return;
    }

    final response = await apiService.dio.post(
      '/api/login',
      options: Options(headers: {"Accept": "application/json"}),
      data: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['user']['role']);

      // simpan FCM token ke backend
      _afterLoginSuccess(data['user']['id'].toString());

      setState(() => isLoading = false);
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: 0);
    } else {
      print("Login gagal: ${response.data}");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login gagal')));
    }
  }

  void _afterLoginSuccess(String userId) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      // Kirim token awal setelah login
      await _sendTokenToBackend(fcmToken);
    }

    // Listen kalau ada refresh token baru
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _sendTokenToBackend(newToken);
    });
  }

  Future<void> _sendTokenToBackend(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token'); // ini Laravel auth token

    if (authToken != null) {
      await ApiService().dio.post(
        '/api/save-fcm-token',
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Accept": "application/json",
          },
        ),
        data: {"fcm_token": fcmToken}, // kirim FCM device token asli
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/illustration/2mug.jpg",
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back_ios),
                  //   color: Colors.white,
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  Text(
                    "Masuk",
                    style: GoogleFonts.lobster(
                      // ganti sesuai selera: lobster, pacifico, dancingScript, dll
                      color: const Color(0xff024924),
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _sigmaX,
                        sigmaY: _sigmaY,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(
                            0,
                            0,
                            0,
                            1,
                          ).withOpacity(_opacity),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.49,
                        child: Form(
                          key: _formKey,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Silakan masuk dengan akun yang telah Anda daftarkan.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  // const Text(
                                  //   "jane.doe@gmail.com",
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 20,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  //   textAlign: TextAlign.start,
                                  // ),
                                  const SizedBox(height: 30),
                                  MyTextField(
                                    controller: emailController,
                                    hintText: 'Email',
                                    obscureText: false,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Email tidak boleh kosong';
                                      } else if (!RegExp(
                                        r'^[^@]+@[^@]+\.[^@]+',
                                      ).hasMatch(val)) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  MyTextField(
                                    controller: passwordController,
                                    hintText: 'Password',
                                    obscureText: true,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Password tidak boleh kosong';
                                      } else if (val.length < 6) {
                                        return 'Password minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: 20),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      RichText(
                                        text: const TextSpan(
                                          text: '',
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: "Belum memiliki akun? ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Daftar disini.',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  71,
                                                  233,
                                                  133,
                                                ),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      MyButton(
                                        text: "Lanjutkan",
                                        isLoading: isLoading,
                                        onPressed: () => _login(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTextField(TextEditingController controller, String hint,
  //     IconData icon, bool obscure) {
  //   return TextFormField(
  //     controller: controller,
  //     obscureText: obscure,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(icon, color: Colors.green.shade800),
  //       labelText: hint,
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //       filled: true,
  //       fillColor: Colors.green.shade50,
  //     ),
  //     validator: (value) {
  //       if (value == null || value.isEmpty) {
  //         return "$hint tidak boleh kosong";
  //       }
  //       return null;
  //     },
  //   );
  // }
}
