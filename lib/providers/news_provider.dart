// lib/providers/news_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article.dart';

class NewsState {
  final List<Article> articles;
  final bool isLoading;
  final bool hasMore;

  NewsState({required this.articles, this.isLoading = false, this.hasMore = true});

  NewsState copyWith({List<Article>? articles, bool? isLoading, bool? hasMore}) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier() : super(NewsState(articles: [])) {
    fetchTop3();
  }

  final String apiKey = "dFk9p3zvHBGdrt7ghDw3wT2mC4sL";

  Future<void> fetchTop3() async {
    state = state.copyWith(isLoading: true);
    final List<Article> top3 = [];

    for (int id = 2623; id >= 2621; id--) {
      final article = await _fetchArticle(id);
      if (article != null) top3.add(article);
    }

    state = state.copyWith(articles: top3, isLoading: false);
  }

  Future<Article?> _fetchArticle(int id) async {
    try {
      final url = 'https://www.hva.gr/api/article_details.php?id=$id&apikey=$apiKey';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['title'] != null && (json['publication_date'] != null || json['date'] != null)) {
          return Article.fromJson(json);
        }
      }
    } catch (e) {
      // σιωπηλά
    }
    return null;
  }
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) => NewsNotifier());
final top3NewsProvider = Provider((ref) => ref.watch(newsProvider).articles);