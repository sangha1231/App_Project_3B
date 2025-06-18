import 'dart:convert';
import 'package:http/http.dart' as http;

class MidForecastService {
  final String serviceKey;

  MidForecastService(this.serviceKey);

  // 중기 기온 예보
  Future<Map<String, dynamic>> getMidTemperature(String regId, String tmFc) async {
    final url = Uri.parse(
      'https://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa'
          '?serviceKey=$serviceKey'
          '&pageNo=1&numOfRows=10'
          '&dataType=JSON'
          '&regId=$regId'
          '&tmFc=$tmFc',
    );

    final response = await http.get(url);
    final json = jsonDecode(response.body);
    return json['response']['body']['items']['item'][0];
  }

  // 중기 날씨 예보 (강수확률 + 맑음/비/눈 등)
  Future<Map<String, dynamic>> getMidWeather(String regId, String tmFc) async {
    final url = Uri.parse(
      'https://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst'
          '?serviceKey=$serviceKey'
          '&pageNo=1&numOfRows=10'
          '&dataType=JSON'
          '&regId=$regId'
          '&tmFc=$tmFc',
    );

    final response = await http.get(url);
    final json = jsonDecode(response.body);
    return json['response']['body']['items']['item'][0];
  }
}

