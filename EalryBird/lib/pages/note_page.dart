// lib/pages/note_page.dart

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';


class NoteItem {
  final String text;
  final String createdAt; 

  NoteItem({
    required this.text,
    required this.createdAt,
  });

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

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final List<NoteItem> _notes = [];
  final Set<int> _selectedNotes = {};
  final Set<int> _notifiedNotes = {};
  final TextEditingController _controller = TextEditingController();

  final _auth = FirebaseAuth.instance;
  late final DatabaseReference _dbRef;
  late final DatabaseReference _notifRef;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref().child('notes');
    _notifRef = FirebaseDatabase.instance.ref().child('note_notifications');
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final user = _auth.currentUser;

    _notes.clear();
    _notifiedNotes.clear();

    if (user != null) {

      final notesSnap = await _dbRef.child(user.uid).get();
      if (notesSnap.exists) {
        final rawNotes = notesSnap.value;
        if (rawNotes is List) {
          for (var e in rawNotes) {
            if (e is Map) {
              _notes.add(NoteItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        } else if (rawNotes is Map) {
          rawNotes.values.forEach((val) {
            if (val is Map) {
              _notes.add(NoteItem.fromJson(Map<String, dynamic>.from(val)));
            }
          });
        }
      }

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
      final prefs = await SharedPreferences.getInstance();

      final savedNotesJson = prefs.getStringList('savedNotesJson') ?? [];
      for (var jsonStr in savedNotesJson) {
        try {
          final map = Map<String, dynamic>.from(json.decode(jsonStr));
          _notes.add(NoteItem.fromJson(map));
        } catch (_) {}
      }

      final savedNotifs = prefs.getStringList('notifiedNotes') ?? [];
      for (var str in savedNotifs) {
        final i = int.tryParse(str);
        if (i != null && i < _notes.length) _notifiedNotes.add(i);
      }
    }

    setState(() {});
  }

  Future<void> _saveNotes() async {
    final user = _auth.currentUser;
    final asJsonList = _notes.map((item) => json.encode(item.toJson())).toList();

    if (user != null) {
      final payload = <dynamic>[];
      for (var item in _notes) {
        payload.add(item.toJson());
      }
      await _dbRef.child(user.uid).set(payload);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('savedNotesJson', asJsonList);
    }
  }

  Future<void> _saveNotifications() async {
    final user = _auth.currentUser;
    final List<String> asStrings = _notifiedNotes.map((i) => i.toString()).toList();

    if (user != null) {
      await _notifRef.child(user.uid).set(asStrings);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('notifiedNotes', asStrings);
    }
  }

  void _addNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    DateTime now = DateTime.now().subtract(const Duration(hours: 3));
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    setState(() {
      _notes.add(NoteItem(text: text, createdAt: formatted));
      _controller.clear();
    });
    _saveNotes();
    _saveNotifications();
  }

  void _showGlassDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
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
                  Text(
                    title,
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
                          onConfirm();
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

  void _deleteNote(int index) {
    _showGlassDialog(
      title: '정말 삭제하시겠습니까?',
      onConfirm: () {
        setState(() {
          _notes.removeAt(index);
          _selectedNotes.remove(index);
          _notifiedNotes.remove(index);

          final updatedNotifs = <int>{};
          for (var i in _notifiedNotes) {
            if (i > index) {
              updatedNotifs.add(i - 1);
            } else {
              updatedNotifs.add(i);
            }
          }
          _notifiedNotes
            ..clear()
            ..addAll(updatedNotifs);
        });
      },
    );
  }

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

  void _deleteSelectedNotes() {
    _showGlassDialog(
      title: '선택한 메모를 삭제하시겠습니까?',
      onConfirm: () {
        setState(() {
          final selectedList = _selectedNotes.toList()..sort((a, b) => b.compareTo(a));
          for (var idx in selectedList) {
            _notes.removeAt(idx);
            _notifiedNotes.remove(idx);
          }
          _selectedNotes.clear();

          final updatedNotifs = <int>{};
          for (var i in _notifiedNotes) {
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
                    controller: editController, decoration:
                  InputDecoration(
                  hintText: '메모 수정',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  // ─────── 여기를 OutlineInputBorder로 바꿔서 모서리를 둥글게 ───────
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
    final navHeight = 60.0;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: topInset + 16,
            left: 16,
            child: _BackButton(),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: navHeight + bottomInset - 60),
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
                    GlassInputField(
                      controller: _controller,
                      hintText: '새 메모 입력',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassButton(
                          onPressed: _addNote,
                          width: 80,
                          height: 40,
                          child: const Text(
                            '추가',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedNotes.contains(index);
                          final isNotified = _notifiedNotes.contains(index);

                          return GestureDetector(
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
                                color: Colors.white.withOpacity(isSelected ? 0.35 : 0.2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _notes[index].text,
                                          style: const TextStyle(color: Colors.black87),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _notes[index].createdAt,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
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

                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.black54),
                                    onPressed: () => _showEditDialog(index),
                                  ),
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

class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const GlassInputField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.black45),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

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
      opacity: isEnabled ? 1.0 : 0.5,
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
