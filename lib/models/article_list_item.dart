// lib/models/article_list_item.dart (ΜΟΝΟ ΓΙΑ ΛΙΣΤΑ)
class ArticleListItem {
  final String id;
  final String title;
  final String date;
  final String? imageUrl;

  ArticleListItem({
    required this.id,
    required this.title,
    required this.date,
    this.imageUrl,
  });

  factory ArticleListItem.fromJson(Map<String, dynamic> json) {
    return ArticleListItem(
      id: json['id']?.toString() ?? '0',
      title: json['title']?.toString() ?? 'Χωρίς τίτλο',
      date: json['indate']?.toString() ?? 'Χωρίς ημερομηνία',
      imageUrl: json['image_url']?.toString(),
    );
  }
}