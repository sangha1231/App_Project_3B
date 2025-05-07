// lib/pages/settings_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navHeight = 60.0;
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) 배경: sky.img
          Positioned.fill(
            child: Image.asset('assets/images/sky.img', fit: BoxFit.cover),
          ),

          // 2) 콘텐츠
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // back button (glass)
                      Align(
                        alignment: Alignment.topLeft,
                        child: ClipOval(
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
                      ),

                      const SizedBox(height: 24),

                      // title
                      Center(
                        child: Text(
                          'SETTING',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Search panel
                      GestureDetector(
                        onTap: () {
                          // 검색 기능으로 이동
                        },
                        child: _GlassPanel(
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: const [
                              Icon(Icons.search, size: 28, color: Color(0xFF4A4A4A)),
                              SizedBox(width: 16),
                              Text(
                                'Search settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Account panel
                      GestureDetector(
                        onTap: () {
                          // 계정 관리로 이동
                        },
                        child: _GlassPanel(
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: const [
                              Icon(Icons.person, size: 28, color: Color(0xFF4A4A4A)),
                              SizedBox(width: 16),
                              Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 200), // 여유 공간
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 3) 바텀 네비게이션 바 (glass)
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

/// 글래스모피즘 패널
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
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}