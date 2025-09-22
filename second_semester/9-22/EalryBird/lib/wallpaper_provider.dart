// lib/wallpaper_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperProvider with ChangeNotifier {
  String _currentWallpaper = 'assets/images/wallpaper_2.jpg';

  String get currentWallpaper => _currentWallpaper;

  Future<void> loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    _currentWallpaper = prefs.getString('wallpaper') ?? 'assets/images/wallpaper_2.jpg';
    notifyListeners();
  }

  Future<void> changeWallpaper(String newWallpaper) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallpaper', newWallpaper);
    _currentWallpaper = newWallpaper;
    notifyListeners();
  }
}