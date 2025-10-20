import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:math';


class DustData {
  final String grade;
  final int value;
  final String stationName;

  DustData({required this.grade, required this.value, required this.stationName});
}
class Station {
  final String stationName;
  final double latitude;
  final double longitude;

  Station(this.stationName, this.latitude, this.longitude);
}

final List<Station> stations = [
  Station('중구', 37.5642135, 126.997655), // 
  Station('수원시', 37.2635732, 127.0286017), // 경기 
  Station('춘천시', 37.8813158, 127.7299707), // 강원 
  Station('청주시', 36.6424345, 127.4890312), // 충북 
  Station('홍성군', 36.6014959, 126.6600033), // 충남 
  Station('전주시', 35.8213411, 127.1480425), // 전북 
  Station('목포시', 34.8118351, 126.3921662), // 전남 
  Station('안동시', 36.5683541, 128.7293574), // 경북 
  Station('창원시', 35.2279187, 128.681055), // 경남 
  Station('제주시', 33.4996213, 126.5311884), 
];
class DustService {
  final String apiKey;
  DustService(this.apiKey);

  Future<DustData?> fetchDust(Position pos) async {
    try {
      final double userLat = pos.latitude;
      final double userLng = pos.longitude;
      final station = await _findNearestStation(userLat, userLng);

      if (station == null) {
        throw Exception('측정소를 찾을 수 없습니다.');
      }
      final dustInfo = await _fetchDustAtStation(station.stationName);

      return DustData(
        grade: _mapDustLevel(dustInfo['pm25Value']),
        value: int.parse(dustInfo['pm25Value']),
        stationName: station.stationName,
      );
    } catch (e) {
      print('미세먼지 가져오기 실패: $e');
      return null;
    }
  }
  Future<Station?> _findNearestStation(double userLat, double userLng) async {
    double minDistance = double.infinity;
    Station? nearestStation;

    for (final station in stations) {
      final distance = _calculateDistance(userLat, userLng, station.latitude, station.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = station;
      }
    }
    return nearestStation;
  }
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371; 

    final double dLat = _deg2rad(lat2 - lat1);
    final double dLng = _deg2rad(lng2 - lng1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
                sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;

    return distance;
  }
  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  Future<Position> _getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 거부되었습니다.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> _fetchDustAtStation(String stationName) async {
    final uri = Uri.parse('http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty')
        .replace(queryParameters: {
      'serviceKey': apiKey,
      'returnType': 'json',
      'stationName': stationName,
      'dataTerm': 'DAILY',
      'ver': '1.3',
    });
    print('미세먼지 API 호출 URL: $uri');

    final response = await http.get(uri);
    final jsonData = jsonDecode(response.body);
    final items = jsonData['response']?['body']?['items'];

    if (items != null && items is List && items.isNotEmpty) {
      return items.first;
    }
    throw Exception('미세먼지 정보를 가져올 수 없습니다.');
  }

  String _mapDustLevel(String valueStr) {
    final value = int.tryParse(valueStr) ?? 0;
    if (value <= 15) return '좋음';
    if (value <= 35) return '보통';
    if (value <= 75) return '나쁨';
    return '매우 나쁨';
  }
}