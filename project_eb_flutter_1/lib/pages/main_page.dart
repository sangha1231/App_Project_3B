// lib/pages/main_page.dart

import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq          = MediaQuery.of(context);
    final screenW     = mq.size.width;
    final bottomInset = mq.padding.bottom;
    const navHeight   = 60.0;
    const maxWidth    = 400.0;

    return Scaffold(
      // 바디가 네비 아래까지 확장, 배경 투명
      extendBody: true,
      backgroundColor: Colors.transparent,

      // 1) BODY: 배경 + 스크롤되는 콘텐츠
      body: Stack(
        children: [
          // 풀스크린 배경
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          // SafeArea 안에서 중앙 400px, 스크롤 가능
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 80),

                      // frame1 / frame2
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/weather'),
                            child: Image.asset(
                              'assets/images/frame1.png',
                              width: maxWidth * 0.35,
                              height: maxWidth * 0.35,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/news'),
                            child: Image.asset(
                              'assets/images/frame2.png',
                              width: maxWidth * 0.35,
                              height: maxWidth * 0.35,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // frame3 (AspectRatio)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/traffic'),
                        child: AspectRatio(
                          aspectRatio: 2.2 / 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/frame3.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // frame4 (AspectRatio)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/note'),
                        child: AspectRatio(
                          aspectRatio: 11 / 9,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/frame4.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 콘텐츠가 너무 짧으면 여유 추가
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 2) BOTTOM NAVIGATION BAR: 배경 + 버튼 두 개
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: Container(
          width: double.infinity,
          // bar background
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bottom.png'),
              fit: BoxFit.cover,
            ),
          ),
          // slight bottom padding then center the two icons
          padding: EdgeInsets.only(bottom: bottomInset + 4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MainPage
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: Image.asset(
                    'assets/images/bottom_mainpage.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
                const SizedBox(width: 8),
                // Settings
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
