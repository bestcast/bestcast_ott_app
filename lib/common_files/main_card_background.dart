import 'package:flutter/material.dart';

class MainCardBackgroundView extends StatelessWidget {
  final Container container;

  const MainCardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(width: 1, color: Colors.white),
        ),
        elevation: 5,
        child: container,
      ),
    );
  }
}
