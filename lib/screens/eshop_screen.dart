// lib/screens/eshop_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EshopScreen extends StatefulWidget {
  const EshopScreen({super.key});

  @override
  State<EshopScreen> createState() => _EshopScreenState();
}

class _EshopScreenState extends State<EshopScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://shop.hva.gr/')); // ΑΛΛΑΞΕ ΜΕ ΤΟ URL ΣΟΥ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: // lib/screens/eshop_screen.dart
AppBar(
  title: const Text('eShop'),
  backgroundColor: const Color(0xFF6A1B9A),
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () => _controller.reload(),
    ),
  ],
),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}