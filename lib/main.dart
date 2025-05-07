import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/weather_page.dart';
import 'pages/news_page.dart';      // 추가
import 'pages/traffic_page.dart';
import 'pages/note_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project EB',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':         (_) => const MainPage(),
        '/weather':  (_) => const WeatherPage(),
        '/news':     (_) => const NewsPage(),     // 추가
        '/traffic':  (_) => const TrafficPage(),
        '/note':     (_) => const NotePage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
