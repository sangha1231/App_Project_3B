import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'pages/account_page.dart';
import 'pages/bus_page.dart';
import 'pages/login_page.dart';
import 'pages/my_page.dart';
import 'pages/notification_page.dart';
import 'pages/signup_page.dart';
import 'pages/main_page.dart';
import 'pages/weather_page.dart';
import 'pages/news_page.dart';
import 'pages/note_page.dart';
import 'pages/home_screen.dart';
import 'pages/settings_page.dart';
import 'database/drift_database.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');

  DateTime now = DateTime.now();
  String formattedDate = DateFormat.yMMMMd('ko_KR').format(now);
  print(formattedDate);

  await Firebase.initializeApp();

  //  Drift Database 인스턴스 등록
  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);

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
        '/': (_) => const MainPage(),
        '/weather': (_) => const WeatherPage(),
        '/news': (_) => const NewsPage(),
        '/bus': (_) => const BusPage(),
        '/note': (_) => const NotePage(),
        '/settings': (_) => const SettingsPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/mypage': (_) => const MyPage(),
        '/account': (_) => const AccountPage(),
        '/calendar': (_) => const HomeScreen(),
        '/notifications': (_) => const NotificationPage(),
      },
    );
  }
}
