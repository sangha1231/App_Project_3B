import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'weather_page.dart';
import 'news_page.dart';
import 'note_page.dart';
import 'settings_page.dart';
import 'bus_page.dart';
import '../wallpaper_provider.dart'; // lib 폴더로 한 단계 위로 이동하여 임포트

class NoteItem {
  final String text;
  final String createdAt;

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

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _showWallpaperDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "배경화면 선택",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _WallpaperOption(
                          imagePath: 'assets/images/wallpaper_1.jpg',
                          onTap: () {
                            Provider.of<WallpaperProvider>(context, listen: false).changeWallpaper('assets/images/wallpaper_1.jpg');
                            Navigator.pop(context);
                          },
                        ),
                        _WallpaperOption(
                          imagePath: 'assets/images/wallpaper_2.jpg',
                          onTap: () {
                            Provider.of<WallpaperProvider>(context, listen: false).changeWallpaper('assets/images/wallpaper_2.jpg');
                            Navigator.pop(context);
                          },
                        ),
                        _WallpaperOption(
                          imagePath: 'assets/images/wallpaper_3.jpg',
                          onTap: () {
                            Provider.of<WallpaperProvider>(context, listen: false).changeWallpaper('assets/images/wallpaper_3.jpg');
                            Navigator.pop(context);
                          },
                        ),
                        _WallpaperOption(
                          imagePath: 'assets/images/wallpaper_4.jpg',
                          onTap: () {
                            Provider.of<WallpaperProvider>(context, listen: false).changeWallpaper('assets/images/wallpaper_4.jpg');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("취소"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;

    // --- 여기를 수정했습니다 ---
    // 위젯 간 간격과 좌우 여백을 조절하는 값입니다. (기존 0.05 -> 0.04)
    final horizontalPadding = screenWidth * 0.04;
    final widgetSpacing = horizontalPadding;
    // --- 여기까지 ---

    final maxWidth = screenWidth - horizontalPadding * 2;
    final widgetSize = (maxWidth - widgetSpacing) / 2;
    final noteWidgetHeight = widgetSize * 1.8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'App Title',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(
                height: 70,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Smart Life App',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                ),
                accountName: const Text(
                  '사용자 아이디',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: null,
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.black,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('설정'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('배경화면 바꾸기'),
                onTap: () {
                  Navigator.pop(context);
                  _showWallpaperDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: const Text('앱 종료'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                              horizontal: 24, vertical: 12),
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
                                              horizontal: 24, vertical: 12),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(wallpaperProvider.currentWallpaper, fit: BoxFit.cover),
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
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()),
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
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotePage()),
                          ),
                          child: _GlassPanel(
                            width: double.infinity,
                            height: noteWidgetHeight,
                            child: const _NoteContent(),
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
    );
  }
}

// ... Rest of the classes (_GlassPanel, _WallpaperOption, content widgets) remain the same ...
// ... (아래의 _GlassPanel, _WallpaperOption 및 다른 위젯들은 변경 사항이 없으므로 생략합니다) ...

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
            border:
            Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _WallpaperOption extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _WallpaperOption({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
      ),
    );
  }
}

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
              '날씨',
              style: TextStyle(
                fontSize: 27,
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
              '뉴스',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 27,
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

class _TrafficContent extends StatelessWidget {
  const _TrafficContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.train_rounded, size: 40, color: Colors.green),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '버스 시간표',
              style: TextStyle(
                fontSize: 27,
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
                fontSize: 27,
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

class _NoteContent extends StatelessWidget {
  const _NoteContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.edit_note, size: 40, color: Colors.amber),
        ),
        Positioned(
          top: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '메모장',
              style: TextStyle(
                fontSize: 27,
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