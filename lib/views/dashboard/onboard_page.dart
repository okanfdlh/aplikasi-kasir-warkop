import 'package:coffeeorder/widgets/button_primary.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OnboardPage extends StatelessWidget {
  const OnboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset('assets/illustration/mug.jpg'),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(38, 253, 217, 195),
                    Color(0xff050505),
                    Color(0xff050505),
                    Color(0xff050505),
                    Color(0xff050505),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(40),
                  const Text(
                    'Fall in Love with Coffee in Blissful Delight!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                      color: Color(0xffFFFFFF),
                      height: 1.5,
                    ),
                  ),
                  const Gap(8),
                  const Text(
                    'Welcome to our cozy coffee corner, where every cup is a delightful for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Color(0xffA2A2A2),
                    ),
                  ),
                  const Gap(30),
                  ButtonPrimary(
                    title: 'Get Started',
                    onTap: () async {
                      FirebaseMessaging messaging = FirebaseMessaging.instance;

                      NotificationSettings settings =
                          await messaging.requestPermission(
                        alert: true,
                        badge: true,
                        sound: true,
                      );

                      print(
                          'User granted permission: ${settings.authorizationStatus}');

                      Navigator.pushNamed(context, '/dashboard');
                    },
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
