// lib/pages/news_page.dart

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

      // ─── BODY ───────────────────────────────────────
      body: Stack(
        children: [
          // 1) 풀스크린 배경
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          // 2) SafeArea → Center → 폭 제한 → Column(back + list)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // 뒤로가기 버튼
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/images/arrow_back.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),

                    // 3) 남은 공간을 리스트로 채우기
                    Expanded(
                      child: FutureBuilder<List<NewsArticle>>(
                        future: NewsService().fetchNews(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(child: Text('오류: ${snap.error}'));
                          }
                          final articles = snap.data!;
                          return ListView.separated(
                            padding: EdgeInsets.only(
                              top: 16,
                              bottom: navHeight + bottomInset + 16,
                            ),
                            itemCount: articles.length,
                            separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                            itemBuilder: (_, i) {
                              final a = articles[i];
                              Widget? leading;
                              if (a.imageUrl != null && a.imageUrl!.isNotEmpty) {
                                leading = Image.network(
                                  a.imageUrl!,
                                  width: 60,
                                  fit: BoxFit.cover,
                                );
                              }

                              // 날짜 + 시간 포맷
                              final dt = a.publishedAt;
                              final datePart = '${dt.year.toString().padLeft(4, '0')}-'
                                  '${dt.month.toString().padLeft(2, '0')}-'
                                  '${dt.day.toString().padLeft(2, '0')}';
                              final timePart = '${dt.hour.toString().padLeft(2, '0')}:'
                                  '${dt.minute.toString().padLeft(2, '0')}';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                leading: leading,
                                title: Text(
                                  a.title,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '$datePart $timePart',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                onTap: () {
                                  // 상세보기 로직
                                },
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
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bottom.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.only(bottom: bottomInset + 4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MainPage 버튼
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: Image.asset(
                    'assets/images/bottom_mainpage.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
                const SizedBox(width: 8),
                // Settings 버튼
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: Image.asset(
                    'assets/images/bottom_setting.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
