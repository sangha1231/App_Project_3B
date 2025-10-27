import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../wallpaper_provider.dart';
import 'colors.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = context.watch<WallpaperProvider>();
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              wallpaperProvider.currentWallpaper,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        children: [
                          ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey.withOpacity(0.2),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),

                          const Expanded(
                            child: Center(
                              child: Text(
                                "오늘의 일정",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        itemCount: 10,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return const ScheduleCard(
                            startTime: 9,
                            endTime: 10,
                            content: "플러터 UI 작업하기",
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              width: 1.0,
              color: Colors.white.withOpacity(0.3),
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
            color: Colors.black.withOpacity(0.6),
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
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}