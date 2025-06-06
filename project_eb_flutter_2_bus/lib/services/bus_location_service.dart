// lib/services/bus_location_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bus_location.dart';

class BusLocationService {
  /// 경기도 버스도착정보 v2 엔드포인트(원본 URL 템플릿)
  static const _baseUrl =
      'https://apis.data.go.kr/6410000/busarrivalservice/v2/getBusArrivalListv2'
      '?serviceKey=JBfCRTmqv7MZZnfa%2FV%2F19Fi9Cyl3AT2sRBMZ6WM00ExOgCneEenq6pdnXVvprqE8GXT5x1Dp7%2FdIfYC3%2FFWrkw%3D%3D'
      '&stationId={stationId}'
      '&format=json';

  /// stationId: 조회할 “정류장 ID” (예: "206000004")
  Future<List<BusLocation>> fetchLocations(String stationId) async {
    // 1) URL 문자열 완성: {stationId} 부분만 치환
    final url = _baseUrl.replaceFirst(
      '{stationId}',
      Uri.encodeComponent(stationId),
    );
    print('▶️ BusLocationService 호출 URL: $url');

    // 2) HTTP GET 요청
    final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
    print('▶️ 상태 코드: ${resp.statusCode}');
    print('▶️ 응답 본문 (원본): ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('버스 도착정보 API 실패: ${resp.statusCode}');
    }

    // 3) JSON 디코딩
    final decoded = json.decode(resp.body) as Map<String, dynamic>;
    final responseObj = decoded['response'] as Map<String, dynamic>? ?? {};
    final msgBodyObj = responseObj['msgBody'] as Map<String, dynamic>? ?? {};

    // 4) busArrivalList 배열 추출
    final arrivalListRaw = msgBodyObj['busArrivalList'] as List<dynamic>? ?? [];
    if (arrivalListRaw.isEmpty) return [];

    // 5) BusLocation 모델로 변환하여 반환
    return arrivalListRaw
        .map((e) => BusLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
