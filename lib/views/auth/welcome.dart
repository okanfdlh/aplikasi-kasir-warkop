import 'dart:ui';
import 'package:coffeeorder/views/auth/login.dart';
import 'package:coffeeorder/views/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // blur settings
  final double _sigmaX = 5; // from 0-10
  final double _sigmaY = 5;
  final double _opacity = 0.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // biar naik kalau keyboard muncul
      backgroundColor: Colors.grey[300],
      body: Stack(
        alignment: Alignment.center,
        children: [
          // background image
          Image.network(
            'https://cdn.pixabay.com/photo/2014/12/11/02/57/coffee-563800_640.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),

          // main content scrollable
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // back button
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back_ios),
                  //   color: Colors.white,
                  //   onPressed: () {},
                  // ),

                  const SizedBox(height: 40),

                  // title
                  Text(
                    "Selamat Datang !",
                    style: GoogleFonts.lobster(
                      // ganti sesuai selera: lobster, pacifico, dancingScript, dll
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // blur card form
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _sigmaX,
                        sigmaY: _sigmaY,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(_opacity),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height *
                              0.7, // maksimal
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // username textfield
                              MyTextField(
                                controller: usernameController,
                                hintText: 'Email',
                                obscureText: false,
                              ),

                              const SizedBox(height: 20),

                              // sign in button
                              MyButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  } else {
                                    print('not valid');
                                  }
                                },
                                text: 'Masuk',
                              ),

                              const SizedBox(height: 20),

                              // not a member? register now
                              Row(
                                children: [
                                  const Text(
                                    'Belum bergabung?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      // contoh: buka WA / kontak
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Signup(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Hubungi kami',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 71, 233, 133),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
