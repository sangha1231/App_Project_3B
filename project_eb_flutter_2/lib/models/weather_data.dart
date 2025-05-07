class WeatherData {
  final String location;
  final double temperature;
  final String sky;
  final String pop;
  final int pm25;
  final String dustGrade;
  final DateTime? updatedAt;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.sky,
    required this.pop,
    required this.pm25,
    required this.dustGrade,
    required this.updatedAt,
  });
}

