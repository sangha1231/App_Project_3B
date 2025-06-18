import 'dart:ui';
import 'package:flutter/material.dart';
import 'settings_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) 배경: sky.png
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          // 2) 콘텐츠
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SettingsPage()),
                              );
                            },
                          ),

                          // 제목
                          const Expanded(
                            child: Center(
                              child: Text(
                                '마이페이지',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),

                          // 오른쪽 알림 아이콘
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                            onPressed: () {
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _GlassPanel(
                        width: double.infinity,
                        height: 140, // 높이 조정: 텍스트 아래 링크가 추가되면서 120 -> 140으로 변경
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1) 연한 빨간색 느낌표 아이콘 + "로그인해주세요"
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 24,
                                    color: Colors.redAccent, // 연한 빨간색
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '로그인해주세요',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // 2) "아이디 혹은 비밀번호를 잊어버리셨나요?" 링크 (텍스트 바로 아래 위치)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    // "아이디 혹은 비밀번호를 잊어버리셨나요?" 동작
                                  },
                                  child: const Text(
                                    '아이디 혹은 비밀번호를 잊어버리셨나요?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4A4A4A),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // 버튼 Row (로그인 / 회원가입)
                              Row(
                                children: [
                                  // 로그인 버튼
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                        side: const BorderSide(color: Colors.white70),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () {
                                        // 로그인 페이지로 이동
                                      },
                                      child: const Text(
                                        '로그인',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4A4A4A),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // 회원가입 버튼
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                        side: const BorderSide(color: Colors.white70),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () {
                                        // 회원가입 페이지로 이동
                                      },
                                      child: const Text(
                                        '회원가입',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4A4A4A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _GlassPanel(
                        width: double.infinity,
                        height: (7 * 60) + (6 * 2) + 32,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // 1) 고객센터
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.headset_mic_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '고객센터',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 2,
                                color: Colors.white54,
                                indent: 10,
                                endIndent: 10,
                              ),

                              // 2) 공지사항
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.announcement_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '공지사항',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 2,
                                color: Colors.white54,
                                indent: 10,
                                endIndent: 10,
                              ),

                              // 3) 개인정보 수집 및 이용
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.privacy_tip_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '개인정보 수집 및 이용',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 2,
                                color: Colors.white54,
                                indent: 10,
                                endIndent: 10,
                              ),

                              // 4) 서비스 이용 약관
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '서비스 이용 약관',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 2,
                                color: Colors.white54,
                                indent: 10,
                                endIndent: 10,
                              ),

                              // 5) 오픈소스 라이선스
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.code_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '오픈소스 라이선스',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 2,
                                color: Colors.white54,
                                indent: 10,
                                endIndent: 10,
                              ),

                              // 6) 실험실
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.science_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '실험실',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 2,
                                color: Colors.white54,
                                indent: 10,
                                endIndent: 10,
                              ),

                              // 7) 버전 정보
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.update_outlined,
                                      size: 28,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '버전 정보 b1.0.0',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '최신 버전입니다',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40), // 여유 공간
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 글래스모피즘 패널 (SettingsPage와 동일)
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