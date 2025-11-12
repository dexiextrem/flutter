// lib/models/article.dart (ΤΕΛΙΚΟ – ΕΝΙΣΧΥΜΕΝΟ ΓΙΑ <p><br> ΧΩΡΙΣ </p>)

import 'dart:developer' as devtools;

class Article {
  final String id;
  final String title;
  final String date;
  final String image;
  final String content;
  final String link;

  Article({
    required this.id,
    required this.title,
    required this.date,
    required this.image,
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
        // <p><br> χωρίς </p> – προσθέτουμε </p> και αφαιρούμε
        .replaceAll(RegExp(r'<p>\s*<br\s*/?>(?!\s*</p>)', caseSensitive: false), '<p></p>')
        .replaceAll(RegExp(r'<p>\s*<br\s*/?>\s*</p>', caseSensitive: false), '') // Τώρα κλεισμένες
        // <p></p> και <p> </p>
        .replaceAll(RegExp(r'<p>\s*</p>', caseSensitive: false), '')
        // <p>&nbsp;</p> και <p> </p>
        .replaceAll(RegExp(r'<p>\s*&nbsp;\s*</p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<p>\s* \s*</p>', caseSensitive: false), '')
        // Πολλαπλές κενές
        .replaceAll(RegExp(r'(<p>\s*</p>\s*)+', caseSensitive: false), '')
        // [TAGS]
        .replaceAll(RegExp(r'\[[^\]]+\]'), '')
        // Πολλαπλά κενά
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    final String finalContent = rawContent.isEmpty
        ? '<p>Δεν υπάρχει περιεχόμενο.</p>'
        : '<p>$rawContent</p>'; // Επαναφορά <p>

    final String formattedDate = json['indate']?.toString() ??
        json['publication_date']?.toString() ??
        json['date']?.toString() ??
        'Χωρίς ημερομηνία';

    final String imageUrl = json['image_url']?.toString() ?? json['image']?.toString() ?? '';

    return Article(
      id: finalId,
      title: json['title']?.toString() ?? 'Χωρίς τίτλο',
      date: formattedDate,
      image: imageUrl,
      content: finalContent,
      link: link,
    );
  }
}