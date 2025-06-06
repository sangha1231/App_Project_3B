// lib/pages/settings_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'favorite_page.dart';
import 'login_page.dart';
import 'account_page.dart';
import 'my_page.dart';
import 'notification_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navHeight = 60.0;
    const maxWidth = 400.0;
    final auth = FirebaseAuth.instance;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) 배경: sky.png
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          // 2) SafeArea 내부에 Column을 두어 뒤로 가기 버튼을 최상단에 배치
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 뒤로 가기 버튼
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

                      const SizedBox(height: 16),

                      // ② 제목
                      Center(
                        child: Text(
                          '설정',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 정류소 즐겨찾기 패널
                      GestureDetector(
                        onTap: () async {
                          final user = auth.currentUser;
                          if (user == null) {
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("알림"),
                                content: const Text("로그인이 필요합니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("확인"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FavoritePage()),
                            );
                          }
                        },
                        child: _GlassPanel(
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: const [
                              Icon(Icons.star_border, size: 28, color: Color(0xFF4A4A4A)),
                              SizedBox(width: 16),
                              Text(
                                '정류소 즐겨찾기',
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

                      // 알림 관리 패널
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationPage()),
                          );
                        },
                        child: _GlassPanel(
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: const [
                              Icon(Icons.notifications, size: 28, color: Color(0xFF4A4A4A)),
                              SizedBox(width: 16),
                              Text(
                                '알림 관리',
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

                      // ④ Account 패널
                      GestureDetector(
                        onTap: () async {
                          final user = auth.currentUser;
                          if (user == null) {
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("알림"),
                                content: const Text("로그인을 해주세요."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginPage()),
                                      );
                                    },
                                    child: const Text("확인"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AccountPage()),
                            );
                          }
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

                      const SizedBox(height: 24),

                      // ⑤ Login 패널
                      GestureDetector(
                        onTap: () async {
                          final user = auth.currentUser;
                          if (user != null) {
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("알림"),
                                content: const Text("이미 로그인된 상태입니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("확인"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          }
                        },
                        child: _GlassPanel(
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: const [
                              Icon(Icons.login, size: 28, color: Color(0xFF4A4A4A)),
                              SizedBox(width: 16),
                              Text(
                                'Login',
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
                  // 중앙 분리선
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
