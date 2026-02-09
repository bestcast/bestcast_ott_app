import 'package:flutter/material.dart';

class MainTransaparentCardBackgroundView extends StatelessWidget {
  final Container container;

  const MainTransaparentCardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          transform: GradientRotation(190),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.transparent.withOpacity(0.1),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: container,
    );
  }
}
