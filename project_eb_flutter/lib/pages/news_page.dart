// lib/pages/news_page.dart
import 'package:flutter/material.dart';
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: const Center(child: Text('News Page')),
    );
  }
}
