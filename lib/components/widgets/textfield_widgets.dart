import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '/common_files/app_default_colors.dart';

// ! Text Field Widget
class TextfieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Widget? prefixIcon;

  const TextfieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        cursorColor: AppDefaultColors.primaryRed,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 0),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14.5),
        ),
      ),
    );
  }
}

// ! SMS Text Field Widget
class SMStextfieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const SMStextfieldWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                '+91',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 20,
                color: Colors.white24,
              ),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              cursorColor: AppDefaultColors.primaryRed,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Mobile number',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ! WhatsApp Text Field Widget
class WhatsApptextfieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(dynamic)? onChanged;

  const WhatsApptextfieldWidget({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: IntlPhoneField(
        controller: controller,
        keyboardType: TextInputType.phone,
        cursorColor: AppDefaultColors.primaryRed,
        style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 0.5),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Mobile number",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14.5),
        ),
        dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20),
        dropdownTextStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        disableLengthCheck: true,
        initialCountryCode: 'IN',
        languageCode: "en",
        onChanged: onChanged,
      ),
    );
  }
}
