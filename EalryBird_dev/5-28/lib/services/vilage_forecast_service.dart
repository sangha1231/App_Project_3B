import 'dart:convert';
import 'package:http/http.dart' as http;

class VilageForecastService {
  final String apiKey;
  VilageForecastService(this.apiKey);

  /// 단기예보 조회 (격자 좌표: nx, ny)
  Future<List<Map<String, dynamic>>> fetchForecast({
    required int nx,
    required int ny,
    required String baseDate,
    required String baseTime,
  }) async {
    final uri = Uri.parse(
      'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst',
    ).replace(
      queryParameters: {
        'serviceKey': Uri.decodeFull(apiKey),
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': baseDate,
        'base_time': baseTime,
        'nx': nx.toString(),
        'ny': ny.toString(),
      },
    );

    final response = await http.get(uri);

    print('[디버그] 호출 URL: $uri');
    print('[디버그] 응답 코드: ${response.statusCode}');
    print('[디버그] 응답 본문: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('단기예보 API 호출 실패: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body);

    // null 체크 추가
    final body = jsonData['response']?['body'];
    final items = body?['items']?['item'];

    if (items == null) {
      throw Exception('예보 데이터가 존재하지 않습니다. API 응답 구조를 확인해 주세요.');
    }

    return List<Map<String, dynamic>>.from(items);
  }
}
