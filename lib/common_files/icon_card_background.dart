import 'package:flutter/material.dart';

import 'app_default_colors.dart';

class IconCardBackgroundView extends StatelessWidget {
  final Container container;

  const IconCardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            AppDefaultColors.lightGray.withOpacity(0.8),
            AppDefaultColors.lightBlue.withOpacity(0.8)
          ],
        ),
      ),
      child: container,
    );
  }
}
