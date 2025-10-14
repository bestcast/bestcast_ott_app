// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_default_colors.dart';

class SubmitButtonDesign extends StatelessWidget {
  final String text;
  final bool isbuttonEnabled;
  final VoidCallback onTap;

  const SubmitButtonDesign(this.text, this.isbuttonEnabled,
      {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: isbuttonEnabled ? onTap : null,
        style: isbuttonEnabled
            ? ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(60),
                foregroundColor: AppDefaultColors.thikRed,
                backgroundColor: AppDefaultColors.thikRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppDefaultColors.thikRed, width: 2),
                ),
              )
            : ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(60),
                foregroundColor: AppDefaultColors.lightGray,
                backgroundColor: AppDefaultColors.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color: AppDefaultColors.textLightGray, width: 2),
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
