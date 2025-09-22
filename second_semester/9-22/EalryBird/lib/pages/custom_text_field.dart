import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isTime;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;

  const CustomTextField({
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.validator,
    this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        isTime
            ? SizedBox( // 시간 입력 필드의 높이를 명확하게 지정
          height: 48,
          child: TextFormField(
            controller: controller,
            onSaved: onSaved,
            validator: validator,
            cursorColor: Colors.grey,
            maxLines: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[300],
              suffixText: '시',
            ),
          ),
        )
            : Expanded( // 멀티라인 필드는 확장 가능
          child: TextFormField(
            controller: controller,
            onSaved: onSaved,
            validator: validator,
            cursorColor: Colors.grey,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            inputFormatters: [],
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }
}
