import 'package:flutter/material.dart';

// Custom Widget untuk Snackbar
class CustomExitSnackbar extends StatefulWidget {
  final VoidCallback onDismiss;

  const CustomExitSnackbar({required this.onDismiss, super.key});

  @override
  State<CustomExitSnackbar> createState() => CustomExitSnackbarState();
}

class CustomExitSnackbarState extends State<CustomExitSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(
                (_fadeAnimation.value * 176).toInt(), // 0-176 alpha
                16,
                24,
                13,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tekan lagi untuk keluar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Sans',
              ),
            ),
          );
        },
      ),
    );
  }
}
