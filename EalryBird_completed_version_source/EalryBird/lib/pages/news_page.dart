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
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child:Column(
                  children: [
                    const SizedBox(height: 16),

                    // 뒤로 가기 버튼 + "최신 뉴스" 텍스트 (같은 높이, 중앙 정렬)
                    Row(
                      children: [
                        // 뒤로 가기 버튼 (왼쪽)
                        ClipOval(
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

                        // 중앙 정렬을 위한 Expanded
                        Expanded(
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

                        // 오른쪽 공간 확보 (뒤로 가기 버튼과 균형 맞추기)
                        SizedBox(width: 44),
                      ],
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
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$datePart $timePart',
                                        style: const TextStyle(color: Colors.black),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, size: 40, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  //중앙 분리선
                  Container(
                    height: navHeight * 0.5,
                    width: 2,
                    color: Colors.white54,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 40, color: Colors.white),
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
