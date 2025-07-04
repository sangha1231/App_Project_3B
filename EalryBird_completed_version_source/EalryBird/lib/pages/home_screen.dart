import 'package:flutter/material.dart';
import 'package:EarlyBird/pages/main_calander.dart';
import 'package:EarlyBird/pages/schedule_card.dart';
import 'package:EarlyBird/pages/today_banner.dart';
import 'package:EarlyBird/pages/schedule_bottom_sheet.dart';
import 'colors.dart';
import 'package:EarlyBird/database/drift_database.dart';
import 'package:get_it/get_it.dart';

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
    return Scaffold(
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
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate){

    setState((){
      this.selectedDate = selectedDate;
  });
  }
}