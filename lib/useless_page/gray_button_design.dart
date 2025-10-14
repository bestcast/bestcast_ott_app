// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../common_files/app_default_colors.dart';

class SubmitGreyButtonDesign extends StatelessWidget {
  // final Function onTap;
  final String text;
  final VoidCallback onTap;

  const SubmitGreyButtonDesign(this.text, {super.key, required this.onTap});

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
            // borders: Border.all(width: 1, color: Colors.grey),
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
