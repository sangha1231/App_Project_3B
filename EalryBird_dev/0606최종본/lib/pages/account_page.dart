// lib/pages/account_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_eb_flutter/pages/main_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final DatabaseReference _notifRef;
  bool _isProcessing = false;

  List<int> _notifiedIndices = [];
  List<String> _allNotes = [];

  @override
  void initState() {
    super.initState();
    _notifRef = FirebaseDatabase.instance
        .ref()
        .child('note_notifications')
        .child(_auth.currentUser?.uid ?? 'unknown');

    _loadNotifications();
    _loadAllNotes();
  }

  /// 저장된 메모를 SharedPreferences에서 불러옵니다.
  Future<void> _loadAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allNotes = prefs.getStringList('savedNotes') ?? [];
    });
  }

  /// Firebase에서 현재 사용자의 알림 인덱스를 불러옵니다.
  Future<void> _loadNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _notifiedIndices = [];
      });
      return;
    }
    final notifSnap = await _notifRef.get();
    if (!notifSnap.exists) {
      setState(() {
        _notifiedIndices = [];
      });
      return;
    }
    final raw = notifSnap.value;
    final temp = <int>[];
    if (raw is List<dynamic>) {
      for (var item in raw) {
        final idx = int.tryParse(item.toString());
        if (idx != null) temp.add(idx);
      }
    } else if (raw is Map<dynamic, dynamic>) {
      for (var entry in raw.values) {
        final idx = int.tryParse(entry.toString());
        if (idx != null) temp.add(idx);
      }
    }
    setState(() {
      _notifiedIndices = temp;
    });
  }

  /// 모든 알림을 해제합니다.
  Future<void> _clearAllNotifications() async {
    final user = _auth.currentUser;
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
      return;
    }
    await _notifRef.remove();
    setState(() {
      _notifiedIndices.clear();
    });
  }

  Future<void> _signOut() async {
    final user = _auth.currentUser;
    if (user == null) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("알림"),
          content: const Text("이미 로그아웃 상태입니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _auth.signOut();
      setState(() {
        _isProcessing = false;
      });

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("알림"),
          content: const Text("로그아웃 되었습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("오류"),
          content: Text("로그아웃 중 오류가 발생했습니다:\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("알림"),
          content: const Text("계정이 존재하지 않습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    try {
      await user.delete();
      setState(() {
        _isProcessing = false;
      });

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("알림"),
          content: const Text("계정이 탈퇴되었습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("탈퇴 실패"),
          content: Text("계정 탈퇴 중 오류가 발생했습니다:\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("정말 탈퇴하시겠습니까?"),
        content: const Text("탈퇴 시 모든 데이터가 영구 삭제됩니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAccount();
            },
            child: const Text("탈퇴", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final bottomInset = mq.padding.bottom;
    const navHeight = 60.0;
    final horizontalPadding = screenWidth * 0.05;
    final maxWidth = screenWidth - horizontalPadding * 2;

    final currentEmail = _auth.currentUser?.email != null
        ? _auth.currentUser!.email!.split('@')[0] + "님의 계정"
        : "GUEST";

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          // 콘텐츠 영역
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
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

                      const SizedBox(height: 24),

                      // 글래스 패널: 사용자 이메일 & 로그아웃·탈퇴·알림 관리 버튼
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Text(
                                      currentEmail,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A4A4A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // 로그아웃 버튼
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isProcessing ? null : _signOut,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isProcessing
                                          ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : const Text(
                                        '로그아웃',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),




                                  // 탈퇴 버튼
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isProcessing ? null : _showDeleteConfirmation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isProcessing
                                          ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : const Text(
                                        '탈퇴하기',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
