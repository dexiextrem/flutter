// lib/screens/filtered_news_screen.dart (Τελική Έκδοση)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import '../providers/news_provider.dart';
import 'detail_screen.dart'; // Import για πλοήγηση
import '../widgets/article_card.dart';

class FilteredNewsScreen extends ConsumerStatefulWidget {
  final String tag;
  const FilteredNewsScreen({super.key, required this.tag});

  @override
  ConsumerState<FilteredNewsScreen> createState() => _FilteredNewsScreenState();
}

class _FilteredNewsScreenState extends ConsumerState<FilteredNewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Αρχική φόρτωση με βάση το Tag που περάστηκε
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Εδώ καλούμε τον notifier με το tag και isInitial=true
      ref.read(newsProvider.notifier).fetchArticles(tag: widget.tag, isInitial: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Φόρτωση περισσότερων άρθρων, διατηρώντας το tag
      ref.read(newsProvider.notifier).fetchArticles(tag: widget.tag);
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    
    // Επαναφόρτωση της γενικής λίστας Νέων όταν κλείνει η φιλτραρισμένη οθόνη
    // (Αυτό διασφαλίζει ότι η NewsListScreen θα έχει τα μη φιλτραρισμένα δεδομένα όταν επιστρέψουμε)
    ref.read(newsProvider.notifier).fetchArticles(isInitial: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsProvider);
    // Φιλτράρουμε τα άρθρα τοπικά (αν και ο notifier φέρνει ήδη φιλτραρισμένα, 
    // αυτή η τοπική φίλτρανση είναι ένα επιπλέον safety net)
    final articles = newsState.articles.where((a) => a.tag == widget.tag).toList(); 
    final isLoading = newsState.isLoading;
    final hasMore = newsState.hasMore;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Άρθρα: ${widget.tag}'),
      ),
      backgroundColor: Colors.transparent, // Απαραίτητο για το gradient
      body: GradientBackground(
        child: articles.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref.read(newsProvider.notifier).fetchArticles(tag: widget.tag, isInitial: true),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: articles.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == articles.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final article = articles[index];
                    
                    return ArticleCard(
                      article: article,
                      onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(article: article),
                            ),
                          );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}