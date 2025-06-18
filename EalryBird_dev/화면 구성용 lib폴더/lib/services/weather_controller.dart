import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';
import '../services/vilage_forecast_service.dart';
import '../utils/geo_converter.dart';

class WeatherController {
  final VilageForecastService service;

  WeatherController(this.service);

  Future<WeatherData> fetchWeather() async {
    try {
      Position pos = await _getPosition();
      var geo = GeoConverter.toGrid(pos.latitude, pos.longitude);

      if (geo.nx > 149 || geo.ny > 255 || geo.nx < 0 || geo.ny < 0) {
        geo = LatXLngY(nx: 60, ny: 127); // 서울 기본값
      }

      String address = await _getAddress(pos);

      final now = DateTime.now().toUtc().add(const Duration(hours: 9));
      final baseDateTime = _getBaseDateTime(now);
      final baseDate = baseDateTime['base_date']!;
      final baseTime = baseDateTime['base_time']!;

      final availableHours = [0, 3, 6, 9, 12, 15, 18, 21];
      final closestHour = availableHours.reduce(
        (a, b) => (now.hour - a).abs() < (now.hour - b).abs() ? a : b,
      );
      final closestTime = _two(closestHour) + '00';

      final items = await service.fetchForecast(
        nx: geo.nx,
        ny: geo.ny,
        baseDate: baseDate,
        baseTime: baseTime,
      );

      String? getValue(String category) {
        final found = items.firstWhere(
          (e) =>
              e['category'] == category &&
              (category == 'TMX' || category == 'TMN'
                  ? true
                  : e['fcstTime'] == closestTime),
          orElse: () => {},
        );
        return found['fcstValue'];
      }

      final sky = getValue('SKY');
      final pty = getValue('PTY');

      return WeatherData(
        address: address,
        temperature: double.tryParse(getValue('TMP') ?? ''),
        pop: getValue('POP'),
        tmx: getValue('TMX'),
        tmn: getValue('TMN'),
        skyText: _skyDescription(sky),
        weatherIcon: _weatherIcon(sky, pty),
      );
    } catch (e) {
      return WeatherData(address: '위치 확인 불가', error: e.toString());
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

  Future<String> _getAddress(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
        localeIdentifier: 'ko',
      );
      final place = placemarks.first;
      final List<String> candidates = [
        place.administrativeArea,
        place.subAdministrativeArea,
        place.locality
      ].whereType<String>().where((e) => e.isNotEmpty).toList();

      return candidates.isNotEmpty ? candidates.join(', ') : '위치 확인 불가';
    } catch (e) {
      return '위치 확인 불가';
    }
  }

  Map<String, String> _getBaseDateTime(DateTime now) {
    final hours = [2, 5, 8, 11, 14, 17, 20, 23];
    int selectedHour;
    DateTime baseDate = now;

    try {
      selectedHour = hours.lastWhere((h) => now.hour >= h);
    } catch (e) {
      selectedHour = 23;
      baseDate = now.subtract(const Duration(days: 1));
    }

    return {
      'base_date':
          '${baseDate.year}${_two(baseDate.month)}${_two(baseDate.day)}',
      'base_time': '${_two(selectedHour)}00',
    };
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _skyDescription(String? value) {
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

  String _weatherIcon(String? sky, String? pty) {
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
