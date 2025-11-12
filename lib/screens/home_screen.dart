// lib/screens/home_screen.dart (ΤΕΛΙΚΟ – ΧΟΡΗΓΟΣ ΚΑΤΩ, ΚΑΡΤΑ ΚΕΝΤΡΑΡΙΣΜΕΝΗ)

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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(top3NewsProvider.notifier).fetchTop3();
        },
        color: const Color(0xFF6A1B9A),
        backgroundColor: Colors.white,
        strokeWidth: 3,
        displacement: 40,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6A1B9A), Color(0xFFF3E5F5)],
            ),
          ),
          child: SafeArea(
            child: Stack( // ΧΡΗΣΙΜΟΠΟΙΟΥΜΕ Stack
              children: [
                // ΑΝΑΝΕΩΣΙΜΟ ΠΕΡΙΕΧΟΜΕΝΟ (ΚΑΡΤΑ)
                ListView(
                  children: [
                    // LOGO + TITLE
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      child: Row(
                        children: [
                          Image.asset('assets/images/hva_logo.png', height: 130),
                          const SizedBox(width: 14),
                          const Expanded(
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

                    // ΚΕΝΤΡΙΚΗ ΚΑΡΤΑ – ΚΕΝΤΡΑΡΙΣΜΕΝΗ
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
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
                    const SizedBox(height: 120), // ΧΩΡΟΣ ΓΙΑ ΧΟΡΗΓΟ
                  ],
                ),

                // ΧΟΡΗΓΟΣ – ΣΤΑΘΕΡΟΣ ΚΑΤΩ
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Text(
                          'ΧΟΡΗΓΟΣ:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
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