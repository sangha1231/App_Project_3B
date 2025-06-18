import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EarlyBird/pages/main_page.dart';

/// 글래스모피즘 커스텀 다이얼로그
Future<void> showGlassDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = '확인',
  VoidCallback? onConfirm,
  String cancelText = '취소',
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(cancelText, style: const TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onConfirm != null) onConfirm();
                      },
                      child: Text(confirmText, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// 글래스모피즘 버튼
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;

  const GlassButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed != null ? 1.0 : 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  Future<void> _loadAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allNotes = prefs.getStringList('savedNotes') ?? [];
    });
  }

  Future<void> _loadNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      _notifiedIndices = [];
      return;
    }
    final notifSnap = await _notifRef.get();
    if (!notifSnap.exists) {
      _notifiedIndices = [];
    } else {
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
      _notifiedIndices = temp;
    }
    setState(() {});
  }

  Future<void> _clearAllNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      await showGlassDialog(
        context: context,
        title: '알림',
        content: '로그인이 필요합니다.',
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
      await showGlassDialog(
        context: context,
        title: '알림',
        content: '이미 로그아웃 상태입니다.',
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await _auth.signOut();
      setState(() => _isProcessing = false);
      await showGlassDialog(
        context: context,
        title: '알림',
        content: '로그아웃 되었습니다.',
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      await showGlassDialog(
        context: context,
        title: '오류',
        content: '로그아웃 중 오류가 발생했습니다:\n\$e',
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      await showGlassDialog(
        context: context,
        title: '알림',
        content: '계정이 존재하지 않습니다.',
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await user.delete();
      setState(() => _isProcessing = false);
      await showGlassDialog(
        context: context,
        title: '알림',
        content: '계정이 탈퇴되었습니다.',
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      await showGlassDialog(
        context: context,
        title: '탈퇴 실패',
        content: '계정 탈퇴 중 오류가 발생했습니다:\n\$e',
      );
    }
  }

  void _showDeleteConfirmation() {
    showGlassDialog(
      context: context,
      title: '정말 탈퇴하시겠습니까?',
      content: '탈퇴 시 모든 데이터가 영구 삭제됩니다.',
      confirmText: '탈퇴',
      cancelText: '취소',
      onConfirm: _deleteAccount,
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
        ? _auth.currentUser!.email!.split('@')[0] + '님의 계정'
        : 'GUEST';

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
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                  GlassButton(
                                    onPressed: _isProcessing ? null : _signOut,
                                    child: _isProcessing
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text('로그아웃', style: TextStyle(color: Colors.black87, fontSize: 18)),
                                  ),
                                  const SizedBox(height: 16),
                                  GlassButton(
                                    onPressed: _isProcessing ? null : _showDeleteConfirmation,
                                    child: const Text('탈퇴하기', style: TextStyle(color: Colors.redAccent, fontSize: 18)),
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