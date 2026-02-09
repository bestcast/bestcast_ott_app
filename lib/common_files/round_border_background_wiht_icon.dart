import 'package:flutter/material.dart';

import 'app_default_colors.dart';

class RoundIconBackgroundView extends StatelessWidget {
  final String text;
  final IconData _iconData;
  final VoidCallback onTap;

  const RoundIconBackgroundView(this.text, this._iconData,
      {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: size.width / 2.5,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ElevatedButton.icon(
          onPressed: onTap,
          label: Text(
            text,
            style: TextStyle(
                color: AppDefaultColors.white,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          ),
          icon: Icon(
            _iconData,
            color: Colors.white,
            size: 30.0,
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(0, 40),
            foregroundColor: AppDefaultColors.lightGray,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: AppDefaultColors.white, width: 1)
                ),
          ),
        ),
      ),
    );
  }
}
