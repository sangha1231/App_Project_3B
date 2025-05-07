import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/weather_page.dart';
import 'pages/news_page.dart';
import 'pages/traffic_page.dart';
import 'pages/note_page.dart';
import 'pages/settings_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
