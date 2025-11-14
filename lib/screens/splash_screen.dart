// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../main.dart'; // Για το MainScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Χωρίς Key? key

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A), // Μωβ HVA
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/hva_logo.png', height: 250),
            const SizedBox(height: 40),
            const Text(
              'ΠΑΝΕΛΛΗΝΙΟΣ\nΚΤΗΝΙΑΤΡΙΚΟΣ\nΣΥΛΛΟΓΟΣ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 80),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}