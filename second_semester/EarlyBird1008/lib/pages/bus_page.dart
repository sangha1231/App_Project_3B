import 'dart:ui'; // 블러(blur) 효과를 위한 패키지
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 간단한 데이터 저장을 위한 패키지
import 'package:provider/provider.dart'; // 1. Provider 패키지 import
import '../models/bus_station.dart';
import '../services/bus_station_service.dart';
import '../wallpaper_provider.dart'; // 2. WallpaperProvider import
import 'bus_location_page.dart';

// 버스 정류장 검색 및 기록 관리 페이지
class BusPage extends StatefulWidget {
  const BusPage({Key? key}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  // 검색창 컨트롤러
  final _ctrl = TextEditingController();
  // 버스 정류장 데이터를 가져오는 서비스
  final _svc = BusStationService();

  // 상태 변수
  List<BusStation> _stations = []; // 검색 결과 정류장 목록
  bool _loading = false;            // 데이터 로딩 상태
  String? _error;                   // 에러 메시지
  List<String> _history = [];       // 최근 검색어 기록

  @override
  void initState() {
    super.initState();
    _loadSearchHistory(); // 페이지가 시작될 때 저장된 검색 기록을 불러옴
  }

  // SharedPreferences에서 검색 기록을 비동기로 불러오는 메소드
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('search_history') ?? [];
    });
  }

  // 검색어를 SharedPreferences에 저장하는 메소드
  Future<void> _saveSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];

    // 중복 제거 후 최신 검색어를 리스트 맨 앞으로 이동
    history.remove(query);
    history.insert(0, query);

    // 최대 5개까지만 저장
    if (history.length > 5) {
      history = history.sublist(0, 5);
    }

    await prefs.setStringList('search_history', history);
    setState(() {
      _history = history;
    });
  }

  // 검색 기록 항목을 삭제하고 SharedPreferences에 반영하는 메소드
  Future<void> _removeHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];

    history.remove(query);

    await prefs.setStringList('search_history', history);
    setState(() {
      _history = history;
    });
  }

  // 검색 로직을 실행하는 핵심 메소드
  Future<void> _search() async {
    final raw = _ctrl.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _stations = [];
        _error = null;
      });
      return;
    }

    // 검색 시작 시 로딩 상태 및 에러, 기존 검색 결과 초기화
    setState(() {
      _loading = true;
      _error = null;
      _stations = [];
    });

    try {
      // API 호출을 통해 버스 정류장 데이터 가져오기
      final list = await _svc.fetchStations(raw);
      setState(() {
        _stations = list;
        // 검색 결과가 없으면 사용자에게 메시지 표시
        if (list.isEmpty) {
          _error = '검색된 정류장이 없습니다';
        } else {
          _error = null;
        }
      });
      // 검색 결과가 있을 때만 검색 기록에 저장
      if (list.isNotEmpty) {
        await _saveSearchHistory(raw);
      }
    } catch (e) {
      // API 호출 실패 시 에러 메시지 설정
      setState(() {
        _error = e.toString();
        _stations = []; // 에러 발생 시 목록 비우기
      });
    } finally {
      // 로딩 상태 해제
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

  // UI 구성 (위젯 트리)
  @override
  Widget build(BuildContext context) {
    // 3. Provider 인스턴스 가져오기 (배경화면 동기화의 핵심)
    final wallpaperProvider = context.watch<WallpaperProvider>();

    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    const navHeight = 60.0;
    const maxWidth = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 4. 동적 배경화면 설정 (WallpaperProvider 사용)
          Positioned.fill(
            child: Image.asset(
              wallpaperProvider.currentWallpaper, // 👈 WallpaperProvider를 통해 동기화
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
                          // 뒤로가기 버튼
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
                                      // 검색 버튼
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
                    // 검색 결과 및 기록 목록... (생략)
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
                    // 검색 결과가 없고 검색 기록이 있을 때만 최근 검색어를 표시
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
                                    bottom: navHeight + bottomInset + 16,
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
                      // 검색 결과가 있을 때만 정류장 목록을 표시
                      else if (_stations.isNotEmpty)
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom: navHeight + bottomInset + 16,
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
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
      // 하단 네비게이션 바
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
                  Container(
                    height: navHeight * 0.5,
                    width: 2,
                    color: Colors.white54,
                  ),
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