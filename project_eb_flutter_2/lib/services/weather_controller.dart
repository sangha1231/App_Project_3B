import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';

class WeatherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<WeatherData> fetchWeather() async {
    try {
      // 위치 가져오기
      Position pos = await _getPosition();
      String region = await _getRegionName(pos);

      // Firestore에서 날씨 + 미세먼지 데이터 가져오기
      final doc = await _firestore.collection('weather').doc(region).get();
      final data = doc.data();

      if (data == null) {
        throw Exception('No weather data found for $region');
      }

      return WeatherData(
        location: region, //
        temperature: (data['temperature'] as num).toDouble(),
        sky: data['sky'].toString(), //
        pop: data['pop'].toString(),
        pm25: data['pm25'] ?? 0,
        dustGrade: data['dustGrade'] ?? '',
        updatedAt: DateTime.tryParse(data['updatedAt'] ?? ''),
      );
    } catch (e) {
      return WeatherData(
        location: '위치 확인 불가', //  에러 fallback에도 필수 필드 반영
        temperature: 0.0,
        sky: '4',
        pop: '-',
        pm25: 0,
        dustGrade: '정보 없음',
        updatedAt: null,
      );
    }
  }

  Future<Position> _getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부됨');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getRegionName(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
        localeIdentifier: 'ko',
      );

      final place = placemarks.first;

      // 시/구/동 중 구가 있으면 구, 없으면 시
      if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
        return place.subAdministrativeArea!;
      } else if (place.locality != null && place.locality!.isNotEmpty) {
        return place.locality!;
      } else {
        return '서울'; // fallback
      }
    } catch (_) {
      return '서울';
    }
  }

  String skyDescription(String value) {
    switch (value) {
      case '1':
        return '맑음';
      case '3':
        return '구름 많음';
      case '4':
        return '흐림';
      default:
        return '알 수 없음';
    }
  }

  String weatherIcon(String sky, String? pty) {
    if (pty != null && pty != '0') {
      switch (pty) {
        case '1':
        case '2':
        case '4':
          return 'rain.png';
        case '3':
        case '6':
        case '7':
          return 'snow.png';
        default:
          return 'cloud.png';
      }
    } else {
      switch (sky) {
        case '1':
          return 'sun.png';
        case '3':
          return 'cloud.png';
        case '4':
          return 'wind.png';
        default:
          return 'cloud.png';
      }
    }
  }
}
