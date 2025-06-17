// lib/pages/bus_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/bus_station.dart';
import '../services/bus_station_service.dart';
import 'bus_location_page.dart';

class BusPage extends StatefulWidget {
  const BusPage({Key? key}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  final _ctrl     = TextEditingController();
  final _svc      = BusStationService();
  List<BusStation> _stations = [];
  bool _loading  = false;
  String? _error;

  Future<void> _search() async {
    final raw = _ctrl.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _stations = [];
        _error    = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      final list = await _svc.fetchStations(raw);
      setState(() {
        _stations = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
    final mq          = MediaQuery.of(context);
    final screenW     = mq.size.width;
    final bottomInset = mq.padding.bottom;
    const navHeight   = 60.0;
    const maxWidth    = 400.0;

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

                    // 4) 로딩 스피너 또는 에러 메시지
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '오류: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // 5) 정류장 리스트
                    if (!_loading && _error == null)
                      Expanded(
                        child: _stations.isEmpty
                            ? const Center(
                          child: Text(
                            '검색된 정류장이 없습니다',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                            : ListView.separated(
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    title: Text(
                                      s.stationName,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
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
                                            stationId:   s.stationId,
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
