// lib/screens/news_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../providers/slider_provider.dart';
import 'detail_screen.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;

  final List<Map<String, String>> categories = [
    {"id": "all", "title": "Όλα"},
    {"id": "206", "title": "Δελτία Τύπου"},
    {"id": "10", "title": "Ανακοινώσεις Δ.Ε."},
    {"id": "11", "title": "Επαγγελματικά"},
    {"id": "12", "title": "Επιστημονικά"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    ref.read(sliderIdsProvider);
    ref.read(top3NewsProvider.notifier).fetchTop3();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sliderIds = ref.watch(sliderIdsProvider).when(
          data: (ids) => ids,
          loading: () => <String>[],
          error: (_, __) => <String>[],
        );

    final articlesAsync = ref.watch(top3NewsProvider);

    return Column(
      children: [
        // ΜΠΑΡΑ ΚΑΤΗΓΟΡΙΩΝ – ΜΕ ΜΩΒ ΧΡΩΜΑ
        Container(
          height: 50,
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF6A1B9A), // ΜΩΒ
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF6A1B9A), // ΜΩΒ
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: categories
                .map((c) => Tab(text: c["title"]!))
                .toList(growable: false),
            onTap: (i) {
              // Μπορείς να φιλτράρεις αργότερα
              ref.read(top3NewsProvider.notifier).fetchTop3();
            },
          ),
        ),

        // ΚΑΡΟΥΣΕΛ
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.30,
          child: articlesAsync.when(
            data: (articles) {
              final sliderArticles =
                  articles.where((a) => sliderIds.contains(a.id)).toList();
              if (sliderArticles.isEmpty) {
                return _buildEmptyCarousel(isDark);
              }
              return PageView.builder(
                controller: _carouselController,
                onPageChanged: (i) => setState(() => _currentCarouselIndex = i),
                itemCount: sliderArticles.length,
                itemBuilder: (context, i) =>
                    _buildCarouselItem(sliderArticles[i], isDark),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            ),
            error: (_, __) => _buildEmptyCarousel(isDark),
          ),
        ),

        // DOT INDICATORS – ΜΩΒ
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: articlesAsync.maybeWhen(
            data: (articles) {
              final count =
                  articles.where((a) => sliderIds.contains(a.id)).length;
              if (count == 0) return const SizedBox.shrink();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  count,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentCarouselIndex == i ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentCarouselIndex == i
                          ? const Color(0xFF6A1B9A) // ΜΩΒ
                          : Colors.grey,
                    ),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ),

        // ΛΙΣΤΑ ΑΡΘΡΩΝ
        Expanded(
          child: articlesAsync.when(
            data: (articles) {
              final displayArticles = articles
                  .where((a) => !sliderIds.contains(a.id))
                  .take(20)
                  .toList();
              if (displayArticles.isEmpty) {
                return const Center(
                  child: Text(
                    'Δεν βρέθηκαν άρθρα',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: displayArticles.length,
                itemBuilder: (context, i) =>
                    _buildArticleCard(displayArticles[i], isDark),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            ),
            error: (err, _) => Center(
              child: Text(
                'Σφάλμα φόρτωσης',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ———————————————————
  // ΚΕΝΟ ΚΑΡΟΥΣΕΛ
  // ———————————————————
  Widget _buildEmptyCarousel(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Δεν υπάρχουν σημαντικά νέα',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ———————————————————
  // ΚΑΡΟΥΣΕΛ ΑΡΘΡΟ
  // ———————————————————
  Widget _buildCarouselItem(Article article, bool isDark) {
    return InkWell(
      onTap: () => _openArticle(article),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ΕΙΚΟΝΑ
          if (article.mainImage?.isNotEmpty ?? false)
            CachedNetworkImage(
              imageUrl: article.mainImage!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[300]),
            )
          else
            Container(color: Colors.grey[300]),

          // GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),

          // ΚΕΙΜΕΝΟ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ΕΤΙΚΕΤΑ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A), // ΜΩΒ
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ΠΡΩΤΟ ΘΕΜΑ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ΤΙΤΛΟΣ
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // ΗΜΕΡΟΜΗΝΙΑ
                Text(
                  '${article.date} • hva.gr',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ———————————————————
  // ΚΑΡΤΑ ΑΡΘΡΟΥ
  // ———————————————————
  Widget _buildArticleCard(Article article, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openArticle(article),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ΕΙΚΟΝΑ
              if (article.mainImage?.isNotEmpty ?? false)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: article.mainImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey[300]),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.article, color: Colors.grey[500]),
                ),

              const SizedBox(width: 14),

              // ΚΕΙΜΕΝΟ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          article.date,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ΒΕΛΟΣ
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ———————————————————
  // ΑΝΟΙΓΜΑ ΑΡΘΡΟΥ
  // ———————————————————
  void _openArticle(Article article) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => DetailScreen(initialArticle: article),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}