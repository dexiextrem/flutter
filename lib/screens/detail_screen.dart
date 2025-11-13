// lib/screens/detail_screen.dart (ΤΕΛΙΚΟ – ΜΕ BOTTOM NAV + SAFEAREA)

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; 
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../providers/news_provider.dart'; // Εισάγει τον top3NewsProvider
import 'home_screen.dart';
import 'news_list_screen.dart';
import 'package:url_launcher/url_launcher.dart'; 


class DetailScreen extends ConsumerStatefulWidget {
  final Article initialArticle;
  const DetailScreen({super.key, required this.initialArticle});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late Future<Article?> _articleFuture;

  @override
  void initState() {
    super.initState();
    final id = int.tryParse(widget.initialArticle.id) ?? 0;
    // ΔΙΟΡΘΩΣΗ: Χρησιμοποιούμε top3NewsProvider.notifier
    _articleFuture = ref.read(top3NewsProvider.notifier).fetchArticle(id); 
  }

  Future<void> _refresh() async {
    setState(() {
      final id = int.tryParse(widget.initialArticle.id) ?? 0;
      // ΔΙΟΡΘΩΣΗ: Χρησιμοποιούμε top3NewsProvider.notifier
      _articleFuture = ref.read(top3NewsProvider.notifier).fetchArticle(id);
    });
  }

  // ΣΥΝΑΡΤΗΣΗ: Για άνοιγμα URL - Πιο ισχυρή και με ανατροφοδότηση χρήστη
  Future<void> _launchURL(String? url) async {
    if (url != null) {
      String fullUrl = url;
      
      // ΒΗΜΑ 1: Προσθέτουμε HTTPS αν λείπει το πρωτόκολλο (scheme)
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://') && !fullUrl.startsWith('mailto:')) {
        fullUrl = 'https://$url';
      }

      final uri = Uri.tryParse(fullUrl);
      
      // ΒΗΜΑ 2: Εκκίνηση URL
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        // ΒΗΜΑ 3: Εμφανίζουμε μήνυμα αποτυχίας στον χρήστη (SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Δεν ήταν δυνατή η φόρτωση του συνδέσμου: $url'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        print('Could not launch $fullUrl');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: const Text('Άρθρο'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF6A1B9A),
        backgroundColor: Colors.white,
        strokeWidth: 3,
        child: FutureBuilder<Article?>(
          future: _articleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 60),
                    Text('Σφάλμα: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Προσπάθησε ξανά'),
                    ),
                  ],
                ),
              );
            }

            final article = snapshot.data ?? widget.initialArticle;

            return SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 100px για bottom nav
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          article.date,
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (article.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: '${article.image}?t=${DateTime.now().millisecondsSinceEpoch}',
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 240,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 240,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Html(
                      data: article.content,
                      style: {
                        "body": Style(fontSize: FontSize(17), lineHeight: LineHeight(1.7), color: Colors.black87),
                        "p": Style(margin: Margins(top: Margin(14), bottom: Margin(14))),
                        "img": Style(width: Width(100, Unit.percent), margin: Margins.symmetric(vertical: 16)),
                        "figure": Style(padding: HtmlPaddings.all(0), margin: Margins.all(0)),
                        "figcaption": Style(
                          fontSize: FontSize(14),
                          color: Colors.grey[600],
                          textAlign: TextAlign.center,
                          padding: HtmlPaddings.symmetric(horizontal: 8),
                        ),
                      },
                      onLinkTap: (url, attributes, element) { 
                        _launchURL(url); 
                      },
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // BOTTOM NAVIGATION – ΕΜΦΑΝΙΖΕΤΑΙ ΚΑΙ ΣΤΟ ΑΡΘΡΟ
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // ΕΝΕΡΓΟ ΤΟ "ΝΕΑ"
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Αρχική'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Νέα'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Κατηγορίες'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Σχετικά'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsListScreen()));
          }
        },
      ),
    );
  }
}