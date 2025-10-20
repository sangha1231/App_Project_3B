// lib/pages/note_page.dart

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Provider 패키지 import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../wallpaper_provider.dart'; // 2. WallpaperProvider import

// 메모 항목 데이터 모델
class NoteItem {
  final String text;
  final String createdAt;

  NoteItem({
    required this.text,
    required this.createdAt,
  });

  // 객체를 JSON 형태로 변환
  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt,
  };

  // JSON Map에서 객체 생성 (Firebase/SharedPreferences 데이터 로딩용)
  factory NoteItem.fromJson(Map<dynamic, dynamic> json) {
    return NoteItem(
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  // 상태 관리 변수들
  final List<NoteItem> _notes = []; // 전체 메모 목록
  final Set<int> _selectedNotes = {}; // 선택된 메모의 인덱스 집합 (다중 삭제용)
  final Set<int> _notifiedNotes = {}; // 알림 설정된 메모의 인덱스 집합
  final TextEditingController _controller = TextEditingController(); // 새 메모 입력 컨트롤러

  final _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  late final DatabaseReference _dbRef; // Firebase Realtime Database 메모 레퍼런스
  late final DatabaseReference _notifRef; // Firebase Realtime Database 알림 레퍼런스

  @override
  void initState() {
    super.initState();
    // Firebase 레퍼런스 초기화
    _dbRef = FirebaseDatabase.instance.ref().child('notes');
    _notifRef = FirebaseDatabase.instance.ref().child('note_notifications');
    _loadAllData(); // 앱 시작 시 데이터 로드
  }

  // SharedPreferences 또는 Firebase에서 메모 및 알림 정보 로드
  Future<void> _loadAllData() async {
    final user = _auth.currentUser;

    _notes.clear();
    _notifiedNotes.clear();

    if (user != null) {
      // 1. Firebase 로그인 상태: Firebase에서 데이터 로드

      // 메모 로드
      final notesSnap = await _dbRef.child(user.uid).get();
      if (notesSnap.exists) {
        final rawNotes = notesSnap.value;
        if (rawNotes is List) {
          // 리스트 형태로 저장된 경우 처리
          for (var e in rawNotes) {
            if (e is Map) {
              _notes.add(NoteItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        } else if (rawNotes is Map) {
          // 맵 형태로 저장된 경우 처리
          rawNotes.values.forEach((val) {
            if (val is Map) {
              _notes.add(NoteItem.fromJson(Map<String, dynamic>.from(val)));
            }
          });
        }
      }

      // 알림 정보 로드 (메모의 인덱스 저장)
      final notifSnap = await _notifRef.child(user.uid).get();
      if (notifSnap.exists) {
        final rawNotifs = notifSnap.value;
        if (rawNotifs is List) {
          for (var idx in rawNotifs) {
            final i = int.tryParse(idx.toString());
            if (i != null && i < _notes.length) _notifiedNotes.add(i);
          }
        } else if (rawNotifs is Map) {
          rawNotifs.values.forEach((val) {
            final i = int.tryParse(val.toString());
            if (i != null && i < _notes.length) _notifiedNotes.add(i);
          });
        }
      }
    } else {
      // 2. 비로그인 상태: SharedPreferences에서 데이터 로드
      final prefs = await SharedPreferences.getInstance();

      // 메모 로드 (JSON 문자열 리스트로 저장됨)
      final savedNotesJson = prefs.getStringList('savedNotesJson') ?? [];
      for (var jsonStr in savedNotesJson) {
        try {
          final map = Map<String, dynamic>.from(json.decode(jsonStr));
          _notes.add(NoteItem.fromJson(map));
        } catch (_) {}
      }

      // 알림 정보 로드 (문자열 리스트로 저장됨)
      final savedNotifs = prefs.getStringList('notifiedNotes') ?? [];
      for (var str in savedNotifs) {
        final i = int.tryParse(str);
        if (i != null && i < _notes.length) _notifiedNotes.add(i);
      }
    }

    setState(() {}); // 데이터 로드 후 UI 업데이트
  }

  // 메모 목록을 SharedPreferences 또는 Firebase에 저장
  Future<void> _saveNotes() async {
    final user = _auth.currentUser;
    final asJsonList = _notes.map((item) => json.encode(item.toJson())).toList();

    if (user != null) {
      // Firebase에 저장
      final payload = <dynamic>[];
      for (var item in _notes) {
        payload.add(item.toJson());
      }
      await _dbRef.child(user.uid).set(payload);
    } else {
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('savedNotesJson', asJsonList);
    }
  }

  // 알림 상태를 SharedPreferences 또는 Firebase에 저장
  Future<void> _saveNotifications() async {
    final user = _auth.currentUser;
    // Set<int>을 List<String>으로 변환
    final List<String> asStrings = _notifiedNotes.map((i) => i.toString()).toList();

    if (user != null) {
      // Firebase에 저장
      await _notifRef.child(user.uid).set(asStrings);
    } else {
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('notifiedNotes', asStrings);
    }
  }

  // 새 메모 추가
  void _addNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // 내용 없으면 리턴

    // 현재 시간을 'yyyy-MM-dd HH:mm:ss' 형식으로 포맷
    DateTime now = DateTime.now().subtract(const Duration(hours: 3)); // 시간 조정 (예시)
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    setState(() {
      _notes.add(NoteItem(text: text, createdAt: formatted));
      _controller.clear();
    });
    _saveNotes();
    _saveNotifications(); // 메모 추가 시 알림 상태도 저장 (변경된 인덱스는 없지만 습관적으로 호출)
  }

  // 유리를 배경으로 하는 커스텀 확인/취소 다이얼로그
  void _showGlassDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2), // 어두운 배경
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // 블러 효과
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25), // 반투명 배경
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, // 다이얼로그 제목
                    style: const TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('취소', style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          onConfirm(); // 확인(삭제) 액션 실행
                          _saveNotes();
                          _saveNotifications();
                          Navigator.of(context).pop();
                        },
                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
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

  // 개별 메모 삭제
  void _deleteNote(int index) {
    _showGlassDialog(
      title: '정말 삭제하시겠습니까?',
      onConfirm: () {
        setState(() {
          _notes.removeAt(index);
          _selectedNotes.remove(index); // 선택 상태 해제
          _notifiedNotes.remove(index); // 알림 상태 해제

          // 메모 삭제 시, 뒤의 메모들의 인덱스가 당겨지므로 알림 인덱스 업데이트
          final updatedNotifs = <int>{};
          for (var i in _notifiedNotes) {
            if (i > index) {
              updatedNotifs.add(i - 1); // 삭제된 인덱스보다 크면 1 감소
            } else {
              updatedNotifs.add(i); // 삭제된 인덱스보다 작으면 그대로
            }
          }
          _notifiedNotes
            ..clear()
            ..addAll(updatedNotifs);
        });
      },
    );
  }

  // 모든 메모 삭제
  void _deleteAllNotes() {
    _showGlassDialog(
      title: '모든 메모를 삭제하시겠습니까?',
      onConfirm: () {
        setState(() {
          _notes.clear();
          _selectedNotes.clear();
          _notifiedNotes.clear();
        });
      },
    );
  }

  // 선택된 메모들 삭제
  void _deleteSelectedNotes() {
    _showGlassDialog(
      title: '선택한 메모를 삭제하시겠습니까?',
      onConfirm: () {
        setState(() {
          // 인덱스가 큰 순서대로 삭제해야 인덱스 오류가 발생하지 않음
          final selectedList = _selectedNotes.toList()..sort((a, b) => b.compareTo(a));
          for (var idx in selectedList) {
            _notes.removeAt(idx);
            _notifiedNotes.remove(idx);
          }
          _selectedNotes.clear();

          // 다중 삭제 시 알림 인덱스 업데이트
          final updatedNotifs = <int>{};
          for (var i in _notifiedNotes) {
            // 현재 알림 인덱스보다 작은 삭제된 인덱스의 개수만큼 shift 값 계산
            int shift = selectedList.where((delIdx) => delIdx < i).length;
            updatedNotifs.add(i - shift);
          }
          _notifiedNotes
            ..clear()
            ..addAll(updatedNotifs);
        });
      },
    );
  }

  // 알림 상태 토글
  void _toggleNotification(int index) {
    setState(() {
      if (_notifiedNotes.contains(index)) {
        _notifiedNotes.remove(index);
      } else {
        _notifiedNotes.add(index);
      }
    });
    _saveNotifications();
  }

  // 메모 수정 다이얼로그 표시
  void _showEditDialog(int index) {
    final TextEditingController editController =
    TextEditingController(text: _notes[index].text);

    showDialog(
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
                children: [
                  TextField(
                    controller: editController,
                    decoration: InputDecoration(
                      hintText: '메모 수정',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      // OutlineInputBorder로 모서리 둥글게
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    style: const TextStyle(color: Colors.black87),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소', style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          final newText = editController.text.trim();
                          if (newText.isNotEmpty) {
                            setState(() {
                              final oldItem = _notes[index];
                              // 기존 생성 시간 유지
                              _notes[index] = NoteItem(
                                text: newText,
                                createdAt: oldItem.createdAt,
                              );
                            });
                            _saveNotes();
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('저장', style: TextStyle(color: Colors.blue)),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🚩 3. Provider 인스턴스 가져오기 (배경화면 동기화의 핵심)
    final wallpaperProvider = context.watch<WallpaperProvider>();

    final navHeight = 60.0;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🚩 4. Provider를 사용해 동적 배경화면 설정
          Positioned.fill(
            child: Image.asset(
              // WallpaperProvider의 currentWallpaper 경로 사용
              wallpaperProvider.currentWallpaper,
              fit: BoxFit.cover,
            ),
          ),
          // 뒤로 가기 버튼
          Positioned(
            top: topInset + 16,
            left: 16,
            child: _BackButton(),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: navHeight + bottomInset - 60),
              // 메인 글래스 패널
              child: _GlassPanel(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      '메모장',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // GlassInputField
                    GlassInputField(
                      controller: _controller,
                      hintText: '새 메모 입력',
                      onAdd: _addNote, // '추가' 버튼의 동작을 전달
                    ),

                    const SizedBox(height: 16),
                    // 전체 삭제 및 선택 삭제 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                      children: [
                        GlassButton(
                          onPressed: _deleteAllNotes,
                          width: 100,
                          height: 40,
                          child: const Text(
                            '전체 삭제',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassButton(
                          // 선택된 메모가 있을 때만 활성화
                          onPressed:
                          _selectedNotes.isNotEmpty ? _deleteSelectedNotes : null,
                          width: 100,
                          height: 40,
                          child: Text(
                            '선택 삭제',
                            style: TextStyle(
                              color: _selectedNotes.isNotEmpty
                                  ? Colors.black87
                                  : Colors.black45,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 메모 목록
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedNotes.contains(index);
                          final isNotified = _notifiedNotes.contains(index);

                          return GestureDetector(
                            // 길게 누르면 선택/선택 해제 (다중 선택)
                            onLongPress: () {
                              setState(() {
                                if (isSelected)
                                  _selectedNotes.remove(index);
                                else
                                  _selectedNotes.add(index);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                // 선택된 경우 배경색 변경
                                color: Colors.white.withOpacity(isSelected ? 0.35 : 0.2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 메모 내용
                                        Text(
                                          _notes[index].text,
                                          style: const TextStyle(color: Colors.black87),
                                        ),
                                        const SizedBox(height: 4),
                                        // 생성 시간
                                        Text(
                                          _notes[index].createdAt,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 알림 토글 버튼
                                  IconButton(
                                    icon: Icon(
                                      isNotified
                                          ? Icons.notifications_active
                                          : Icons.notifications_none,
                                      color:
                                      isNotified ? Colors.orangeAccent : Colors.black45,
                                    ),
                                    onPressed: () => _toggleNotification(index),
                                  ),
                                  // 수정 버튼
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.black54),
                                    onPressed: () => _showEditDialog(index),
                                  ),
                                  // 삭제 버튼
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.black45),
                                    onPressed: () => _deleteNote(index),
                                  ),
                                ],
                              ),
                            ),
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
      // 하단 네비게이션 바 (글래스모피즘 효과)
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
                  Container( // 구분선
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

// 🚩 수정된 GlassInputField 위젯: 텍스트 필드와 '추가' 버튼을 내부에 포함
class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onAdd; // 추가 버튼 클릭 이벤트를 받습니다.

  const GlassInputField({
    required this.controller,
    required this.hintText,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 48, // 입력 필드 높이 고정
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.only(left: 16), // 텍스트 필드 시작 위치 조정
          child: Row( // Row를 사용하여 텍스트 필드와 버튼을 가로로 배치
            children: [
              Expanded( // 텍스트 필드가 버튼을 제외한 남은 공간을 차지
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 TextField의 border 제거
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  onSubmitted: (_) => onAdd(), // 엔터 키를 눌러도 메모 추가
                ),
              ),

              // '추가' 버튼 (GlassButton 재사용)
              Padding(
                padding: const EdgeInsets.all(4.0), // 컨테이너 안에서 버튼 크기를 줄여 여백 확보
                child: GlassButton(
                  onPressed: onAdd,
                  width: 60,
                  height: 40, // Container 높이(48)보다 작게 설정하여 여백 확보
                  child: const Text(
                    '추가',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 뒤로 가기 버튼 위젯 (글래스모피즘)
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 40,
          height: 40,
          color: Colors.white.withOpacity(0.2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}

// 글래스모피즘 효과를 적용한 컨테이너 패널
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
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// 글래스모피즘 효과를 적용한 버튼
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;

  const GlassButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width = 100,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5, // 비활성화 시 투명도 조절
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
            child: Material( // InkWell 효과를 주기 위해 Material 위젯 사용
              type: MaterialType.transparency,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                onTap: onPressed,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}