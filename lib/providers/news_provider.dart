// lib/providers/news_provider.dart (ΤΟ ΔΙΚΟ ΣΟΥ – 77 ΓΡΑΜΜΕΣ – ΜΟΝΟ ΔΙΟΡΘΩΜΕΝΟ fetchArticle)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article.dart';

final top3NewsProvider = StateNotifierProvider<Top3Notifier, AsyncValue<List<Article>>>((ref) {
  return Top3Notifier();
});

class Top3Notifier extends StateNotifier<AsyncValue<List<Article>>> {
  Top3Notifier() : super(const AsyncValue.loading()) {
    fetchTop3();
  }

  final String _apiKey = "dFk9p3zvHBGdrt7ghDw3wT2mC4sL";

  Future<void> fetchTop3() async {
    state = const AsyncValue.loading();
    try {
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final url = 'https://www.hva.gr/api/index.php?apikey=$_apiKey&t=$cacheBuster';
      print('ΦΟΡΤΩΝΩ TOP3: $url');

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isEmpty) {
          state = const AsyncValue.data([]);
          return;
        }

        final top3 = jsonList
            .take(3)
            .map((json) => Article.fromJson({
                  'id': json['id'],
                  'title': json['title'],
                  'indate': json['indate'],
                  'image_url': json['image_url'],
                  'link': 'https://www.hva.gr/el/article.php?id=${json['id']}',
                }))
            .toList();

        state = AsyncValue.data(top3);
        print('ΦΟΡΤΩΘΗΚΑΝ TOP3: ${top3.length} άρθρα');
      } else {
        state = AsyncValue.error('HTTP ${response.statusCode}', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('ΣΦΑΛΜΑ fetchTop3: $e');
    }
  }

  // ΔΙΟΡΘΩΜΕΝΟ fetchArticle – ΜΕ DEBUG + ΕΛΕΓΧΟ
  Future<Article?> fetchArticle(int id) async {
    if (id <= 0) return null;

    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final url = 'https://www.hva.gr/api/article_details.php?id=$id&apikey=$_apiKey&t=$cacheBuster';
    print('ΦΟΡΤΩΝΩ ΑΡΘΡΟ: $url');

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      print('ΑΠΑΝΤΗΣΗ API: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // DEBUG: Δες τι παίρνεις
        print('JSON ΑΡΘΡΟΥ: $jsonData');

        // ΕΛΕΓΧΟΣ content
        final rawContent = jsonData['content']?.toString() ?? '';
        print('RAW CONTENT: "$rawContent"');

        if (rawContent.trim().isEmpty) {
          print('ΠΡΟΕΙΔΟΠΟΙΗΣΗ: content είναι κενό');
        }

        return Article.fromJson(jsonData);
      } else {
        print('ΣΦΑΛΜΑ HTTP: ${response.statusCode}');
      }
    } catch (e, stack) {
      print('ΣΦΑΛΜΑ fetchArticle: $e');
      print(stack);
    }
    return null;
  }
}