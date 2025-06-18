import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bus_station.dart';

class BusStationService {
  /// 브라우저에서 정상 동작 확인된 URL 템플릿
  static const _urlTemplate = 'https://apis.data.go.kr/6410000/busstationservice/v2/'
      'getBusStationListv2?serviceKey=JBfCRTmqv7MZZnfa%2FV%2F19Fi9Cyl3AT2sRBMZ6WM00ExOgCneEenq6pdnXVvprqE8GXT5x1Dp7%2FdIfYC3%2FFWrkw%3D%3D'
      '&keyword={keyword}'
      '&format=json';

  Future<List<BusStation>> fetchStations(String keyword) async {
    // {keyword} 에 검색어 삽입 (한글도 자동 인코딩)
    final url = _urlTemplate.replaceFirst(
      '{keyword}',
      Uri.encodeComponent(keyword),
    );
    print('▶️ 요청 URL: $url');

    final resp = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));
    print('▶️ 상태 코드: ${resp.statusCode}');
    print('▶️ 응답 본문: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('정류소 목록 API 실패: ${resp.statusCode}');
    }

    // 1) 최상위 decode
    final decoded      = json.decode(resp.body) as Map<String, dynamic>;

    // 2) response 내부
    final responseObj  = decoded['response'] as Map<String, dynamic>?;
    if (responseObj == null) return [];

    // 3) msgBody 내부 (기존 body → msgBody 로 변경)
    final msgBodyObj   = responseObj['msgBody'] as Map<String, dynamic>?;
    if (msgBodyObj == null) return [];

    // 4) busStationList 배열 추출
    final stationList  = msgBodyObj['busStationList'] as List<dynamic>?;
    if (stationList == null || stationList.isEmpty) return [];

    // 5) 모델로 매핑
    return stationList
        .map((e) => BusStation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
