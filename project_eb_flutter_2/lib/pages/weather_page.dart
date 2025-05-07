import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/weather_controller.dart';
import '../models/weather_data.dart';

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
    controller = WeatherController();
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Image.asset('assets/images/arrow_back.png', width: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: navHeight + bottomInset),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weather!.location,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('오늘의 날씨: ${controller.skyDescription(weather!.sky)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/${controller.weatherIcon(weather!.sky, null)}',
                    width: 160,
                    height: 160,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, size: 160);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                      '현재 기온: ${weather?.temperature.toStringAsFixed(1) ?? '--'}°C',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  if (weather?.pop != null)
                    Text('강수확률: ${weather!.pop}%',
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('미세먼지: ${weather!.dustGrade} (${weather!.pm25}㎍/㎥)',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bottom.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/'),
                    child: Image.asset(
                      'assets/images/bottom_mainpage.png',
                      width: navHeight * 3.4,
                      height: navHeight * 3.4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: Image.asset(
                      'assets/images/bottom_setting.png',
                      width: navHeight * 3.0,
                      height: navHeight * 3.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}