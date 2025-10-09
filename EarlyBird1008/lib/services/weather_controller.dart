import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../services/vilage_forecast_service.dart';
import '../utils/geo_converter.dart';
import '../services/dust_service.dart';
import '../services/mid_forecast_service.dart';

class WeatherController {
  final VilageForecastService service;
  final DustService dustService;
  final MidForecastService midService;

  WeatherController(this.service, this.dustService, this.midService);

  Future<WeatherData> fetchWeather() async {
    try {
      Position pos = await _getPosition();
      var geo = GeoConverter.toGrid(pos.latitude, pos.longitude);

      if (geo.nx > 149 || geo.ny > 255 || geo.nx < 0 || geo.ny < 0) {
        geo = LatXLngY(nx: 60, ny: 127); // 서울 
      }

      String address = await _getAddress(pos);
      String province = _getProvinceFromAddress(address); 
      final dustData = await dustService.fetchDust(pos); 
      final pm25 = dustData?.value ?? 0;
      final dustGrade = dustData?.grade ?? '정보없음';

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

      // 주간 예보 구성 (오늘/내일 단기예보 기반)
      final List<DailyForecast> weeklyForecast = [];
      final today = DateTime.now();
      final tomorrow = today.add(Duration(days: 1));

      for (final date in [today, tomorrow]) {
        final dateStr = DateFormat('yyyyMMdd').format(date);

        final max = items.firstWhere(
              (e) => e['category'] == 'TMX' && e['fcstDate'] == dateStr,
          orElse: () => {},
        )?['fcstValue'];

        final min = items.firstWhere(
              (e) => e['category'] == 'TMN' && e['fcstDate'] == dateStr,
          orElse: () => {},
        )?['fcstValue'];

        final pop = items
            .where((e) => e['category'] == 'POP' && e['fcstDate'] == dateStr)
            .map((e) => int.tryParse(e['fcstValue']))
            .whereType<int>()
            .fold(0, (a, b) => a + b) ~/
            8; 

        final sky = items.firstWhere(
              (e) => e['category'] == 'SKY' && e['fcstDate'] == dateStr,
          orElse: () => {},
        )?['fcstValue'];

        final pty = items.firstWhere(
              (e) => e['category'] == 'PTY' && e['fcstDate'] == dateStr,
          orElse: () => {},
        )?['fcstValue'];

        final icon = _weatherIcon(sky, pty) ?? 'assets/images/sun.png';

        if (max != null && min != null) {
          weeklyForecast.add(
            DailyForecast(
              iconPath: 'assets/images/$icon',
              min: int.tryParse(min) ?? 0,
              max: int.tryParse(max) ?? 0,
              pop: pop,
            ),
          );
          final regId = _mapRegionToCode(_getProvinceFromAddress(address));
          final tmFc = _getMidForecastTime();

          try {
            final midTemp = await midService.getMidTemperature(regId, tmFc);
            final midWeather = await midService.getMidWeather(regId, tmFc);

            for (int i = 3; i <= 7; i++) {
              final min = int.tryParse(midTemp['taMin$i']?.toString() ?? '0') ?? 0;
              final max = int.tryParse(midTemp['taMax$i']?.toString() ?? '0') ?? 0;

              // 오전/오후 예보 중 하나라도 비/눈/흐림 등이 포함되면 아이콘 변경
              final amWeather = midWeather['wf${i}Am']?.toString() ?? '';
              final pmWeather = midWeather['wf${i}Pm']?.toString() ?? '';
              final pop = int.tryParse(midWeather['rnSt${i}Pm']?.toString() ?? '0') ?? 0;
              final description = '$amWeather $pmWeather';
              final icon = _weatherIconFromText(description);

              weeklyForecast.add(
                DailyForecast(
                  iconPath: 'assets/images/$icon',
                  min: min,
                  max: max,
                  pop: pop,
                ),
              );
            }
          } catch (e) {
            print('중기예보 가져오기 실패: $e');
          }
        }
      }

      return WeatherData(
        address: address,
        temperature: double.tryParse(getValue('TMP') ?? ''),
        pop: getValue('POP'),
        tmx: getValue('TMX'),
        tmn: getValue('TMN'),
        skyText: _skyDescription(sky),
        weatherIcon: _weatherIcon(sky, pty),
        pm25: pm25, //
        dustGrade: dustGrade, //
        weeklyForecast: weeklyForecast,
      );
    } catch (e) {
      return WeatherData(address: '위치 확인 불가', error: e.toString());
    }
  }

  String _getProvinceFromAddress(String address) {
    List<String> parts = address.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    } else {
      return '서울특별시';
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
        place.locality,
        place.subLocality,
      ].whereType<String>().where((e) => e.isNotEmpty).toList();

      return candidates.isNotEmpty ? candidates.join(', ') : '위치 확인 불가';
    } catch (e) {
      return '위치 확인 불가';
    }
  }

  String _mapRegionToCode(String province) {
    const regionMap = {
      '서울특별시': '11B00000',
      '경기도': '11B00000',
      '강원도': '11D10000',
      '충청북도': '11C10000',
      '충청남도': '11C20000',
      '전라북도': '11F10000',
      '전라남도': '11F20000',
      '경상북도': '11H10000',
      '경상남도': '11H20000',
      '제주특별자치도': '11G00000',
    };

    return regionMap[province] ?? '11B00000'; 
  }

  String _getMidForecastTime() {
    final now = DateTime.now();
    final baseDate = now.hour < 18
        ? DateTime(now.year, now.month, now.day, 6)
        : DateTime(now.year, now.month, now.day, 18);
    return DateFormat('yyyyMMddHH00').format(baseDate);
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

  String _weatherIconFromText(String text) {
    if (text.contains('비')) return 'rain.png';
    if (text.contains('눈')) return 'snow.png';
    if (text.contains('구름')) return 'cloud.png';
    if (text.contains('흐림')) return 'cloud.png';
    if (text.contains('맑')) return 'sun.png';
    return 'sun.png';
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