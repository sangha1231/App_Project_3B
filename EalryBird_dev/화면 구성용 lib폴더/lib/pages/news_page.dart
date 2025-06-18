// lib/pages/news_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq          = MediaQuery.of(context);
    final screenW     = mq.size.width;
    final bottomInset = mq.padding.bottom;
    const navHeight   = 60.0;
    const maxWidth    = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          // 1) 배경 이미지 (sky.img)
          Positioned.fill(
            child: Image.asset('assets/images/sky.img', fit: BoxFit.cover),
          ),

          // 2) SafeArea → Center → 폭 제한
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 3) 뒤로 가기 버튼 (glass)
                    Align(
                      alignment: Alignment.topLeft,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: 44, height: 44,
                            color: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 4) 뉴스 리스트
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
                              bottom: navHeight + bottomInset + 16,
                            ),
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemCount: articles.length,
                            itemBuilder: (_, i) {
                              final a = articles[i];
                              // 날짜 + 시간 포맷
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
                                    color: Colors.white.withOpacity(0.2),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$datePart $timePart',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      onTap: () {
                                        // 상세보기 로직
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

      // ─── BOTTOM NAVIGATION BAR ───────────────────────
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.2),
              padding: EdgeInsets.only(bottom: bottomInset + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, size: 32, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 32, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
