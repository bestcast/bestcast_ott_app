// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_default_colors.dart';

class SliderCardBackgroundView extends StatelessWidget {
  final Container container;

  const SliderCardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          transform: GradientRotation(190),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.black.withOpacity(0.8),
            Colors.transparent.withOpacity(0.3),
            AppDefaultColors.darkBlue.withOpacity(0.9),
          ],
        ),
      ),
      child: container,
    );
  }
}
