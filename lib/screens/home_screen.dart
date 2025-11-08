// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import 'detail_screen.dart';
import 'news_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topArticles = ref.watch(top3NewsProvider);
    final isLoading = ref.watch(newsProvider.select((s) => s.isLoading));

    return Scaffold(
      // GRADIENT BACKGROUND ΑΠΟ ΠΑΝΩ ΜΕΧΡΙ ΚΑΤΩ
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A), // Μωβ πάνω
              Color(0xFF8E24AA),
              Color(0xFFAB47BC),
              Color(0xFFCE93D8), // Ανοιχτό μωβ κάτω
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1/4 ΠΑΝΩ: Logo + Τίτλος (ΜΕ ΤΙΣ ΔΙΚΕΣ ΣΟΥ ΑΛΛΑΓΕΣ)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), // ΜΙΚΡΟ PADDING ΚΑΤΩ
                child: Row(
                  children: [
                    Image.asset('assets/images/hva_logo.png', height: 130), // Το δικό σου μέγεθος
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'ΠΑΝΕΛΛΗΝΙΟΣ\nΚΤΗΝΙΑΤΡΙΚΟΣ\nΣΥΛΛΟΓΟΣ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28, // Το δικό σου μέγεθος
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2/4 ΜΕΣΗ: ΜΙΑ ΚΑΡΤΑ ΜΕ 3 ΕΙΔΗΣΕΙΣ (ΣΤΑΘΕΡΟ ΥΨΟΣ, ΧΩΡΙΣ SCROLL)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.only(top: 10), // ΜΙΚΡΟ PADDING ΠΑΝΩ
                height: MediaQuery.of(context).size.height * 0.45, // Σταθερό 50% της οθόνης
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text(
                        'Τελευταία Νέα',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    ),
                    Expanded(
                      child: isLoading && topArticles.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)))
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(), // ΧΩΡΙΣ SCROLL
                                itemCount: topArticles.length,
                                itemBuilder: (context, index) {
                                  final article = topArticles[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => DetailScreen(article: article)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ΤΙΤΛΟΣ: 3 ΓΡΑΜΜΕΣ + ΑΥΤΟΜΑΤΟ ΜΙΚΡΑΙΝΕΙ ΑΝ ΧΡΕΙΑΖΕΤΑΙ
                                          Text(
                                            article.title,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                          const SizedBox(height: 4),
                                          // ΗΜΕΡΟΜΗΝΙΑ: ΕΜΦΑΝΙΖΕΤΑΙ ΠΑΝΤΑ
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
                                          if (index < topArticles.length - 1)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 12),
                                              child: Divider(height: 1, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const Spacer(), // ΧΩΡΟΣ ΑΝΑΜΕΣΑ ΣΤΑ 2 CONTAINERS

              // 1/4 ΚΑΤΩ: Χορηγός + Logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Text(
                    'ΧΟΡΗΓΟΣ:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 215, 203, 223)),
                  ),
                  const SizedBox(height: 0),
                  Image.asset('assets/images/sponsor_logo.png', height: 65),
                ],
              ),
            ),
          ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6A1B9A),
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
