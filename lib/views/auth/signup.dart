import 'dart:ui';

import 'package:coffeeorder/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class Signup extends StatelessWidget {
  Signup({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  double _sigmaX = 5; // from 0-10
  double _sigmaY = 5; // from 0-10
  double _opacity = 0.2;
  final _formKey = GlobalKey<FormState>();

  // sign user in method
  void signUserIn() {
    if (_formKey.currentState!.validate()) {
      print('valid');
    } else {
      print('not valid');
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
              Image.network(
                'https://cdn.pixabay.com/photo/2020/06/02/19/37/coffee-5252373_640.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.26),
                  Text(
                    "Daftar",
                    style: GoogleFonts.lobster(
                      // ganti sesuai selera: lobster, pacifico, dancingScript, dll
                      color: Colors.white,
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
                                    "Belum memiliki akun? Silakan daftar terlebih dahulu",
                                    // ignore: prefer_const_constructors
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  // ignore: prefer_const_constructors
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
                                    controller: usernameController,
                                    hintText: 'Email',
                                    obscureText: false,
                                  ),

                                  const SizedBox(height: 10),
                                  MyPasswordTextField(
                                    controller: passwordController,
                                    hintText: 'Password',
                                    obscureText: true,
                                  ),
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
                                              text:
                                                  "Dengan memilih 'Setuju & Lanjutkan', saya setuju dengan syarat dan ketentuan ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Syarat & Ketentuan',
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
                                      MyButtonAgree(
                                        text: "Setuju dan Lanjutkan",
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        },
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
}
