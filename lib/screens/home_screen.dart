// lib/screens/home_screen.dart (ΤΕΛΙΚΟ – ΜΕ DARK MODE ΑΠΟ ΚΙΝΗΤΟ)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import 'detail_screen.dart';
import 'news_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top3Async = ref.watch(top3NewsProvider);
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(top3NewsProvider.notifier).fetchTop3();
        },
        color: const Color.fromARGB(255, 197, 162, 218),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        strokeWidth: 3,
        displacement: 40,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6A1B9A),
                isDark ? const Color(0xFF1F1F1F) : const Color.fromARGB(255, 255, 255, 255),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ListView(
                  children: [
                    // LOGO + TITLE
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      child: Row(
                        children: [
                          Image.asset('assets/images/hva_logo.png', height: 130),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'ΠΑΝΕΛΛΗΝΙΟΣ\nΚΤΗΝΙΑΤΡΙΚΟΣ\nΣΥΛΛΟΓΟΣ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.only(top: 10),
                        constraints: BoxConstraints(
                          maxWidth: 600,
                          maxHeight: MediaQuery.of(context).size.height * 0.55,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: Text(
                                'Τελευταία Νέα',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                   color: isDark ? Colors.white : const Color(0xFF6A1B9A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            top3Async.when(
                              data: (topArticles) {
                                if (topArticles.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text('Δεν βρέθηκαν άρθρα'),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: topArticles.length,
                                    itemBuilder: (context, index) {
                                      final article = topArticles[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: InkWell(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => DetailScreen(initialArticle: article)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                article.title,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    article.date,
                                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(color: Color.fromARGB(255, 197, 162, 218)),
                              ),
                              error: (err, _) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red, size: 60),
                                    Text('Σφάλμα: $err'),
                                    ElevatedButton(
                                      onPressed: () => ref.read(top3NewsProvider.notifier).fetchTop3(),
                                      child: const Text('Προσπάθησε ξανά'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),

                // ΧΟΡΗΓΟΣ
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'ΧΟΡΗΓΟΣ:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset('assets/images/sponsor_logo.png', height: 65),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 151, 99, 189),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Αρχική'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Νέα'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Κατηγορίες'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Σχετικά'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsListScreen()));
          }
        },
      ),
    );
  }
}