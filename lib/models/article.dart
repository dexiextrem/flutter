// lib/models/article.dart (ΤΕΛΙΚΟ – ΜΕ mainImage + galleryImages – ΧΩΡΙΣ image)

import 'dart:developer' as devtools;

class Article {
  final String id;
  final String title;
  final String date;
  final String? mainImage;           // ΝΕΟ: Κύρια εικόνα από API
  final List<String> galleryImages; // ΝΕΟ: Λίστα με εικόνες gallery
  final String content;
  final String link;

  Article({
    required this.id,
    required this.title,
    required this.date,
    required this.mainImage,
    required this.galleryImages,
    required this.content,
    this.link = '',
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final String link = json['link']?.toString() ?? '';
    String finalId = '0';

    if (link.isNotEmpty) {
      final match = RegExp(r'article\.php\?id=(\d+)').firstMatch(link);
      if (match != null) {
        finalId = match.group(1)!;
        devtools.log('ID ΑΠΟ LINK: $finalId');
      }
    }

    if (finalId == '0') {
      final rawId = json['id']?.toString() ?? '';
      if (rawId.isNotEmpty && RegExp(r'^\d+$').hasMatch(rawId.trim())) {
        finalId = rawId.trim();
      }
    }

    String rawContent = json['content']?.toString() ?? '';

    // ΕΝΙΣΧΥΜΕΝΟΣ ΚΑΘΑΡΙΣΜΟΣ ΓΙΑ <p><br> ΧΩΡΙΣ </p>
    rawContent = rawContent
        .replaceAll(RegExp(r'<p>\s*<br\s*/?>(?!\s*</p>)', caseSensitive: false), '<p></p>')
        .replaceAll(RegExp(r'<p>\s*<br\s*/?>\s*</p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<p>\s*</p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<p>\s*&nbsp;\s*</p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<p>\s* \s*</p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'(<p>\s*</p>\s*)+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[[^\]]+\]'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    final String finalContent = rawContent.isEmpty
        ? '<p>Δεν υπάρχει περιεχόμενο.</p>'
        : '<p>$rawContent</p>';

    final String formattedDate = json['indate']?.toString() ??
        json['publication_date']?.toString() ??
        json['date']?.toString() ??
        'Χωρίς ημερομηνία';

    // ΝΕΟ: main_image από API
    final String mainImageUrl = json['main_image']?.toString() ?? '';

    // ΝΕΟ: gallery_images από API
    final List<String> galleryImagesList = json['gallery_images'] != null
        ? List<String>.from(json['gallery_images'].map((x) => x.toString()))
        : <String>[];

    return Article(
      id: finalId,
      title: json['title']?.toString() ?? 'Χωρίς τίτλο',
      date: formattedDate,
      mainImage: mainImageUrl,
      galleryImages: galleryImagesList,
      content: finalContent,
      link: link,
    );
  }
}