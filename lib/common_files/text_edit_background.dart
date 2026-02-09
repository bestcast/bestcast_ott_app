import 'package:flutter/material.dart';

import 'app_default_colors.dart';

class TextEditBackground extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const TextEditBackground(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: size.width / 2.5,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(60),
          foregroundColor: AppDefaultColors.lightGray,
          backgroundColor: AppDefaultColors.boxDarkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: AppDefaultColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
