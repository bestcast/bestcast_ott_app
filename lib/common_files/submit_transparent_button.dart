import 'package:flutter/material.dart';

import 'app_default_colors.dart';

class SubmitTransparentButton extends StatelessWidget {
  final String text;
  final IconData _iconData;
  final VoidCallback onTap;

  const SubmitTransparentButton(this.text, this._iconData,
      {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              AppDefaultColors.boxDarkGray.withOpacity(0.5)),
          foregroundColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
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
              color: AppDefaultColors.white,
              size: 40.0,
            ),
            SizedBox(
              width: 0,
            ),
            Text(
              text,
              style: TextStyle(
                  color: AppDefaultColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
