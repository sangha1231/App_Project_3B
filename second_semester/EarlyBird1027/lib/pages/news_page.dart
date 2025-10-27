import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';

import 'package:provider/provider.dart';
import '../wallpaper_provider.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = context.watch<WallpaperProvider>();

    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(wallpaperProvider.currentWallpaper, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: 44,
                              height: 44,
                              color: Colors.white.withOpacity(0.2),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Center(
                            child: Text(
                              "최신 뉴스",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 44),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 뉴스 리스트
                    Expanded(
                      child: FutureBuilder<List<NewsArticle>>(
                        future: NewsService().fetchNews(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(child: Text('오류: ${snap.error}', style: const TextStyle(color: Colors.white)));
                          }
                          final articles = snap.data!;

                          return ListView.separated(
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: 16 + bottomInset,
                            ),
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemCount: articles.length,
                            itemBuilder: (_, i) {
                              final a = articles[i];
                              final dt = a.publishedAt;
                              final datePart = '${dt.year.toString().padLeft(4, '0')}-'
                                  '${dt.month.toString().padLeft(2, '0')}-'
                                  '${dt.day.toString().padLeft(2, '0')}';
                              final timePart = '${dt.hour.toString().padLeft(2, '0')}:'
                                  '${dt.minute.toString().padLeft(2, '0')}';

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    color: Colors.grey.withOpacity(0.1),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: a.imageUrl != null && a.imageUrl!.isNotEmpty
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(a.imageUrl!, width: 60, fit: BoxFit.cover),
                                      )
                                          : null,
                                      title: Text(
                                        a.title,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$datePart $timePart',
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      onTap: () {
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}