import 'dart:ui'; // 1. BackdropFilter를 사용하기 위해 import
import 'package:flutter/material.dart';
import 'colors.dart';

class _Time extends StatelessWidget{
  final int startTime;
  final int endTime;

  const _Time({
    required this.startTime,
    required this.endTime,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    // 2. 텍스트 색상을 배경과 상관없이 잘 보이도록 어두운 색으로 변경
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.black.withOpacity(0.8),
      fontSize: 16.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00',
          style: textStyle,
        ),
        Text(
          '${endTime.toString().padLeft(2, '0')}:00',
          style: textStyle.copyWith(
            fontSize: 10.0,
            color: Colors.black.withOpacity(0.6), // 보조 텍스트는 좀 더 연하게
          ),
        )
      ],
    );
  }
}

class _Content extends StatelessWidget{
  final String content;

  const _Content({
    required this.content,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Expanded(
      child: Text(
        content,
        // 3. 내용 텍스트 색상도 변경
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }

}

class ScheduleCard extends StatelessWidget{
  final int startTime;
  final int endTime;
  final String content;

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.content,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    // 4. ClipRRect와 BackdropFilter로 감싸 유리 질감을 만듭니다.
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            // 5. 반투명한 흰색 배경과 은은한 테두리로 변경
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              width: 1.5,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Time(startTime: startTime, endTime: endTime),
                  const SizedBox(width: 16.0),
                  _Content(content: content),
                  const SizedBox(width: 16.0,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}