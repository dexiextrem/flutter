// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top3Async = ref.watch(top3NewsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(top3NewsProvider.notifier).fetchTop3();
      },
      color: const Color(0xFF6A1B9A),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      strokeWidth: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6A1B9A),
              isDark ? const Color(0xFF1F1F1F) : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  // LOGO + TITLE
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/hva_logo.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'ΠΑΝΕΛΛΗΝΙΟΣ\nΚΤΗΝΙΑΤΡΙΚΟΣ\nΣΥΛΛΟΓΟΣ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ΚΑΡΤΑ "ΤΕΛΕΥΤΑΙΑ ΝΕΑ"
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Τελευταία Νέα',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ΛΙΣΤΑ ΑΡΘΡΩΝ – ΧΩΡΙΣ DIVIDER
                          top3Async.when(
                            data: (topArticles) {
                              if (topArticles.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'Δεν βρέθηκαν άρθρα',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: topArticles.length,
                                itemBuilder: (context, index) {
                                  final article = topArticles[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20), // ΑΠΟΣΤΑΣΗ ΜΕΤΑΞΥ ΑΡΘΡΩΝ
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) => DetailScreen(initialArticle: article),
                                            transitionDuration: Duration.zero,
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                              height: 1.4,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                              const SizedBox(width: 6),
                                              Text(
                                                article.date,
                                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                            ),
                            error: (err, _) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                                  const SizedBox(height: 12),
                                  Text('Σφάλμα φόρτωσης', style: TextStyle(color: Colors.red[300])),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => ref.read(top3NewsProvider.notifier).fetchTop3(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A1B9A),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Προσπάθησε ξανά'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),

              // ΧΟΡΗΓΟΣ
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'ΧΟΡΗΓΟΣ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/images/sponsor_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}