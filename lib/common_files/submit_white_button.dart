// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_default_colors.dart';

class SubmitWhiteButton extends StatelessWidget {
  final String text;
  final IconData _iconData;
  final VoidCallback onTap;

  const SubmitWhiteButton(this.text, this._iconData,
      {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      // child: ElevatedButton.icon(
      //   onPressed: onTap,
      //   label: Text(
      //     text,
      //     style: TextStyle(color: AppDefaultColors.darkGray, fontSize: 20, fontWeight: FontWeight.w500),
      //   ),
      //   icon: Icon(
      //     _iconData,
      //     color: AppDefaultColors.darkGray,
      //     size: 40.0,
      //   ),
      //   style: ElevatedButton.styleFrom(
      //     // minimumSize: Size(0, 10),
      //     foregroundColor: AppDefaultColors.white,
      //     backgroundColor: Colors.white,
      //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(7),
      //       side: BorderSide(color: AppDefaultColors.white, width: 1),
      //       // borders: Border.all(width: 1, color: Colors.grey),
      //     ),
      //   ),
      // ),

      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          // padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
          textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // BorderRadius
            ),
          ),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Icon(
              _iconData,
              color: AppDefaultColors.darkGray,
              size: 40.0,
            ),
            SizedBox(
              width: 0,
            ),
            Text(
              text,
              style: TextStyle(
                  color: AppDefaultColors.darkGray,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
