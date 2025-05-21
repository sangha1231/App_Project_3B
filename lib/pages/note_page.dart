import 'dart:ui';
import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final List<String> _notes = [];
  final Set<int> _selectedNotes = {}; // 선택된 메모들의 인덱스를 저장
  final TextEditingController _controller = TextEditingController();

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _notes.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.removeAt(index);
                  _selectedNotes.remove(index);
                  _selectedNotes.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('모든 메모를 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.clear();
                  _selectedNotes.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('선택한 메모를 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () {
                setState(() {
                  final selectedList = _selectedNotes.toList()..sort((a, b) => b.compareTo(a));
                  for (var idx in selectedList) {
                    if (idx >= 0 && idx < _notes.length) {
                      _notes.removeAt(idx);
                    }
                  }
                  _selectedNotes.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = 46.0;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          // 뒤로 가기 버튼 (Glass)
          Positioned(
            top: 40,
            left: 16,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context)),
                ),
              ),
            ),
          ),

          // 메인 글래스 패널
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: navHeight + bottomInset - 50),
              child: _GlassPanel(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('메모장',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 16),

                    // 입력 필드와 추가 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '새 메모 입력',
                                hintStyle: TextStyle(color: Colors.black45),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                              ),
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassButton(
                            onPressed: _addNote,
                            width: 70,
                            height: 36,
                            child: Text(
                              '추가',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 일괄 삭제 & 선택 삭제 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassButton(
                          onPressed: _deleteAllNotes,
                          width: 100,
                          height: 40,
                          child: Text(
                            '전체 삭제',
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
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
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.4),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 리스트뷰
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Checkbox(
                              value: _selectedNotes.contains(index),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedNotes.add(index);
                                  } else {
                                    _selectedNotes.remove(index);
                                  }
                                });
                              },
                            ),
                            title: Text(_notes[index],
                                style: const TextStyle(color: Colors.black87)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black54),
                              onPressed: () => _deleteNote(index),
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

      // 하단 네비게이션 바 (Glass)
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.white.withOpacity(0.2),
              padding: EdgeInsets.only(bottom: bottomInset + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: const Icon(Icons.home_outlined,
                          size: 32, color: Colors.black87),
                      onPressed: () => Navigator.pushNamed(context, '/')),
                  IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          size: 32, color: Colors.black87),
                      onPressed: () => Navigator.pushNamed(context, '/settings')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 글래스 모피즘 패널
class _GlassPanel extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  const _GlassPanel(
      {required this.width, required this.height, required this.child});

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
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
          child: child,
        ),
      ),
    );
  }
}

/// 커스텀 글래스모피즘 버튼
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
                splashColor: Colors.black.withOpacity(0.15),
                highlightColor: Colors.black.withOpacity(0.08),
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
