import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/bus_station.dart';
import '../services/bus_station_service.dart';
import '../wallpaper_provider.dart';
import 'bus_location_page.dart';

class BusPage extends StatefulWidget {
  const BusPage({Key? key}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  final _ctrl = TextEditingController();
  final _svc = BusStationService();

  List<BusStation> _stations = [];
  bool _loading = false;
  String? _error;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];

    history.remove(query);
    history.insert(0, query);

    if (history.length > 5) {
      history = history.sublist(0, 5);
    }

    await prefs.setStringList('search_history', history);
    setState(() {
      _history = history;
    });
  }

  Future<void> _removeHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];

    history.remove(query);

    await prefs.setStringList('search_history', history);
    setState(() {
      _history = history;
    });
  }

  Future<void> _search() async {
    final raw = _ctrl.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _stations = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _stations = [];
    });

    try {
      final list = await _svc.fetchStations(raw);
      setState(() {
        _stations = list;
        if (list.isEmpty) {
          _error = '검색된 정류장이 없습니다';
        } else {
          _error = null;
        }
      });
      if (list.isNotEmpty) {
        await _saveSearchHistory(raw);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _stations = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = context.watch<WallpaperProvider>();

    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              wallpaperProvider.currentWallpaper,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
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
                          // 검색창
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _ctrl,
                                          decoration: const InputDecoration(
                                            hintText: '정류소명 또는 ID 입력',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(color: Colors.black54),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          cursorColor: Colors.black,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.search, color: Colors.black),
                                        onPressed: _search,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 검색 결과 및 기록 목록
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '오류: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (_stations.isEmpty && _history.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  '최근 검색어',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.only(
                                    bottom: bottomInset + 16,
                                    left: 16,
                                    right: 16,
                                  ),
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemCount: _history.length,
                                  itemBuilder: (context, index) {
                                    final query = _history[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                        child: Container(
                                          color: Colors.white.withOpacity(0.2),
                                          child: ListTile(
                                            title: Text(query, style: const TextStyle(color: Colors.black)),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.black),
                                              onPressed: () => _removeHistoryItem(query),
                                            ),
                                            onTap: () {
                                              _ctrl.text = query;
                                              _search();
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_stations.isNotEmpty)
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom: bottomInset + 16,
                                left: 16,
                                right: 16,
                              ),
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemCount: _stations.length,
                              itemBuilder: (_, i) {
                                final s = _stations[i];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      color: Colors.white.withOpacity(0.2),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        title: Text(
                                          s.stationName,
                                          style: const TextStyle(
                                              color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          '${s.regionName} (${s.stationId})',
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BusLocationPage(
                                                stationId: s.stationId,
                                                stationName: s.stationName,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
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