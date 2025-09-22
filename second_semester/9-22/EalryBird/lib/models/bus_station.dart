
class BusStation {
  final String stationId;   // 정류장 ID (예: "22026")
  final String stationName; // 정류장명 (예: "가산디지털단지역")
  final String regionName;  // 지역명 (예: "서울" 또는 "경기도")
  final double longitude;   // 경도
  final double latitude;    // 위도

  BusStation({
    required this.stationId,
    required this.stationName,
    required this.regionName,
    required this.longitude,
    required this.latitude,
  });

  factory BusStation.fromJson(Map<String, dynamic> j) {
    return BusStation(
      stationId:   j['stationId'].toString(),
      stationName: j['stationName'] as String,
      regionName:  j['regionName'] as String,
      longitude:   (j['x'] as num).toDouble(),
      latitude:    (j['y'] as num).toDouble(),
    );
  }
}
