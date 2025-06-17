
class FavoriteStation {
  final String stationId;
  final String stationName;

  FavoriteStation({
    required this.stationId,
    required this.stationName,
  });

  // Firebase에 저장할 때 Map<String, dynamic> 형태로 변환
  Map<String, dynamic> toJson() => {
    'stationId': stationId,
    'stationName': stationName,
  };

  // Firebase에서 꺼낼 때 Map에서 객체로 복원
  factory FavoriteStation.fromJson(Map<dynamic, dynamic> json) {
    return FavoriteStation(
      stationId: json['stationId']?.toString() ?? '',
      stationName: json['stationName']?.toString() ?? '',
    );
  }
}
