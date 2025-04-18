// lib/pages/weather_page.dart

import 'package:flutter/material.dart';
import '../services/kma_service.dart';
import '../models/weather_data.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq          = MediaQuery.of(context);
    final screenW     = mq.size.width;
    final bottomInset = mq.padding.bottom;
    const navHeight   = 60.0;
    const maxWidth    = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1) 풀스크린 배경
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          // 2) SafeArea → Center → 최대 폭 제한 → FutureBuilder 콘텐츠
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: FutureBuilder<WeatherData>(
                  future: KmaService('zaD7i0jSR5Og-4tI0reTZQ').fetchYesterdaySeoul(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('오류: ${snapshot.error}'));
                    }
                    final data = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // 뒤로가기
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.asset(
                                'assets/images/arrow_back.png',
                                width: 60,
                                height: 60,
                              ),
                            ),
                          ),

                          const SizedBox(height: 100),

                          // 날씨 상태
                          Text(
                            data.status == '화창함'
                                ? '오늘 날씨: 맑음'
                                : '오늘 날씨: ${data.status}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 날씨 아이콘
                          Image.asset(
                            data.iconAsset,
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 8),

                          // 기온
                          Text(
                            '${data.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 추가 정보
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '최저기온: ${data.lowestTemp.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '습도: ${data.humidity}%',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '풍속: ${data.windSpeed.toStringAsFixed(1)}m/s',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),
                          // (기존 Padding → Row 코드는 삭제)
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      // 3) bottomNavigationBar: MainPage 와 동일한 하단 바
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: Stack(
          children: [
            // 바 배경 (110% 확대)
            Positioned.fill(
              child: FractionallySizedBox(
                widthFactor: 1.1,
                heightFactor: 1.0,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/bottom.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 버튼 2개 중앙 정렬
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/'),
                    child: Image.asset(
                      'assets/images/bottom_mainpage.png',
                      width: navHeight * 2.5,
                      height: navHeight * 2.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: Image.asset(
                      'assets/images/bottom_setting.png',
                      width: navHeight * 2.5,
                      height: navHeight * 2.5,
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
