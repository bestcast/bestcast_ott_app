import 'package:flutter/material.dart';

import 'app_default_colors.dart';

class CardBackgroundView extends StatelessWidget {
  final Container container;

  const CardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
