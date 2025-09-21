import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    // Gunakan pushReplacement supaya AuthCheck tidak tumpuk di atas route lain
    if (token != null) {
      if (ModalRoute.of(context)?.settings.name == "/") {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else {
      if (ModalRoute.of(context)?.settings.name == "/") {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
