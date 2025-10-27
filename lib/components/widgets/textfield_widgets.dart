// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// Project imports:
import '/common_files/app_default_colors.dart';

// ! Text Field Widget
class TextfieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const TextfieldWidget({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDefaultColors.boxDarkGray,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        cursorColor: AppDefaultColors.white,
        style: TextStyle(color: AppDefaultColors.white, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400),
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
        color: AppDefaultColors.boxDarkGray,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '+91',
                style: TextStyle(
                  color: AppDefaultColors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              cursorColor: AppDefaultColors.white,
              style: TextStyle(
                color: AppDefaultColors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Mobile number',
                hintStyle: TextStyle(color: Colors.grey.shade400),
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
        color: AppDefaultColors.boxDarkGray,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: IntlPhoneField(
        controller: controller,
        keyboardType: TextInputType.phone,
        cursorColor: AppDefaultColors.white,
        style: TextStyle(color: AppDefaultColors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Mobile number",
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        dropdownIcon: Icon(Icons.arrow_drop_down, color: AppDefaultColors.white),
        dropdownTextStyle: TextStyle(color: AppDefaultColors.white),
        disableLengthCheck: true,
        initialCountryCode: 'IN',
        languageCode: "en",
        onChanged: onChanged,
      ),
    );
  }
}
