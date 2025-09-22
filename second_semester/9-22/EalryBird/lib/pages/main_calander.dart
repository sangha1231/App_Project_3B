import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'colors.dart';

class MainCalander extends StatelessWidget{

  final OnDaySelected onDaySelected;
  final DateTime selectedDate;

  MainCalander({
    required this.onDaySelected,
    required this.selectedDate
  });

  @override
  Widget build(BuildContext context){

    return TableCalendar(
  locale: 'ko_KR',
  onDaySelected: onDaySelected,
  selectedDayPredicate: (date) =>
    date.year == selectedDate.year &&
    date.month == selectedDate.month &&
    date.day == selectedDate.day,
  focusedDay: selectedDate,
  firstDay: DateTime(2025, 5, 1),
  lastDay: DateTime(2026, 1, 1),
  headerStyle: HeaderStyle(
    titleCentered: true,
    formatButtonVisible: false,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16.0,
    ),
  ),
  calendarStyle: CalendarStyle(
    isTodayHighlighted: true,
    defaultDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      color: LIGHT_GREY_COLOR,
    ),
    weekendDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      color: LIGHT_GREY_COLOR,
    ),
    selectedDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      border: Border.all(
        color: PRIMARY_COLOR,
        width: 1.0,
      ),
    ),
    defaultTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: DARK_GREY_COLOR,
    ),
    weekendTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: DARK_GREY_COLOR,
    ),
    selectedTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: DARK_GREY_COLOR,
    ),
  ),
);

  }
}