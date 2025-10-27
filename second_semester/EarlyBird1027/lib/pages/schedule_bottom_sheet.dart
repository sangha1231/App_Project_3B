import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import '../database/drift_database.dart'; // 👈 [경로 확인 필요]
import 'package:drift/drift.dart' hide Column;

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key,
  }) : super(key: key);

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
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;
    const maxWidth = 400.0;

    return Container(
      height: mq.size.height / 2 + bottomInset,
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            // ▼▼▼ 1. [수정됨] 메인 배경색을 white -> grey로 변경 ▼▼▼
            color: Colors.grey.withOpacity(0.2),
            // ▲▲▲ 1. [수정됨] ▲▲▲
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildGlassTextField(
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
                                    child: _buildGlassTextField(
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
                              _buildGlassTextField(
                                label: '내용',
                                isTime: false,
                                onSaved: (String? val) {
                                  content = val;
                                },
                                validator: contentValidator,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                          child: SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  // ▼▼▼ 2. [수정됨] 버튼 배경색을 white -> grey로 변경 ▼▼▼
                                  color: Colors.grey.withOpacity(0.2),
                                  // ▲▲▲ 2. [수정됨] ▲▲▲
                                  child: ElevatedButton(
                                    onPressed: onSavePressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text(
                                      '저장',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String label,
    required bool isTime,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            // ▼▼▼ 3. [수정됨] 텍스트 필드 배경색을 white -> grey로 변경 ▼▼▼
            color: Colors.grey.withOpacity(0.2),
            // ▲▲▲ 3. [수정됨] ▲▲▲
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: TextFormField(
            keyboardType: isTime ? TextInputType.number : TextInputType.text,
            onSaved: onSaved,
            validator: validator,
            style: const TextStyle(color: Colors.black),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  // --- 기존 로직 (변경 없음) ---

  void onSavePressed() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      await GetIt.I<LocalDatabase>().createSchedule(SchedulesCompanion(
        startTime: Value(startTime!),
        endTime: Value(endTime!),
        content: Value(content!),
        date: Value(widget.selectedDate),
      ));
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