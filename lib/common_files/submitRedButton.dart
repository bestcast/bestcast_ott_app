import 'package:flutter/material.dart';

import 'app_default_colors.dart';

class SubmitRedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SubmitRedButton(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      // width: size.width / 2.5,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(60),
          foregroundColor: AppDefaultColors.lightGray,
          backgroundColor: AppDefaultColors.thikRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppDefaultColors.white, fontSize: 17),
        ),
      ),
    );
    //   onTap: onTap,
    //       color: Colors.transparent,
    //       text,
  }
}
