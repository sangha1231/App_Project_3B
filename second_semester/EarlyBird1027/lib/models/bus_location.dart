
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

    final routeIdValue = json['routeId']?.toString() ?? '';
    final routeNameValue = json['routeName']?.toString() ?? '';

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
