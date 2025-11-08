// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import '../navigation/main_navigation_screen.dart'; // Οθόνη προορισμού

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Μέθοδος για την πλοήγηση μετά από καθυστέρηση
  void _navigateToHome() async {
    // Καθυστέρηση 2 δευτερολέπτων
    await Future.delayed(const Duration(seconds: 2));

    // Πλοήγηση στην κύρια οθόνη (αντικαθιστώντας την τρέχουσα)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Το Scaffold πρέπει να είναι διαφανές για να φαίνεται το gradient
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. Λογότυπο Εφαρμογής (Asset)
              Image.asset(
                'assets/images/hva_logo.png',
                height: 150,
                // Χρησιμοποιούμε color filter αν είναι Dark Mode
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
              ),
              const SizedBox(height: 20),
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}