// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_default_colors.dart';

class SubmitRedButton extends StatelessWidget {
  // final Function onTap;
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
            // borders: Border.all(width: 1, color: Colors.grey),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppDefaultColors.white, fontSize: 17),
        ),
      ),
    );
    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10),
    //       border: Border.all(width: 1, color: Colors.grey),
    //       color: Colors.transparent,
    //     ),
    //     child: Text(
    //       text,
    //       style: TextStyle(color: AppDefaultColors.white, fontWeight: FontWeight.bold),
    //     ),
    //   ),
    // );
  }
}
