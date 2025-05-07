// lib/pages/weather_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/weather_controller.dart';
import '../models/weather_data.dart';
import '../services/vilage_forecast_service.dart';

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
          "Ss1oqrxEJeZWB2n737U08XyxvdG6k2Uy5nNEwvX0LpBNyTrtrZEK2iDGCCioQXriqSaZIzoZv1HlnLxbIIO4Hw=="
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

    // 로딩 / 에러 처리
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (weather?.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('에러: ${weather!.error}', style: const TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) 배경 이미지
          Positioned.fill(
            child: Image.asset('assets/images/sky.img', fit: BoxFit.cover),
          ),

          // 2) 뒤로 가기 버튼 (glass)
          Positioned(
            top: 40,
            left: 16,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 40, height: 40,
                  color: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // 3) 메인 콘텐츠 글래스 패널
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: navHeight + bottomInset + 24),
              child: _GlassPanel(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weather!.address,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF4A4A4A)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '오늘의 날씨: ${weather!.skyText}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      'assets/images/${weather!.weatherIcon}',
                      width: 120, height: 120,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 120, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '현재 ${weather!.temperature!.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                    ),
                    const SizedBox(height: 8),
                    if (weather?.tmn != null && weather?.tmx != null)
                      Text(
                        '최저 ${weather!.tmn}°C  최고 ${weather!.tmx}°C',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
                      ),
                    if (weather?.pop != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '강수확률 ${weather!.pop}%',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 4) 하단 네비게이션 바(글래스)
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.white.withOpacity(0.2),
              padding: EdgeInsets.only(bottom: bottomInset + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, size: 32, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 32, color: Colors.white),
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

/// 재사용 가능한 글래스 패널 위젯
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
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
