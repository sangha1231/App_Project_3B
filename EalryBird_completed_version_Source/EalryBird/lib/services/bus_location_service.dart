import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bus_location.dart';

class BusLocationService {
  static const _baseUrl =
      'https://apis.data.go.kr/6410000/busarrivalservice/v2/getBusArrivalListv2'
      '?serviceKey=JBfCRTmqv7MZZnfa%2FV%2F19Fi9Cyl3AT2sRBMZ6WM00ExOgCneEenq6pdnXVvprqE8GXT5x1Dp7%2FdIfYC3%2FFWrkw%3D%3D'
      '&stationId={stationId}'
      '&format=json';

  Future<List<BusLocation>> fetchLocations(String stationId) async {
    final url = _baseUrl.replaceFirst(
      '{stationId}',
      Uri.encodeComponent(stationId),
    );
    print('▶️ BusLocationService 호출 URL: $url');

    final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
    print('▶️ 상태 코드: ${resp.statusCode}');
    print('▶️ 응답 본문 (원본): ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('버스 도착정보 API 실패: ${resp.statusCode}');
    }

    final decoded = json.decode(resp.body) as Map<String, dynamic>;
    final responseObj = decoded['response'] as Map<String, dynamic>? ?? {};
    final msgBodyObj = responseObj['msgBody'] as Map<String, dynamic>? ?? {};

    final arrivalListRaw = msgBodyObj['busArrivalList'] as List<dynamic>? ?? [];
    if (arrivalListRaw.isEmpty) return [];

    return arrivalListRaw
        .map((e) => BusLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
