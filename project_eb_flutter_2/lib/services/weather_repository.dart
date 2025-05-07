import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weather_data.dart';

class WeatherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<WeatherData> fetchWeatherFromFirestore(String region) async {
    final doc = await _firestore.collection('weather').doc(region).get();
    final data = doc.data();

    if (data == null) {
      throw Exception('No weather data found for $region');
    }

    return WeatherData(
      location: data['location'] ?? region,
      temperature: (data['temperature'] as num).toDouble(),
      sky: data['sky'].toString(),          // 앱에서 string 기대 시
      pop: data['pop'].toString(),          // 앱에서 string 기대 시
      pm25: data['pm25'] ?? 0,
      dustGrade: data['dustGrade'] ?? '',
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? ''),
    );
  }
}
