// lib/screens/about_screen.dart (ΔΙΟΡΘΩΜΕΝΟ - ΑΦΑΙΡΕΣΗ Scaffold)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ΑΦΑΙΡΟΥΜΕ ΤΟ SCRAFFOLD, κρατάμε μόνο το GradientBackground
    return GradientBackground(
      child: Center(
        child: Text(
          'ΣΧΕΤΙΚΑ',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold,
            // Χρησιμοποιούμε λευκό χρώμα για να φαίνεται στο σκούρο gradient
            color: Colors.white, 
          ),
        ),
      ),
    );
  }
}