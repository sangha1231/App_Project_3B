class WeatherData {
  final String address;
  final double? temperature;
  final String? pop;
  final String? tmx;
  final String? tmn;
  final String? skyText;
  final String? weatherIcon;
  final String? error;

  WeatherData({
    required this.address,
    this.temperature,
    this.pop,
    this.tmx,
    this.tmn,
    this.skyText,
    this.weatherIcon,
    this.error,
  });
}
