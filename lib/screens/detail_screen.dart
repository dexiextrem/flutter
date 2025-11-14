// lib/screens/detail_screen.dart (ΤΕΛΙΚΟ – ΜΕ DARK MODE, ΧΩΡΙΣ GRADIENT, ΛΕΥΚΟ/ΜΑΥΡΟ ΦΟΝΤΟ)

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; 
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import 'home_screen.dart';
import 'news_list_screen.dart';
import 'package:url_launcher/url_launcher.dart'; 

// ΑΠΑΡΑΙΤΗΤΑ IMPORTS
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Article initialArticle;
  const DetailScreen({super.key, required this.initialArticle});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late Future<Article?> _articleFuture;
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    final id = int.tryParse(widget.initialArticle.id) ?? 0;
    _articleFuture = ref.read(top3NewsProvider.notifier).fetchArticle(id); 
    _extractYouTubeVideo();
  }

  void _extractYouTubeVideo() {
    final content = widget.initialArticle.content;
    final regex = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(content);
    if (match != null) {
      final videoId = match.group(1);
      _ytController = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      final id = int.tryParse(widget.initialArticle.id) ?? 0;
      _articleFuture = ref.read(top3NewsProvider.notifier).fetchArticle(id);
    });
  }

  Future<void> _launchURL(String? url) async {
    if (url != null) {
      String fullUrl = url;
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://') && !fullUrl.startsWith('mailto:')) {
        fullUrl = 'https://$url';
      }
      final uri = Uri.tryParse(fullUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Δεν ήταν δυνατή η φόρτωση του συνδέσμου: $url'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ΔΙΟΡΘΩΜΕΝΗ _openGallery
  void _openGallery(Article article, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryScreen(images: article.galleryImages, initialIndex: index),
      ),
    );
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: const Text('Άρθρο'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF6A1B9A),
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        strokeWidth: 3,
        child: FutureBuilder<Article?>(
          future: _articleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 60),
                    Text('Σφάλμα: ${snapshot.error}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                    ElevatedButton(onPressed: _refresh, child: const Text('Προσπάθησε ξανά')),
                  ],
                ),
              );
            }

            final article = snapshot.data ?? widget.initialArticle;

            return SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ΤΙΤΛΟΣ
                    Text(
                      article.title,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, height: 1.3),
                    ),
                    const SizedBox(height: 12),

                    // 2. ΗΜΕΡΟΜΗΝΙΑ
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.white70 : Colors.grey),
                        const SizedBox(width: 8),
                        Text(article.date, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. ΚΥΡΙΑ ΕΙΚΟΝΑ
                    if (article.mainImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: '${article.mainImage}?t=${DateTime.now().millisecondsSinceEpoch}',
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 240,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 240,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // 4. ΚΕΙΜΕΝΟ (HTML)
                    Html(
                      data: article.content,
                      style: {
                        "body": Style(fontSize: FontSize(17), lineHeight: LineHeight(1.7), color: isDark ? Colors.white70 : Colors.black87),
                        "p": Style(margin: Margins(top: Margin(14), bottom: Margin(14))),
                        "img": Style(display: Display.none),
                        "iframe": Style(display: Display.none),
                        "figure": Style(padding: HtmlPaddings.all(0), margin: Margins.all(0)),
                        "figcaption": Style(fontSize: FontSize(14), color: isDark ? Colors.grey[400] : Colors.grey[600], textAlign: TextAlign.center),
                      },
                      onLinkTap: (url, attributes, element) { 
                        _launchURL(url); 
                      },
                    ),

                    // 5. GALLERY – ΣΤΟ ΤΕΛΟΣ
                    if (article.galleryImages.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text("Φωτογραφίες", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: article.galleryImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _openGallery(article, index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: article.galleryImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // 6. YOUTUBE – ΣΤΟ ΤΕΛΟΣ
                    if (_ytController != null) ...[
                      const SizedBox(height: 32),
                      Text("Βίντεο", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      YoutubePlayer(
                        controller: _ytController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: const Color(0xFF6A1B9A),
                      ),
                    ],

                  ],
                ),
              ),
            );
          },
        ),
      ),

      // BOTTOM NAVIGATION – ΑΜΕΤΑΒΛΗΤΟ
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Αρχική'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Νέα'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Κατηγορίες'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Σχετικά'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsListScreen()));
          }
        },
      ),
    );
  }
}

// GALLERY SCREEN – ΑΜΕΤΑΒΛΗΤΟ
class GalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const GalleryScreen({super.key, required this.images, required this.initialIndex});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            onPageChanged: (index) => setState(() => currentIndex = index),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text("${currentIndex + 1} / ${widget.images.length}", style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}