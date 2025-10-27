import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../models/favorite_station.dart';
import '../models/bus_location.dart';
import '../services/bus_location_service.dart';
import '../wallpaper_provider.dart';

Future<void> showGlassDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = '확인',
  VoidCallback? onConfirm,
  String cancelText = '취소',
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A), fontSize: 18, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(cancelText, style: const TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onConfirm != null) onConfirm();
                      },
                      child: Text(confirmText, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class BusLocationPage extends StatefulWidget {
  final String stationId;
  final String stationName;

  const BusLocationPage({Key? key, required this.stationId, required this.stationName}) : super(key: key);

  @override
  State<BusLocationPage> createState() => _BusLocationPageState();
}

class _BusLocationPageState extends State<BusLocationPage> {
  final _auth = FirebaseAuth.instance;
  late DatabaseReference _favRef;
  Map<String, FavoriteStation> _favMap = {};
  bool _loadingFav = true;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _favRef = FirebaseDatabase.instance.ref().child('favorite_stations').child(user.uid);
      _setupFavoritesListener();
    } else {
      setState(() {
        _favMap = {};
        _loadingFav = false;
        _isFavorited = false;
      });
    }
  }

  void _setupFavoritesListener() {
    _favRef.onValue.listen((event) {
      if (mounted) {
        final data = event.snapshot.value;
        final temp = <String, FavoriteStation>{};
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              temp[key.toString()] = FavoriteStation.fromJson(Map<String, dynamic>.from(value));
            }
          });
        }
        setState(() {
          _favMap = temp;
          _isFavorited = _favMap.values.any((f) => f.stationId == widget.stationId);
          _loadingFav = false;
        });
      }
    });
  }

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) {
      await showGlassDialog(
        context: context,
        title: '로그인 필요',
        content: '즐겨찾기를 사용하려면 로그인해주세요.',
      );
      return;
    }
    final existingFavKey = _favMap.keys.firstWhere(
          (key) => _favMap[key]!.stationId == widget.stationId,
      orElse: () => '',
    );

    if (existingFavKey.isNotEmpty) {
      await _favRef.child(existingFavKey).remove();
    } else {
      final newFav = FavoriteStation(stationId: widget.stationId, stationName: widget.stationName);
      await _favRef.push().set(newFav.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    const maxWidth = 400.0;
    final wallpaperProvider = context.watch<WallpaperProvider>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset( wallpaperProvider.currentWallpaper, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 44, height: 44,
                                color: Colors.white.withOpacity(0.2),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                  ),
                                  child: Text(
                                    '${widget.stationName} 도착정보',
                                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _loadingFav
                              ? const SizedBox(width: 44, height: 44, child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                              : ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 44, height: 44,
                                color: Colors.white.withOpacity(0.2),
                                child: IconButton(
                                  icon: Icon(_isFavorited ? Icons.star : Icons.star_border, color: _isFavorited ? Colors.orangeAccent : Colors.white),
                                  onPressed: _toggleFavorite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FutureBuilder<List<BusLocation>>(
                        future: BusLocationService().fetchLocations(widget.stationId),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Text('오류: ${snap.error}', style: const TextStyle(color: Colors.white)),
                            );
                          }
                          final data = snap.data ?? [];
                          if (data.isEmpty) {
                            return const Center(child: Text('도착 정보가 없습니다.', style: TextStyle(color: Colors.white70)));
                          }
                          return GridView.builder(
                            padding: EdgeInsets.only(top: 8, bottom: bottomInset + 16, left: 16, right: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1,
                            ),
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final b = data[i];
                              final min1 = b.predictTime1 ~/ 60;
                              final sec1 = b.predictTime1 % 60;
                              final min2 = b.predictTime2 ~/ 60;
                              final sec2 = b.predictTime2 % 60;
                              final busLabel = b.routeName.isNotEmpty ? b.routeName : b.routeId;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    color: Colors.white.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$busLabel번 버스', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            text: '첫 번째: ',
                                            style: const TextStyle(color: Colors.black, fontSize: 14),
                                            children: [
                                              TextSpan(text: '$min1시간 ', style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600)),
                                              TextSpan(text: '$sec1분 후 도착', style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Text('남은 정류장: ${b.locationNo1}개', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                        const SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            text: '두 번째: ',
                                            style: const TextStyle(color: Colors.black, fontSize: 14),
                                            children: [
                                              TextSpan(text: '$min2시간 ', style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600)),
                                              TextSpan(text: '$sec2분 후 도착', style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Text('남은 정류장: ${b.locationNo2}개', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}