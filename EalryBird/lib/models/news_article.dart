
class NewsArticle {
  final String sourceName;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;

  NewsArticle({
    required this.sourceName,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      sourceName: json['source']?['name'] ?? '',
      author: json['author'] as String?,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );
  }
}
