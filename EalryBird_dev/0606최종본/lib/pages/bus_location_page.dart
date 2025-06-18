// lib/pages/bus_location_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/favorite_station.dart';       // 위에서 만든 모델
import '../models/bus_location.dart';
import '../services/bus_location_service.dart';

class BusLocationPage extends StatefulWidget {
  final String stationId;
  final String stationName;

  const BusLocationPage({
    Key? key,
    required this.stationId,
    required this.stationName,
  }) : super(key: key);

  @override
  State<BusLocationPage> createState() => _BusLocationPageState();
}

class _BusLocationPageState extends State<BusLocationPage> {
  final _auth = FirebaseAuth.instance;
  late DatabaseReference _favRef; // /favorite_stations/<uid>
  List<FavoriteStation> _favList = [];
  bool _loadingFav = true; // 즐겨찾기 로딩 중 표시용

  @override
  void initState() {
    super.initState();
    _initFavoriteReference();
  }

  void _initFavoriteReference() {
    final user = _auth.currentUser;
    if (user != null) {
      _favRef = FirebaseDatabase.instance
          .ref()
          .child('favorite_stations')
          .child(user.uid);
      _loadFavoritesFromFirebase();
    } else {
      // 로그인되어 있지 않으면 빈 상태로 두고 로딩 완료 처리
      setState(() {
        _favList = [];
        _loadingFav = false;
      });
    }
  }

  Future<void> _loadFavoritesFromFirebase() async {
    setState(() => _loadingFav = true);
    final snapshot = await _favRef.get();
    List<FavoriteStation> temp = [];
    if (snapshot.exists) {
      final data = snapshot.value;
      // data가 Map<dynamic, dynamic> 혹은 List<dynamic> 형태일 수 있으므로 처리
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
      _loadingFav = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) {
      // 로그인 안 된 경우
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("로그인 필요"),
          content: const Text("즐겨찾기를 사용하려면 로그인해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    // 이미 즐겨찾기 되어 있는지 체크
    final existsIndex = _favList.indexWhere(
          (f) => f.stationId == widget.stationId,
    );

    if (existsIndex >= 0) {
      // 이미 즐겨찾기되어 있으므로 제거
      // Firebase에서 인덱스를 유추하여 삭제
      final snapshot = await _favRef.get();
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map<dynamic, dynamic>) {
          // Map으로 저장된 상태: key는 "0","1",...
          String? removeKey;
          data.forEach((k, v) {
            if (v is Map) {
              final fs = FavoriteStation.fromJson(Map<String, dynamic>.from(v));
              if (fs.stationId == widget.stationId) {
                removeKey = k.toString();
              }
            }
          });
          if (removeKey != null) {
            await _favRef.child(removeKey!).remove();
          }
        } else if (data is List<dynamic>) {
          // List로 저장된 상태: 그냥 인덱스 기반
          final idxList = _favList.indexWhere(
                (f) => f.stationId == widget.stationId,
          );
          if (idxList >= 0) {
            await _favRef.child(idxList.toString()).remove();
          }
        }
      }
    } else {
      // 새로 추가: push()가 아니라 인덱스 순서대로 넣어도 무방하지만,
      // set(childKey) 형태를 쓰려면 아래처럼 간단히 리스트 전체를 덮어써도 됩니다.

      // 1) 로컬 리스트에 추가
      _favList.add(
        FavoriteStation(
          stationId: widget.stationId,
          stationName: widget.stationName,
        ),
      );
      // 2) Firebase에 덮어쓰기
      final payload = _favList.map((f) => f.toJson()).toList();
      await _favRef.set(payload);
    }

    // 변경 후 다시 불러오기
    await _loadFavoritesFromFirebase();
  }

  bool get _isFavorited {
    return _favList.any((f) => f.stationId == widget.stationId);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    const navHeight = 60.0;
    const maxWidth = 400.0;

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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 1) 뒤로 가기 + 정류장명 + 즐겨찾기 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          // 뒤로 가기 버튼 (glass)
                          ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.white.withOpacity(0.2),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 정류장 이름 (glass panel)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3), width: 1),
                                  ),
                                  child: Text(
                                    '${widget.stationName} 도착정보',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 즐겨찾기 토글 버튼
                          _loadingFav
                              ? const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                              : ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.white.withOpacity(0.2),
                                child: IconButton(
                                  icon: Icon(
                                    _isFavorited
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: _isFavorited
                                        ? Colors.orangeAccent
                                        : Colors.white,
                                  ),
                                  onPressed: _toggleFavorite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 2) 도착정보 리스트 (GridView)
                    Expanded(
                      child: FutureBuilder<List<BusLocation>>(
                        future: BusLocationService()
                            .fetchLocations(widget.stationId),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Text(
                                '오류: ${snap.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          final data = snap.data ?? [];
                          if (data.isEmpty) {
                            return const Center(
                              child: Text(
                                '도착 정보가 없습니다.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: navHeight + bottomInset + 16,
                              left: 16,
                              right: 16,
                            ),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final b = data[i];
                              final min1 = b.predictTime1 ~/ 60;
                              final sec1 = b.predictTime1 % 60;
                              final min2 = b.predictTime2 ~/ 60;
                              final sec2 = b.predictTime2 % 60;
                              final busLabel = b.routeName.isNotEmpty
                                  ? b.routeName
                                  : b.routeId;

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    color: Colors.white.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$busLabel번 버스',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            text: '첫 번째: ',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '$min1시간 ',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '$sec1분 후 도착',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '남은 정류장: ${b.locationNo1}개',
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(height: 6),
                                        RichText(
                                          text: TextSpan(
                                            text: '두 번째: ',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '$min2시간 ',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '$sec2분 후 도착',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '남은 정류장: ${b.locationNo2}개',
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12),
                                        ),
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

      // ─── BOTTOM NAVIGATION BAR ───────────────────────
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
                    icon: const Icon(Icons.home_outlined,
                        size: 40, color: Colors.white),
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
