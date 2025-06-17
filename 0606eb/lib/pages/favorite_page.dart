// lib/pages/favorite_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/favorite_station.dart';
import 'bus_location_page.dart'; // BusLocationPage 경로에 맞게 수정

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final _auth = FirebaseAuth.instance;
  late DatabaseReference _favRef;       // /favorite_stations/<uid>
  List<FavoriteStation> _favList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initFavRef();
  }

  void _initFavRef() {
    final user = _auth.currentUser;
    if (user != null) {
      _favRef = FirebaseDatabase.instance
          .ref()
          .child('favorite_stations')
          .child(user.uid);
      _loadFavoritesFromFirebase();
    } else {
      // 로그인 안 된 경우 빈 화면 표시
      setState(() {
        _favList = [];
        _loading = false;
      });
    }
  }

  Future<void> _loadFavoritesFromFirebase() async {
    setState(() => _loading = true);

    final snapshot = await _favRef.get();
    List<FavoriteStation> temp = [];
    if (snapshot.exists) {
      final data = snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        data.forEach((key, val) {
          if (val is Map) {
            temp.add(FavoriteStation.fromJson(Map<String, dynamic>.from(val)));
          }
        });
      } else if (data is List<dynamic>) {
        for (var e in data) {
          if (e is Map) {
            temp.add(FavoriteStation.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
    }

    setState(() {
      _favList = temp;
      _loading = false;
    });
  }

  Future<void> _deleteFavorite(int listIndex) async {
    // prefs와 동일하게, 화면에서 보여지는 listIndex가 실제 Key/index와 매칭되어야 합니다.
    final snapshot = await _favRef.get();
    if (snapshot.exists) {
      final data = snapshot.value;
      String? removeKey;

      if (data is Map<dynamic, dynamic>) {
        // Map으로 저장된 경우: key를 찾아서 제거
        final target = _favList[listIndex];
        data.forEach((k, v) {
          if (v is Map) {
            final fs = FavoriteStation.fromJson(Map<String, dynamic>.from(v));
            if (fs.stationId == target.stationId) {
              removeKey = k.toString();
            }
          }
        });
        if (removeKey != null) {
          await _favRef.child(removeKey!).remove();
        }
      } else if (data is List<dynamic>) {
        // List로 저장된 경우: 인덱스 그대로 삭제
        await _favRef.child(listIndex.toString()).remove();
      }
    }

    await _loadFavoritesFromFirebase();
  }

  Future<void> _clearAll() async {
    await _favRef.remove();
    setState(() {
      _favList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = 60.0;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      '정류소 즐겨찾기',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: _loading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : (_favList.isEmpty
                          ? const Center(
                        child: Text(
                          '즐겨찾기된 정류장이 없습니다.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                          : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: _favList.length,
                        separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white24),
                        itemBuilder: (_, i) {
                          final fav = _favList[i];
                          return ListTile(
                            tileColor: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            // 터치 시 BusLocationPage로 이동
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BusLocationPage(
                                    stationId: fav.stationId,
                                    stationName: fav.stationName,
                                  ),
                                ),
                              );
                            },

                            title: Text(
                              fav.stationName,
                              style:
                              const TextStyle(color: Colors.black87),
                            ),
                            subtitle: Text(
                              'ID: ${fav.stationId}',
                              style:
                              const TextStyle(color: Colors.black54),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteFavorite(i),
                            ),
                          );
                        },
                      )),
                    ),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _clearAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                      child: const Text('모두 삭제'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon:
                    const Icon(Icons.home_outlined, size: 40, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  Container(
                    height: navHeight * 0.5,
                    width: 2,
                    color: Colors.white54,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        size: 40, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
