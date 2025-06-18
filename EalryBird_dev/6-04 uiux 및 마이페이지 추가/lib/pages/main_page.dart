import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project_eb_flutter/pages/settings_page.dart';

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
    final screenWidth = mq.size.width;
    final bottomInset = mq.padding.bottom;
    const navHeight = 60.0;

    final horizontalPadding = screenWidth * 0.05;
    final widgetSpacing = horizontalPadding;
    final maxWidth = screenWidth - horizontalPadding * 2;
    final widgetSize = (maxWidth - widgetSpacing) / 2;
    final noteWidgetHeight = widgetSize * 1.8;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: widgetSpacing),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WeatherPage()),
                              ),
                              child: _GlassPanel(
                                width: widgetSize,
                                height: widgetSize,
                                child: const _WeatherContent(),
                              ),
                            ),
                            SizedBox(width: widgetSpacing),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NewsPage()),
                              ),
                              child: _GlassPanel(
                                width: widgetSize,
                                height: widgetSize,
                                child: const _NewsContent(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widgetSpacing),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TrafficPage()),
                              ),
                              child: _GlassPanel(
                                width: widgetSize,
                                height: widgetSize,
                                child: const _TrafficContent(),
                              ),
                            ),
                            SizedBox(width: widgetSpacing),
                            // 반응 버튼으로 변경된 + 위젯 (색상 일치)
                            _GlassPanel(
                              width: widgetSize,
                              height: widgetSize,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.add, size: 40, color: Color(0xFF616161)),
                                  splashRadius: 28,
                                  onPressed: () {
                                    // 임시 버튼 애니메이션 동작
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widgetSpacing * 1.2),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotePage()),
                          ),
                          child: _GlassPanel(
                            width: double.infinity,
                            height: noteWidgetHeight,
                            child: const _NoteContent(),
                          ),
                        ),
                        SizedBox(height: widgetSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    ),
                  ),
                  // 중앙 분리선
                  Container(
                    height: navHeight * 0.5,
                    width: 1,
                    color: Colors.white54,
                  ),
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.wb_sunny, size: 40, color: Colors.orangeAccent),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '22℃',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsContent extends StatelessWidget {
  const _NewsContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.article, size: 38, color: Colors.blueAccent),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '3 News',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrafficContent extends StatelessWidget {
  const _TrafficContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.train, size: 40, color: Colors.green),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '+5 min',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteContent extends StatelessWidget {
  const _NoteContent();

  @override
  Widget build(BuildContext context) {
    final notes = ['팀 회의 준비', '과제 제출 23:59', '선물 구매', '추가 일정 1', '추가 일정 2', '추가 일정 3'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.edit_note, size: 40, color: Colors.amber),
            TextButton.icon(
              onPressed: () {
                // 여기서 NotePage(노트 상세페이지)로 이동하도록 변경
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotePage()),
                );
              },
              icon: const Icon(Icons.add, size: 20, color: Colors.amber),
              label: const Text('Add Note', style: TextStyle(fontSize: 16, color: Colors.amber)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 1),
            itemBuilder: (context, idx) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  '• ${notes[idx]}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
