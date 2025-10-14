// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_default_colors.dart';

class RoundBackgroundView extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const RoundBackgroundView(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width:  100,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, 40),
          foregroundColor: AppDefaultColors.lightGray,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: AppDefaultColors.white, width: 1)
              // borders: Border.all(width: 1, color: Colors.grey),
              ),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: AppDefaultColors.white,
              fontSize: 15,
              fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
