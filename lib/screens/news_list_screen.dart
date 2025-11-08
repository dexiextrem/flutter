// lib/screens/news_list_screen.dart (ΔΙΟΡΘΩΜΕΝΟ - ΑΦΑΙΡΕΣΗ Scaffold)

import 'package:flutter/material.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Όλα τα Νέα')),
      body: const Center(child: Text('Θα το φτιάξουμε αύριο!')),
    );
  }
}