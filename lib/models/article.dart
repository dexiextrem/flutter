// lib/models/article.dart (ΔΙΟΡΘΩΜΕΝΟ)

class Article {
  final String id;
  final String title;
  final String date;        // ΑΚΡΙΒΩΣ ΌΠΩΣ ΤΟ API: 30-10-2025
  final String image;
  final String content;

  Article({
    required this.id,
    required this.title,
    required this.date,
    required this.image,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // ΤΟ API ΔΙΝΕΙ ΗΔΗ ΕΛΛΗΝΙΚΗ ΜΟΡΦΗ: "30-10-2025"
    String formattedDate = json['publication_date']?.toString() ?? json['date']?.toString() ?? 'Χωρίς ημερομηνία';

    return Article(
      id: json['id'].toString(),
      title: json['title'] ?? 'Χωρίς τίτλο',
      date: formattedDate,
      image: json['image_url'] ?? json['image'] ?? '', // και image_url αν χρειάζεται
      content: json['content'] ?? '',
    );
  }
}