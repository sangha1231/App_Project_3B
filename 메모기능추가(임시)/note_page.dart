import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final List<String> _notes = [];
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.removeAt(index); // 메모 삭제
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
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
    _controller.dispose(); // TextEditingController 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navHeight = 60.0;
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Stack(
                children: [
                  // 뒤로 가기 버튼
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                      child: Image.asset(
                        'assets/images/arrow_back.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      const SizedBox(height: 80), // "뒤로 가기 버튼" 아래 간격 추가

                      // "메모장" 제목
                      const Text(
                        '메모장',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // "새 메모 입력" 필드와 "메모 추가" 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // 입력 필드
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 4,
                                    ),
                                  ),
                                  hintText: '새 메모 입력',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                enableIMEPersonalizedLearning: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // "메모 추가" 버튼
                            ElevatedButton(
                              onPressed: _addNote,
                              child: const Text('추가'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 메모 리스트
                      Expanded(
                        child: ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _notes[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min, // 트레일링(Row)의 최소 너비로 맞춤
                                children: [
                                  GestureDetector(
                                    onTap: () => _deleteNote(index), // 삭제 다이얼로그 연결
                                    child: Image.asset(
                                      'assets/images/delete.png', // 사용자 정의 삭제 이미지 경로
                                      width: 30, // 이미지 너비
                                      height: 30, // 이미지 높이
                                    ),
                                  ),
                                  const SizedBox(width: 20), // 삭제 아이콘과 알람 이미지 사이 간격
                                  GestureDetector(
                                    // onTap: () {
                                    //   // 알람 버튼에 동작 추가 가능
                                    //   print('알람 버튼 클릭!');
                                    // },
                                    child: Image.asset(
                                      'assets/images/alarm.png', // alarm.png 경로
                                      width: 30, // 이미지 너비
                                      height: 30, // 이미지 높이
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bottom.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.only(bottom: bottomInset + 4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: Image.asset(
                    'assets/images/bottom_mainpage.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: Image.asset(
                    'assets/images/bottom_setting.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
