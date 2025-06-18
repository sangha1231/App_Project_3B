// lib/models/weather_data.dart

class WeatherData {
  final String status;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final double lowestTemp;
  final String iconAsset;

  WeatherData({
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.lowestTemp,
    required this.iconAsset,
  });
}