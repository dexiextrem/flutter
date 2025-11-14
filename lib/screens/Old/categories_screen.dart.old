// lib/screens/categories_screen.dart (ΔΙΟΡΘΩΜΕΝΟ - ΑΦΑΙΡΕΣΗ Scaffold)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import 'filtered_news_screen.dart'; 

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  final List<String> categories = const [
    'Δελτία Τύπου',
    'Ανακοινώσεις της Δ.Ε.',
    'Επαγγελματικά',
    'Επιστημονικά',
    'E-Shop',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ΑΦΑΙΡΟΥΜΕ ΤΟ SCRAFFOLD
    return GradientBackground(
      child: ListView.builder(
        // Η padding τώρα είναι ασφαλής, καθώς δεν υπάρχει AppBar
        padding: const EdgeInsets.all(16.0), 
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                leading: Icon(Icons.label, color: Theme.of(context).primaryColor),
                title: Text(
                  category,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Πλοήγηση στη φιλτραρισμένη λίστα
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FilteredNewsScreen(tag: category),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}