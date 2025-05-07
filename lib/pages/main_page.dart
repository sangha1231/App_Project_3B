// lib/pages/main_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project_eb_flutter/pages/settings_page.dart';

// 상세 페이지 import
import 'weather_page.dart';
import 'news_page.dart';
import 'note_page.dart';
import 'settings_page.dart';
import 'traffic_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    const navHeight = 80.0;        // 네비 버튼 크기
    const maxWidth = 400.0;        // 중앙 최대 너비
    const smallPanelHeight = 150.0; // 작은 패널 높이
    const notePanelHeight = 300.0;  // 메모 패널 높이

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 전체 배경: sky.img
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          // 콘텐츠 영역
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 날씨 / 뉴스 / 교통
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 날씨
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WeatherPage()),
                            ),
                            child: _GlassPanel(
                              width: (maxWidth - 32) / 3,
                              height: smallPanelHeight,
                              child: const _WeatherContent(),
                            ),
                          ),

                          // 뉴스
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NewsPage()),
                            ),
                            child: _GlassPanel(
                              width: (maxWidth - 32) / 3,
                              height: smallPanelHeight,
                              child: const _NewsContent(),
                            ),
                          ),

                          // 교통
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TrafficPage()),
                            ),
                            child: _GlassPanel(
                              width: (maxWidth - 32) / 3,
                              height: smallPanelHeight,
                              child: const _TrafficContent(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 메모 (풀 너비, 크게)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotePage()),
                        ),
                        child: _GlassPanel(
                          width: maxWidth,
                          height: notePanelHeight,
                          child: const _NoteContent(),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 하단 네비게이션 바
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
                  // 홈 버튼
                  IconButton(
                    icon: const Icon(Icons.home_outlined, size: 40, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    ),
                  ),
                  // 설정 버튼
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 40, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
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

/// 글래스패널 공통 위젯
class _GlassPanel extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _GlassPanel({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 날씨 콘텐츠 (미니멀)
class _WeatherContent extends StatelessWidget {
  const _WeatherContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.wb_sunny, size: 36, color: Colors.orange),
        SizedBox(height: 8),
        Text('22℃', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
      ],
    );
  }
}

/// 뉴스 콘텐츠 (미니멀)
class _NewsContent extends StatelessWidget {
  const _NewsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.article, size: 32, color: Colors.blueAccent),
        SizedBox(height: 8),
        Text('3 Headlines', style: TextStyle(fontSize: 16, color: Color(0xFF4A4A4A))),
      ],
    );
  }
}

/// 교통 콘텐츠 (미니멀)
class _TrafficContent extends StatelessWidget {
  const _TrafficContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.train, size: 36, color: Colors.green),
        SizedBox(height: 8),
        Text('+5 min', style: TextStyle(fontSize: 18, color: Color(0xFF4A4A4A))),
      ],
    );
  }
}

/// 노트 콘텐츠 (미니멀)
class _NoteContent extends StatelessWidget {
  const _NoteContent();

  @override
  Widget build(BuildContext context) {
    final notes = ['팀 회의 준비', '과제 제출 23:59', '선물 구매'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: notes.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, idx) {
              if (idx < notes.length) {
                return Text('• ${notes[idx]}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)));
              }
              return TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18, color: Color(0xFF4A4A4A)),
                label: const Text('Add note', style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A))),
              );
            },
          ),
        ),
      ],
    );
  }
}
