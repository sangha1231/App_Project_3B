// lib/pages/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. provider 패키지 import
import 'package:EarlyBird/pages/main_calander.dart';
import 'package:EarlyBird/pages/schedule_card.dart';
import 'package:EarlyBird/pages/today_banner.dart';
import 'package:EarlyBird/pages/schedule_bottom_sheet.dart';
import './colors.dart'; // 상대 경로로 수정 가능성이 있습니다.
import 'package:EarlyBird/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import '../wallpaper_provider.dart'; // 2. WallpaperProvider import

class HomeScreen extends StatefulWidget{

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context){
    // 3. Provider를 통해 현재 배경화면 경로를 가져옵니다.
    final wallpaperProvider = context.watch<WallpaperProvider>();

    // 4. Stack을 사용해 배경 이미지와 Scaffold를 겹치도록 합니다.
    return Stack(
      children: [
        // 배경 이미지
        Positioned.fill(
          child: Image.asset(
            wallpaperProvider.currentWallpaper,
            fit: BoxFit.cover,
          ),
        ),

        // 기존 Scaffold 구조 (배경을 투명하게 설정)
        Scaffold(
          backgroundColor: Colors.transparent, // 5. Scaffold 배경을 투명하게 만들어 이미지가 보이게 합니다.
          floatingActionButton: FloatingActionButton(
            backgroundColor: PRIMARY_COLOR,
            onPressed: (){
              showModalBottomSheet(
                  context: context,
                  isDismissible: true,
                  builder: (_) => ScheduleBottomSheet(selectedDate: selectedDate,),
                  isScrollControlled: true
              );
            },
            child: Icon(
              Icons.add,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [

                MainCalander(selectedDate: selectedDate, onDaySelected: onDaySelected,),

                SizedBox(height: 8.0,),

                StreamBuilder<List<Schedule>>(
                  stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                  builder: (context, snapshot){
                    return TodayBanner(selectedDate: selectedDate,
                        count: snapshot.data?.length ?? 0
                    );
                  },
                ),

                SizedBox(height: 8.0,),

                Expanded(child: StreamBuilder<List<Schedule>>(
                    stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return Container();
                      }

                      return ListView.builder(itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                          final schedule = snapshot.data![index];
                          return Dismissible(key: ObjectKey(schedule.id),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (DismissDirection direction){
                              GetIt.I<LocalDatabase>().removeSchedule(schedule.id);
                            },
                            child: Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 8.0,
                                right: 8.0),
                              child: ScheduleCard(
                                startTime: schedule.startTime,
                                endTime: schedule.endTime,
                                content: schedule.content,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate){
    setState((){
      this.selectedDate = selectedDate;
    });
  }
}