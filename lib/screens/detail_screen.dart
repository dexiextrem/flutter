import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/article.dart';

class DetailScreen extends StatelessWidget {
  final Article article;
  const DetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Άρθρο')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (article.image.isNotEmpty) Image.network(article.image),
            const SizedBox(height: 16),
            Text(article.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(article.date),
            const Divider(height: 32),
            Html(data: article.content),
          ],
        ),
      ),
    );
  }
}