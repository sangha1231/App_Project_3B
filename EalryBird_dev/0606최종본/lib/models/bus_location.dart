// lib/models/bus_location.dart

/// 경기도 버스 도착정보를 담는 모델 클래스
/// JSON 필드가 int로 되어 있을 수도 있으므로 toString()을 사용합니다.
class BusLocation {
  final String routeId;      // 노선ID (문자 or 숫자 모두 문자열로 저장)
  final String routeName;      // 노선명 (문자 or 숫자 모두 문자열로 저장)
  final int locationNo1;     // 첫 번째 버스까지 남은 정류장 수
  final int predictTime1;    // 첫 번째 버스까지 남은 시간(초)
  final int seatCnt1;        // 첫 번째 버스 잔여 좌석수
  final int locationNo2;     // 두 번째 버스까지 남은 정류장 수
  final int predictTime2;    // 두 번째 버스까지 남은 시간(초)
  final int seatCnt2;        // 두 번째 버스 잔여 좌석수

  BusLocation({
    required this.routeId,
    required this.routeName,
    required this.locationNo1,
    required this.predictTime1,
    required this.seatCnt1,
    required this.locationNo2,
    required this.predictTime2,
    required this.seatCnt2,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    // routeId, routeNm 은 문자열이거나 숫자로 올 수도 있으니 toString() 사용
    final routeIdValue = json['routeId']?.toString() ?? '';
    final routeNameValue = json['routeName']?.toString() ?? '';

    // 나머지 필드는 숫자 혹은 문자열 형태로 올 수 있으므로
    // String → int.parse, 또는 num → toInt() 등을 활용
    int parseIntField(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is double) {
        return value.toInt();
      }
      return 0;
    }

    return BusLocation(
      routeId:      routeIdValue,
      routeName:      routeNameValue,
      locationNo1:  parseIntField(json['locationNo1']),
      predictTime1: parseIntField(json['predictTime1']),
      seatCnt1:     parseIntField(json['seatCnt1']),
      locationNo2:  parseIntField(json['locationNo2']),
      predictTime2: parseIntField(json['predictTime2']),
      seatCnt2:     parseIntField(json['seatCnt2']),
    );
  }
}
