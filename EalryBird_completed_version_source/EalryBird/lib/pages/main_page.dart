import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';

import 'weather_page.dart';
import 'news_page.dart';
import 'note_page.dart';
import 'settings_page.dart';
import 'bus_page.dart';
import 'bus_location_page.dart'; 


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
                                MaterialPageRoute(
                                    builder: (_) => const WeatherPage()),
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
                                MaterialPageRoute(
                                    builder: (_) => const NewsPage()),
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
                                MaterialPageRoute(
                                    builder: (_) => const BusPage()),
                              ),
                              child: _GlassPanel(
                                width: widgetSize,
                                height: widgetSize,
                                child: const _TrafficContent(),
                              ),
                            ),
                            SizedBox(width: widgetSpacing),

                            // 반응 버튼으로 변경된 + 위젯 (색상 일치)
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const HomeScreen()), 
                              ),
                              child: _GlassPanel(
                                width: widgetSize,
                                height: widgetSize,
                                child: const _CalendarContent(),
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
                    icon: const Icon(Icons.home_outlined,
                        size: 40, color: Colors.white),
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
                    icon: const Icon(Icons.settings_outlined,
                        size: 40, color: Colors.white),
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
                    icon: const Icon(Icons.exit_to_app,
                        size: 40, color: Colors.redAccent),
                    onPressed: () {
                      // 종료 확인 다이얼로그 표시
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.25),
                                        width: 1),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "앱 종료",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "앱을 종료하시겠습니까?",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black54,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              backgroundColor:
                                                  Colors.white.withOpacity(0.3),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("취소"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              exit(0);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.redAccent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              backgroundColor:
                                                  Colors.white.withOpacity(0.3),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("종료"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
              '날씨정보',
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
              '뉴스정보',
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
              '버스 도착 정보',
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

/// 캘린더 위젯
class _CalendarContent extends StatelessWidget {
  const _CalendarContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.calendar_month, size: 40, color: Colors.deepPurple),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '일정관리',
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
    const int maxItems = 3;

    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (_notes.isEmpty) {
      return const Center(
        child: Text(
          '메모하시려면 여기를 눌러주세요',
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
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        note.createdAt,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
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
