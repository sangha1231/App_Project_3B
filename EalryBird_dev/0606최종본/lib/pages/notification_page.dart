// lib/pages/notification_page.dart

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// NoteItem 클래스 정의 (NotePage 쪽과 동일하게 유지)
class NoteItem {
  final String text;
  final String createdAt; // "yyyy-MM-dd HH:mm:ss" 형태

  NoteItem({
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt,
  };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NoteItem> _allNotes = []; // 현재 사용자에 저장된 전체 메모 리스트
  List<int> _notifIndices = []; // 알림이 등록된 메모의 인덱스 리스트

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
    List<int> loadedIndices = [];
    List<NoteItem> loadedNotes = [];

    if (user != null) {
      // ===== 로그인된 사용자는 Firebase에서 메모와 알림 인덱스를 모두 불러온다 =====

      // 1) Firebase에서 메모 리스트 가져오기
      final notesSnap = await _notesRef.child(user.uid).get();
      if (notesSnap.exists) {
        final rawNotes = notesSnap.value;
        if (rawNotes is List) {
          for (var e in rawNotes) {
            if (e is Map) {
              loadedNotes.add(NoteItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        } else if (rawNotes is Map) {
          rawNotes.values.forEach((val) {
            if (val is Map) {
              loadedNotes.add(NoteItem.fromJson(Map<String, dynamic>.from(val)));
            }
          });
        }
      }

      // 2) Firebase에서 알림 인덱스 리스트 가져오기
      final notifSnap = await _notifRef.child(user.uid).get();
      if (notifSnap.exists) {
        final rawNotifs = notifSnap.value;
        if (rawNotifs is List) {
          for (var idxVal in rawNotifs) {
            final idx = int.tryParse(idxVal.toString());
            if (idx != null) loadedIndices.add(idx);
          }
        } else if (rawNotifs is Map) {
          rawNotifs.values.forEach((val) {
            final idx = int.tryParse(val.toString());
            if (idx != null) loadedIndices.add(idx);
          });
        }
      }
    } else {
      // ===== 비로그인 상태라면, 알림 기능을 사용 불가하므로 비워둠 =====
      loadedNotes = [];
      loadedIndices = [];
    }

    // 인덱스가 메모 개수를 벗어나지 않도록 필터
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
    if (user == null) return; // 비로그인 상태면 아무것도 하지 않음

    final targetIdx = _notifIndices[listIndex];
    final targetStr = targetIdx.toString();

    // ===== Firebase에서 알림 인덱스 리스트를 가져와서 해당 요소 제거 후 업데이트 =====
    final notifSnap = await _notifRef.child(user.uid).get();
    if (notifSnap.exists) {
      final rawNotifs = notifSnap.value;
      List<String> currentList = [];

      if (rawNotifs is List) {
        for (var idxVal in rawNotifs) {
          currentList.add(idxVal.toString());
        }
      } else if (rawNotifs is Map) {
        rawNotifs.values.forEach((val) {
          currentList.add(val.toString());
        });
      }

      // 실제 목록에서 targetStr 제거
      currentList.removeWhere((str) => str == targetStr);

      // Firebase에 업데이트
      await _notifRef.child(user.uid).set(currentList);
    }

    // 삭제 후 새로 고침
    await _loadNotifications();
  }

  Future<void> _clearAllNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return; // 비로그인 상태면 아무것도 하지 않음

    // ===== Firebase에서 노드 자체를 삭제 =====
    await _notifRef.child(user.uid).remove();

    setState(() {
      _notifIndices.clear();
    });
  }

  void _showClearAllDialog() {
    final user = _auth.currentUser;
    if (user == null) {
      // 비로그인 상태에서는 팝업 없이 바로 토스트나 다이얼로그로 안내해도 좋습니다.
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('알림 기능 사용 불가'),
          content: const Text('알림 기능은 로그인 후에만 사용 가능합니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

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
              height: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '모든 알림을 삭제하시겠습니까?',
                    style: TextStyle(
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
                          Navigator.of(context).pop();
                          _clearAllNotifications();
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

  void _showDeleteConfirm(int listIndex) {
    final user = _auth.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('알림 기능 사용 불가'),
          content: const Text('알림 삭제는 로그인 후에만 가능합니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

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
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '정말 삭제하시겠습니까?',
                    style: TextStyle(
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
                          Navigator.of(context).pop();
                          _deleteNotification(listIndex);
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

  void _showEditDialog(int noteIdx) {
    final user = _auth.currentUser;
    if (user == null) {
      // 비로그인 시에는 편집 불가 안내
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('알림 기능 사용 불가'),
          content: const Text('알림 편집은 로그인 후에만 가능합니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final TextEditingController editController =
    TextEditingController(text: _allNotes[noteIdx].text);

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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                        onPressed: () async {
                          final newText = editController.text.trim();
                          if (newText.isNotEmpty) {
                            // Firebase에서 메모 리스트 받아오기
                            final notesSnap = await _notesRef.child(user.uid).get();
                            List<dynamic> updatedList = [];
                            if (notesSnap.exists) {
                              final rawNotes = notesSnap.value;
                              if (rawNotes is List) {
                                updatedList = List<dynamic>.from(rawNotes);
                              } else if (rawNotes is Map) {
                                updatedList = List<dynamic>.from(rawNotes.values);
                              }
                            }
                            // 해당 인덱스 수정
                            if (noteIdx >= 0 && noteIdx < updatedList.length) {
                              final original = updatedList[noteIdx];
                              if (original is Map) {
                                original['text'] = newText;
                              }
                            }
                            // 다시 저장
                            await _notesRef.child(user.uid).set(updatedList);

                            await _loadNotifications();
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
  Widget build(BuildContext context) {
    final navHeight = 60.0;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final user = _auth.currentUser;

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
              child: user == null
              // 로그인되지 않은 경우
                  ? Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Text(
                  '알림 기능은 로그인 후에만 이용 가능합니다.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4A4A4A),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              // 로그인된 경우
                  : Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      '알림 관리',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
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
                        itemBuilder: (_, listIdx) {
                          final noteIdx = _notifIndices[listIdx];
                          final noteItem = _allNotes[noteIdx];
                          return Container(
                            margin:
                            const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              // 1) 내용(text)을 Title로: 폰트 크기 16
                              title: Text(
                                noteItem.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              // 2) 시간(createdAt)을 Subtitle로: 폰트 크기 12
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  noteItem.createdAt,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black54,
                                      size: 24,
                                    ),
                                    onPressed: () =>
                                        _showEditDialog(noteIdx),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 24,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirm(listIdx),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _showClearAllDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                      child: const Text(
                        '모두 삭제',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  Container(
                    height: navHeight * 0.5,
                    width: 2,
                    color: Colors.white54,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        size: 40, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
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
