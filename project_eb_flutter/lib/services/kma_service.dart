// lib/services/kma_service.dart

import 'package:http/http.dart' as http;
import 'package:project_eb_flutter/models/weather_data.dart';

class KmaService {
  final String apiKey;
  static const _baseUrl = 'https://apihub.kma.go.kr/';

  KmaService(this.apiKey);

  /// 어제 날짜(서울 108번 지점)의 일자료를 가져와 WeatherData로 변환
  Future<WeatherData> fetchYesterdaySeoul() async {
    // 어제 날짜 문자열 (yyyyMMdd)
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateStr = '${yesterday.year}${_two(yesterday.month)}${_two(yesterday.day)}';

    // API endpoint + query parameters
    final uri = Uri.parse('$_baseUrl/api/typ01/url/kma_sfcdd3.php').replace(queryParameters: {
      'tm1': dateStr,
      'tm2': dateStr,
      'stn': '108',
      'authKey': apiKey,
    });

    // 요청 URI 로그
    print('📡 KMA 요청 URI → $uri');

    try {
      final res = await http.get(uri);
      print('📨 응답 상태 → ${res.statusCode}');
      // print('📨 본문 → ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('API 호출 실패: ${res.statusCode}');
      }

      // 줄 단위 분할 후, 필요한 수치 추출
      final values = _extractWeatherValues(res.body.split('\n'));

      // 파싱한 값들을 올바른 타입으로 변환
      final tempRaw = values[0];
      final humRaw  = values[1];
      final windRaw = values[2];
      final lowRaw  = values[5];

      final temp   = double.tryParse(tempRaw) ?? 0.0;
      final hum    = (double.tryParse(humRaw) ?? 0.0).toInt();
      final wind   = double.tryParse(windRaw) ?? 0.0;
      final ltemp  = double.tryParse(lowRaw) ?? 0.0;

      // 상태 분류 및 아이콘 매핑
      final status    = _classifyWeather(values);
      final iconAsset = _iconAssetForStatus(status);

      // WeatherData 객체 생성
      return WeatherData(
        status:      status,
        temperature: temp,
        humidity:    hum,
        windSpeed:   wind,
        lowestTemp:  ltemp,
        iconAsset:   iconAsset,
      );
    } catch (e) {
      print('❌ HTTP 에러 → $e');
      rethrow;
    }
  }

  // --- 내부 유틸리티 메서드들 ---

  /// 응답 라인에서 [기온, 습도, 풍속, 강수량, 운량, 최저기온]을 추출
  List<String> _extractWeatherValues(List<String> lines) {
    for (var line in lines) {
      if (line.startsWith('#') || line.trim().isEmpty) continue;
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 36 && parts[1] == '108') {
        return [
          parts[10], // 평균기온
          parts[18], // 평균습도
          parts[2],  // 평균풍속
          parts[35], // 일강수량
          parts[31], // 평균운량
          parts[13], // 최저기온
        ];
      }
    }
    // 예외 시 모두 "0"으로 반환
    return ['0', '0', '0', '0', '0', '0'];
  }

  /// 수치 기반 날씨 상태 분류
  String _classifyWeather(List<String> data) {
    final t = double.tryParse(data[0]) ?? -9.0;
    final w = double.tryParse(data[2]) ?? -9.0;
    final r = double.tryParse(data[3]) ?? -9.0;
    final c = double.tryParse(data[4]) ?? -9.0;

    if (r >= 30 && r != -9.0)     return '비';
    else if (t <= 0 && t != -9.0) return '눈';
    else if (w >= 8 && w != -9.0) return '바람';
    else if (c >= 7 && c != -9.0) return '구름';
    else                           return '화창함';
  }

  /// 상태별 아이콘 경로 반환
  String _iconAssetForStatus(String status) {
    switch (status) {
      case '비':   return 'assets/images/rain.png';
      case '눈':   return 'assets/images/snow.png';
      case '구름': return 'assets/images/cloud.png';
      case '바람': return 'assets/images/wind.png';
      default:     return 'assets/images/sun.png';
    }
  }

  /// 두 자리 문자열로 포맷 (예: 3 → "03")
  String _two(int n) => n.toString().padLeft(2, '0');
}
