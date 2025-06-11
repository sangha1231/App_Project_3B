import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/favorite_station.dart';
import 'bus_location_page.dart';

/// 글래스모피즘 커스텀 다이얼로그
Future<void> showGlassDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = '취소',
  String confirmText = '확인',
  VoidCallback? onConfirm,
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
                Text(title, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(content, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14)),
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
                        onConfirm?.call();
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

/// 글래스모피즘 버튼
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const GlassButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.height = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed != null ? 1.0 : 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _favRef;
  List<FavoriteStation> _favList = [];
  List<String> _favKeys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _favRef = FirebaseDatabase.instance.ref().child('favorite_stations').child(user.uid);
      _loadFavoritesFromFirebase();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadFavoritesFromFirebase() async {
    setState(() => _loading = true);
    final snap = await _favRef.get();
    final temp = <FavoriteStation>[];
    final keys = <String>[];
    if (snap.exists) {
      final data = snap.value;
      if (data is Map) {
        data.forEach((k, v) {
          if (v is Map) {
            temp.add(FavoriteStation.fromJson(Map<String, dynamic>.from(v)));
            keys.add(k.toString());
          }
        });
      } else if (data is List) {
        for (int i = 0; i < data.length; i++) {
          final e = data[i];
          if (e is Map) {
            temp.add(FavoriteStation.fromJson(Map<String, dynamic>.from(e)));
            keys.add(i.toString());
          }
        }
      }
    }
    setState(() {
      _favList = temp;
      _favKeys = keys;
      _loading = false;
    });
  }

  Future<void> _deleteFavorite(int index) async {
    await showGlassDialog(
      context: context,
      title: '정말 삭제하시겠습니까?',
      content: '${_favList[index].stationName}을(를) 삭제합니다.',
      confirmText: '삭제',
      onConfirm: () async {
        final key = _favKeys[index];
        await _favRef.child(key).remove();
        await _loadFavoritesFromFirebase();
      },
    );
  }

  Future<void> _clearAll() async {
    await showGlassDialog(
      context: context,
      title: '모두 삭제',
      content: '모든 즐겨찾기를 삭제하시겠습니까?',
      confirmText: '삭제',
      onConfirm: () async {
        await _favRef.remove();
        setState(() {
          _favList.clear();
          _favKeys.clear();
        });
      },
    );
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
          Positioned.fill(
            child: Image.asset('assets/images/sky.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                            separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                            itemBuilder: (_, i) {
                              final fav = _favList[i];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    color: Colors.white.withOpacity(0.2),
                                    child: ListTile(
                                      title: Text(
                                        fav.stationName,
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                      subtitle: Text(
                                        'ID: ${fav.stationId}',
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () => _deleteFavorite(i),
                                      ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BusLocationPage(
                                            stationId: fav.stationId,
                                            stationName: fav.stationName,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
                        ),
                        const SizedBox(height: 12),
                        GlassButton(
                          onPressed: _favList.isNotEmpty ? _clearAll : null,
                          child: const Text('모두 삭제', style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
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
                    icon: const Icon(Icons.home_outlined, size: 40, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  Container(height: navHeight * 0.5, width: 2, color: Colors.white54),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 40, color: Colors.white),
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
