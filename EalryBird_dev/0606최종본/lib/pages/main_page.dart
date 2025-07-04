// lib/pages/main_page.dart

import 'dart:io'; // exit(0) 사용을 위해 추가
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'weather_page.dart';
import 'news_page.dart';
import 'note_page.dart';        // NotePage 파일 경로에 맞게 수정
import 'settings_page.dart';
import 'bus_page.dart';
import 'bus_location_page.dart'; // BusLocationPage 파일 경로에 맞게 수정

/// NoteItem 클래스 (NotePage 쪽과 동일하게 유지)
class NoteItem {
  final String text;
  final String createdAt; // "yyyy-MM-dd HH:mm"

  NoteItem({required this.text, required this.createdAt});

  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt,
  };

  factory NoteItem.fromJson(Map<dynamic, dynamic> json) {
    return NoteItem(
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

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
                constraints: const BoxConstraints(maxWidth: 900),
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
                                MaterialPageRoute(builder: (_) => const BusPage()),
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
                                  icon: const Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Color(0xFF616161),
                                  ),
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

                        // ─── 기존 NoteWidget 대신 동적으로 메모 목록을 불러와 보여주는 위젯 ───
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotePage()),
                          ),
                          child: _GlassPanel(
                            width: double.infinity,
                            height: noteWidgetHeight,
                            child: const _SyncedNoteContent(),
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
                    icon:
                    const Icon(Icons.home_outlined, size: 40, color: Colors.white),
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
                  // 중앙 분리선
                  Container(
                    height: navHeight * 0.5,
                    width: 2,
                    color: Colors.white54,
                  ),
                  // 앱 종료 버튼 추가
                  IconButton(
                    icon: const Icon(Icons.exit_to_app, size: 40, color: Colors.redAccent),
                    onPressed: () {
                      // 종료 확인 다이얼로그 표시
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("앱 종료"),
                            content: const Text("앱을 종료하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(), // 취소
                                child: const Text("취소"),
                              ),
                              TextButton(
                                onPressed: () {
                                  exit(0); // 앱 완전 종료
                                },
                                child: const Text("종료"),
                              ),
                            ],
                          );
                        },
                      );
                    },
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

/// ─────────────────────────────────────────────────────────────────────────────
/// GlassPanel 재사용 컴포넌트
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

/// 날씨 위젯
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

/// 뉴스 위젯
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

/// 교통 위젯 (버스 검색 화면 이동)
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

/// ─────────────────────────────────────────────────────────────────────────────
/// “실제 NotePage 에 저장된 메모”를 불러와서 표시하는 위젯
class _SyncedNoteContent extends StatefulWidget {
  const _SyncedNoteContent();

  @override
  State<_SyncedNoteContent> createState() => _SyncedNoteContentState();
}

class _SyncedNoteContentState extends State<_SyncedNoteContent> {
  final _auth = FirebaseAuth.instance;
  late DatabaseReference _dbRef;
  final List<NoteItem> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref().child('notes');
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final user = _auth.currentUser;

    if (user != null) {
      // 로그인이 되어 있으면 Firebase 에서 읽어오기
      final notesSnap = await _dbRef.child(user.uid).get();
      final temp = <NoteItem>[];

      if (notesSnap.exists) {
        final rawNotes = notesSnap.value;
        if (rawNotes is List<dynamic>) {
          for (var e in rawNotes) {
            if (e is Map) {
              temp.add(NoteItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        } else if (rawNotes is Map<dynamic, dynamic>) {
          rawNotes.values.forEach((val) {
            if (val is Map) {
              temp.add(NoteItem.fromJson(Map<String, dynamic>.from(val)));
            }
          });
        }
      }

      setState(() {
        _notes
          ..clear()
          ..addAll(temp);
        _loading = false;
      });
    } else {
      // 로그인 안 되어 있으면 SharedPreferences 에서 읽어오기
      final prefs = await SharedPreferences.getInstance();
      final savedNotesJson = prefs.getStringList('savedNotesJson') ?? [];
      final temp = <NoteItem>[];

      for (var jsonStr in savedNotesJson) {
        try {
          final map = Map<String, dynamic>.from(json.decode(jsonStr));
          temp.add(NoteItem.fromJson(map));
        } catch (_) {}
      }

      setState(() {
        _notes
          ..clear()
          ..addAll(temp);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 메인 카드 높이 대비 내부 스크롤 없이 일부만 보여 주기 위해
    // 단순히 첫 3개 정도만 표시하도록 합니다. 더 많이 보여주고 싶으면 maxItems를 높여주세요.
    const int maxItems = 3;

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_notes.isEmpty) {
      return const Center(
        child: Text(
          '작성된 메모가 없습니다.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단에 “메모장” 타이틀 + 추가 아이콘
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.edit_note, size: 32, color: Colors.amber),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.amber),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotePage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 실제 메모 리스트 (최대 maxItems개만)
        ..._notes
            .take(maxItems)
            .map((note) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ${note.text}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                note.createdAt,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ))
            .toList(),

        // “더 보기” 가 필요하면...
        if (_notes.length > maxItems)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              '더보기...',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
