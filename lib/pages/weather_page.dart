// lib/pages/weather_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/weather_controller.dart';
import '../models/weather_data.dart';
import '../services/vilage_forecast_service.dart';
import '../services/dust_service.dart';

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
    final navHeight = 60.0;
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
          child: Text('에러: ${weather!.error}', style: const TextStyle(color: Colors.white)),
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
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: navHeight + bottomInset + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 메인 날씨 위젯 (2x2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _WidgetPanel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/${weather!.weatherIcon}',
                              width: 120,
                              height: 120,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.error,
                                size: 120,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '현재 ${weather!.temperature!.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 1x1 온도, 1x1 강수
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _WidgetPanel(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.thermostat, color: Colors.blueAccent),
                                      const SizedBox(width: 8),
                                      Text('최저', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade200)),
                                      const SizedBox(width: 4),
                                      Text('${weather!.tmn}°C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade200)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.thermostat, color: Colors.redAccent),
                                      const SizedBox(width: 8),
                                      Text('최고', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade200)),
                                      const SizedBox(width: 4),
                                      Text('${weather!.tmx}°C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade200)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _WidgetPanel(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.beach_access, color: Colors.lightBlueAccent),
                                  const SizedBox(width: 8),
                                  Text('강수확률', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.lightBlue.shade200)),
                                  const SizedBox(width: 4),
                                  Text('${weather!.pop}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.lightBlue.shade200)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 1x1 미세먼지 위젯 (왼쪽 정렬)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _WidgetPanel(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.grain, color: Colors.amber.shade800),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('미세먼지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                                      Text('$dustStatus (${weather!.pm25}㎍/㎥)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: dustColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: Container()),
                      ],
                    ),
                  ),
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
                  Container(
                    height: navHeight * 0.5,
                    width: 1,
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
