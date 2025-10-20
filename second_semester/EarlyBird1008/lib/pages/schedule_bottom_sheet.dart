import 'dart:ui'; // 1. BackdropFilter를 사용하기 위해 import 합니다.
import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'colors.dart';

import 'package:get_it/get_it.dart';
import '../database/drift_database.dart';
import 'package:drift/drift.dart' hide Column;

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key}) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: formKey,
      child: SafeArea(
        // 2. ClipRRect로 감싸 위쪽 모서리를 둥글게 만듭니다.
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          child: Container(
            height: MediaQuery.of(context).size.height / 2 + bottomInset,
            // 3. 반투명 배경과 블러 효과를 적용합니다.
            color: Colors.white.withOpacity(0.7), // 불투명한 흰색에서 반투명으로 변경
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: '시작 시간',
                            isTime: true,
                            onSaved: (String? val) {
                              startTime = int.parse(val!);
                            },
                            validator: timeValidator,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: CustomTextField(
                            label: '종료 시간',
                            isTime: true,
                            onSaved: (String? val) {
                              endTime = int.parse(val!);
                            },
                            validator: timeValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: CustomTextField(
                        label: '내용',
                        isTime: false,
                        onSaved: (String? val) {
                          content = val;
                        },
                        validator: contentValidator,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onSavePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR,
                        ),
                        child: const Text('저장'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSavePressed() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            date: Value(widget.selectedDate),
          )
      );
      Navigator.of(context).pop();
    }
  }

  String? timeValidator(String? val) {
    if (val == null) {
      return '값을 입력해주세요';
    }
    int? number;
    try {
      number = int.parse(val);
    } catch (e) {
      return '숫자를 입력해주세요';
    }
    if (number < 0 || number > 24) {
      return '0시부터 24시 사이를 입력해주세요';
    }
    return null;
  }

  String? contentValidator(String? val) {
    if (val == null || val.isEmpty) {
      return '값을 입력해주세요';
    }
    return null;
  }
}