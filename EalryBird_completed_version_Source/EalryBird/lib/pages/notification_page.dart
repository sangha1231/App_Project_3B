import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// 글래스모피즘 커스텀 다이얼로그
Future<void> showGlassDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = '취소',
  String confirmText = '확인',
  VoidCallback? onConfirm,
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
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(content,
                    style:
                    const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child:
                      Text(cancelText, style: const TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm?.call();
                      },
                      child: Text(confirmText,
                          style: const TextStyle(color: Colors.red)),
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

/// 알림 관리 페이지
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NoteItem> _allNotes = [];
  List<int> _notifIndices = [];

  final _auth = FirebaseAuth.instance;
  late final DatabaseReference _notesRef;
  late final DatabaseReference _notifRef;

  @override
  void initState() {
    super.initState();
    _notesRef = FirebaseDatabase.instance.ref().child('notes');
    _notifRef = FirebaseDatabase.instance.ref().child('note_notifications');
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = _auth.currentUser;
    List<NoteItem> loadedNotes = [];
    List<int> loadedIndices = [];

    if (user != null) {
      // 메모 불러오기
      final notesSnap = await _notesRef.child(user.uid).get();
      if (notesSnap.exists) {
        final raw = notesSnap.value;
        if (raw is List) {
          for (var e in raw) {
            if (e is Map) loadedNotes.add(NoteItem.fromJson(Map<String, dynamic>.from(e)));
          }
        } else if (raw is Map) {
          raw.values.forEach((v) {
            if (v is Map) loadedNotes.add(NoteItem.fromJson(Map<String, dynamic>.from(v)));
          });
        }
      }
      // 알림 인덱스 불러오기
      final notifSnap = await _notifRef.child(user.uid).get();
      if (notifSnap.exists) {
        final rawN = notifSnap.value;
        if (rawN is List) {
          for (var i in rawN) {
            final idx = int.tryParse(i.toString());
            if (idx != null) loadedIndices.add(idx);
          }
        } else if (rawN is Map) {
          rawN.values.forEach((v) {
            final idx = int.tryParse(v.toString());
            if (idx != null) loadedIndices.add(idx);
          });
        }
      }
    }

    // 유효 범위 필터링
    final validNotes = loadedNotes;
    final validIndices =
    loadedIndices.where((i) => i >= 0 && i < validNotes.length).toList();

    setState(() {
      _allNotes = validNotes;
      _notifIndices = validIndices;
    });
  }

  Future<void> _deleteNotification(int listIndex) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final targetIdx = _notifIndices[listIndex];
    await showGlassDialog(
      context: context,
      title: '정말 즐겨찾기를 삭제하시겠습니까?',
      content: _allNotes[targetIdx].text,
      confirmText: '삭제',
      onConfirm: () async {
        final snap = await _notifRef.child(user.uid).get();
        List<String> current = [];
        if (snap.exists) {
          final raw = snap.value;
          if (raw is List) current = raw.map((e) => e.toString()).toList();
          else if (raw is Map) raw.values.forEach((v) => current.add(v.toString()));
        }
        current.remove(targetIdx.toString());
        await _notifRef.child(user.uid).set(current);
        await _loadNotifications();
      },
    );
  }

  Future<void> _clearAllNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await showGlassDialog(
      context: context,
      title: '모든 즐겨찾기 삭제',
      content: '저장된 모든 즐겨찾기를 삭제하시겠습니까?',
      confirmText: '삭제',
      onConfirm: () async {
        await _notifRef.child(user.uid).remove();
        setState(() => _notifIndices.clear());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = 60.0;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final user = _auth.currentUser;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover)),
        SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: user == null
                  ? const Text(
                '즐겨찾기 기능은 로그인 후에만 이용 가능합니다.',
                style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 16),
                textAlign: TextAlign.center,
              )
                  : Column(
                children: [
                  const Text(
                    '메모장 즐겨찾기 관리',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _notifIndices.isEmpty
                        ? const Center(child: Text('등록된 알림이 없습니다.'))
                        : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _notifIndices.length,
                      separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white24),
                      itemBuilder: (_, idx) {
                        final noteIdx = _notifIndices[idx];
                        final item = _allNotes[noteIdx];
                        return ListTile(
                          tileColor:
                          Colors.white.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            item.text,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                          subtitle: Text(
                            item.createdAt,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () =>
                                _deleteNotification(idx),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassButton(
                    onPressed: _notifIndices.isNotEmpty
                        ? _clearAllNotifications
                        : null,
                    child: const Text('모두 삭제',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
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
                    icon:
                    const Icon(Icons.home_outlined, size: 40, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  Container(
                      height: navHeight * 0.5,
                      width: 2,
                      color: Colors.white54),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        size: 40, color: Colors.white),
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

/// NoteItem 클래스: NotePage 쪽과 동일
class NoteItem {
  final String text;
  final String createdAt;

  NoteItem({required this.text, required this.createdAt});

  factory NoteItem.fromJson(Map<dynamic, dynamic> json) => NoteItem(
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '');

  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt,
  };
}
/// 글래스모피즘 버튼
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const GlassButton({
    Key? key,
    required this.onPressed,
    required this.child,
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
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
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
