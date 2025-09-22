import 'dart:math' as math;

class LatXLngY {
  final int nx;
  final int ny;
  LatXLngY({required this.nx, required this.ny});
}

class GeoConverter {
  static const double RE = 6371.00877; // 지구 반지름(km)
  static const double GRID = 5.0; 
  static const double SLAT1 = 30.0;
  static const double SLAT2 = 60.0;
  static const double OLON = 126.0;
  static const double OLAT = 38.0;
  static const double XO = 43;
  static const double YO = 136;

  static LatXLngY toGrid(double lat, double lng) {
    const double DEGRAD = math.pi / 180.0;

    final double re = RE / GRID;
    final double slat1 = SLAT1 * DEGRAD;
    final double slat2 = SLAT2 * DEGRAD;
    final double olon = OLON * DEGRAD;
    final double olat = OLAT * DEGRAD;

    final double sn = math.log(math.cos(slat1) / math.cos(slat2)) /
        math.log(math.tan(math.pi * 0.25 + slat2 * 0.5) /
            math.tan(math.pi * 0.25 + slat1 * 0.5));
    final double sf = math.pow(math.tan(math.pi * 0.25 + slat1 * 0.5), sn) *
        math.cos(slat1) /
        sn;
    final double ro =
        re * sf / math.pow(math.tan(math.pi * 0.25 + olat * 0.5), sn);
    final double ra =
        re * sf / math.pow(math.tan(math.pi * 0.25 + lat * DEGRAD * 0.5), sn);
    double theta = lng * DEGRAD - olon;
    if (theta > math.pi) theta -= 2.0 * math.pi;
    if (theta < -math.pi) theta += 2.0 * math.pi;
    theta *= sn;

    final int nx = (ra * math.sin(theta) + XO + 0.5).floor();
    final int ny = (ro - ra * math.cos(theta) + YO + 0.5).floor();

    return LatXLngY(nx: nx, ny: ny);
  }
}

