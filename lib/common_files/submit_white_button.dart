import 'package:flutter/material.dart';

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
      //   onPressed: onTap,
      //     text,
      //     _iconData,
      //     color: AppDefaultColors.darkGray,
      //     size: 40.0,
      //     foregroundColor: AppDefaultColors.white,
      //     backgroundColor: Colors.white,
      //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,

      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(Colors.white),
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
