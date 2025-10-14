// Flutter imports:
import 'package:flutter/material.dart';

class ContentBackground extends StatelessWidget {
  final Container container;

  const ContentBackground(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.grey),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.8)
          ],
        ),
      ),
      child: container,
    );
  }
}
