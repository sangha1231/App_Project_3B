import 'news_article.dart';

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> arr = json['articles'] as List<dynamic>;
    return NewsResponse(
      status: json['status'] as String,
      totalResults: json['totalResults'] as int,
      articles: arr.map((e) => NewsArticle.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
