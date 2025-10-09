// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  Future<List<NewsArticle>> fetchNews() async {
    final uri = Uri.parse('https://newsapi.org/v2/everything'
        '?q=한국'
        '&language=ko'
        '&pageSize=20'
        '&sortBy=publishedAt' 
        '&apiKey=a04097150b8c4eef8efd1cce571f1da6');

    final res =
        await http.get(uri).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('요청이 시간 초과되었습니다.');
    });

    if (res.statusCode != 200) {
      throw Exception('뉴스 로드 실패: ${res.statusCode}');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(res.body);
    final List<dynamic> articles = jsonBody['articles'] as List<dynamic>? ?? [];
    return articles
        .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
