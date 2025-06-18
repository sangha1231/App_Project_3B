import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_eb_flutter/pages/account_page.dart';
//import 'package:intl/date_symbol_data_file.dart';
import 'package:project_eb_flutter/pages/bus_page.dart';
import 'package:project_eb_flutter/pages/login_page.dart';
import 'package:project_eb_flutter/pages/my_page.dart';
import 'package:project_eb_flutter/pages/notification_page.dart';
import 'package:project_eb_flutter/pages/signup_page.dart';
import 'pages/main_page.dart';
import 'pages/weather_page.dart';
import 'pages/news_page.dart';      // 추가
import 'pages/bus_page.dart';
import 'pages/note_page.dart';
import 'pages/settings_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ 비동기 작업 전 필수
  // ✅ 두 번째 인수(null) 없이 로케일(locale)만 넘겨줍니다.
  await initializeDateFormatting('ko_KR');

  DateTime now = DateTime.now();
  String formattedDate = DateFormat.yMMMMd('ko_KR').format(now);
  print(formattedDate);

  await Firebase.initializeApp(); // ✅ Firebase 초기화

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
        '/bus':  (_) => const BusPage(),
        '/note':     (_) => const NotePage(),
        '/settings': (_) => const SettingsPage(),
        '/login':(context) => const LoginPage(),
        '/signup':(context) => const SignupPage(),
        '/mypage':(_) => const MyPage(),
        '/account':(context) => const AccountPage(),
        '/notifications': (_) => const NotificationPage(),
      },
    );
  }
}
