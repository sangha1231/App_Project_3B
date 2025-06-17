import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_controller.dart';
import '../models/weather_data.dart';
import '../services/vilage_forecast_service.dart';
import '../services/dust_service.dart';
import '../services/mid_forecast_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}
class _WeatherPageState extends State<WeatherPage> {
  WeatherData? weather;
  bool isLoading = true;
  late final WeatherController controller;

  @override
  void initState() {
    super.initState();
    controller = WeatherController(
      VilageForecastService(
        "Ss1oqrxEJeZWB2n737U08XyxvdG6k2Uy5nNEwvX0LpBNyTrtrZEK2iDGCCioQXriqSaZIzoZv1HlnLxbIIO4Hw==",
      ),
      DustService(
        "Ss1oqrxEJeZWB2n737U08XyxvdG6k2Uy5nNEwvX0LpBNyTrtrZEK2iDGCCioQXriqSaZIzoZv1HlnLxbIIO4Hw==",
      ),
      MidForecastService(
        "Ss1oqrxEJeZWB2n737U08XyxvdG6k2Uy5nNEwvX0LpBNyTrtrZEK2iDGCCioQXriqSaZIzoZv1HlnLxbIIO4Hw==",
      ),
    );
    fetch();
  }

  void fetch() async {
    final result = await controller.fetchWeather();
    setState(() {
      weather = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = 46.0;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (weather?.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            '에러: ${weather!.error}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // 미세먼지 상태 분류
    final pm25 = weather!.pm25 ?? 0;
    late Color dustColor;
    late String dustStatus;
    if (pm25 > 75) {
      dustColor = Colors.red;
      dustStatus = '심각';
    } else if (pm25 > 35) {
      dustColor = Colors.black;
      dustStatus = '보통';
    } else {
      dustColor = Colors.lightGreen.shade400;
      dustStatus = '쾌적';
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),
          // 뒤로가기 버튼
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
          // 메인 콘텐츠
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 36, bottom: navHeight + bottomInset + 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1행: 날씨 그림 + 현재기온 | 최저/최고기온
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.2,
                            child: _WidgetPanel(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/${weather!.weatherIcon}',
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.error,
                                      size: 60,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '현재 ${weather!.temperature!.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.2,
                            child: _WidgetPanel(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.thermostat, color: Colors.blueAccent),
                                      const SizedBox(width: 6),
                                      Text(
                                        '최저 ${weather!.tmn}°C',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue.shade200),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.thermostat, color: Colors.redAccent),
                                      const SizedBox(width: 6),
                                      Text(
                                        '최고 ${weather!.tmx}°C',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.red.shade200),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 2행: 미세먼지 | 강수확률 (아이콘 위, 텍스트 중간, 상태 맨 아래)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // 1) 미세먼지 위젯
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.2,
                            child: _WidgetPanel(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 아이콘을 확대 (약 1.7배)
                                  Icon(
                                    Icons.grain,
                                    size: 26 * 1.7, // 기본 24 → 약 40.8
                                    color: Colors.amber.shade800,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '미세먼지',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.amber.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$dustStatus (${weather!.pm25}㎍/㎥)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: dustColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 2) 강수 위젯
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.2,
                            child: _WidgetPanel(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.beach_access,
                                    size: 24 * 1.7, // 약 40.8
                                    color: Colors.lightBlueAccent,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '강수',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.lightBlue.shade200,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${weather!.pop}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.lightBlue.shade200,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (weather!.weeklyForecast != null && weather!.weeklyForecast!.length >= 6)
                    Column(
                      children: [
                        for (int row = 0; row < 2; row++)
                          Row(
                            children: List.generate(3, (col) {
                              int index = row * 3 + col;
                              final forecast = weather!.weeklyForecast![index];
                              final weekday = DateFormat.E('ko').format(DateTime.now().add(Duration(days: index + 1)));

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _WidgetPanel(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(weekday,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                )
                                            ),
                                            const SizedBox(width: 6),
                                            Image.asset(
                                              forecast.iconPath,
                                              width: 30,
                                              height: 30,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 30),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.beach_access, size: 20, color: Colors.lightBlueAccent),
                                            const SizedBox(width: 4),
                                            Text('${forecast.pop ?? 0}%', style: const TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            ),
                          ),
                      ],
                    )

                ],
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
                  //중앙 분리선
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

class _WidgetPanel extends StatelessWidget {
  final Widget child;
  const _WidgetPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}