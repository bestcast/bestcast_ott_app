// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/common_files/app_default_colors.dart';

class TextfieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const TextfieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text, // default type
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDefaultColors.boxDarkGray,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          cursorColor: AppDefaultColors.white,
          style: TextStyle(color: AppDefaultColors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: TextStyle(color: AppDefaultColors.white),
          ),
        ),
      ),
    );
  }
}
