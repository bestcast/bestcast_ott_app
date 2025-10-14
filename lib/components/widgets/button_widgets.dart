// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/common_files/app_default_colors.dart';

class SendButtonWidgets extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SendButtonWidgets(this.text, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(60),
        backgroundColor: AppDefaultColors.thikRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
