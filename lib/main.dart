import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart'; // ΜΟΝΟ ΑΥΤΟ ΧΡΕΙΑΖΕΤΑΙ

void main() {
  runApp(const ProviderScope(child: HvaApp()));
}

class HvaApp extends StatelessWidget {
  const HvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HVA Νέα',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system, // ΑΥΤΗ Η ΓΡΑΜΜΗ ΚΑΝΕΙ ΤΗ ΜΑΓΕΙΑ
      home: SplashScreen(),
    );
  }
}