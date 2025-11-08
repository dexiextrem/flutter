// lib/screens/articles_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

// ΣΗΜΑΝΤΙΚΟ: Import των άλλων τοπικών αρχείων
import '../models/article.dart'; 
import 'detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});
  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Article> articles = [];
  bool loading = true;
  String? errorMessage;
  final String apiKey = "dFk9p3zvHBGdrt7ghDw3wT2mC4sL";

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      loading = true;
      errorMessage = null;
      articles.clear();
    });

    List<Future<http.Response>> requests = [];
    for (int id = 2623; id >= 2600; id--) {
      final url = 'https://www.hva.gr/api/article_details.php?id=$id&apikey=$apiKey';
      requests.add(http.get(Uri.parse(url)).timeout(const Duration(seconds: 8)));
    }

    try {
      final responses = await Future.wait(requests);
      for (final response in responses) {
        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            final json = jsonDecode(response.body);
            if (json['title'] != null && json['title'] != '') {
              articles.add(Article.fromJson(json));
            }
          }
        }
      }
      
      articles.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));

    } catch (e) {
      debugPrint('Σφάλμα κατά τη φόρτωση των άρθρων: $e');
      setState(() {
        errorMessage = 'Δεν ήταν δυνατή η φόρτωση των άρθρων. Ελέγξτε τη σύνδεσή σας ή προσπαθήστε αργότερα.';
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HVA Νέα', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 16),
                        Text(errorMessage!, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : articles.isEmpty && !loading
                  ? Center(
                      child: Text('Δεν βρέθηκαν άρθρα.', style: TextStyle(color: Colors.grey[600])),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchArticles,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: articles.length,
                        itemBuilder: (context, i) {
                          final a = articles[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: a.image,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Icon(Icons.image, size: 40, color: Colors.grey),
                                  errorWidget: (_, __, ___) => const Icon(Icons.error, size: 40, color: Colors.red),
                                ),
                              ),
                              title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(a.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(article: a))),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        onPressed: fetchArticles,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}