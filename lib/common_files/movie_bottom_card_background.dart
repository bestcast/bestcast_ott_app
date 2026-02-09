import 'package:flutter/material.dart';

class MovieBottomCardBackgroundView extends StatelessWidget {
  final Container container;

  const MovieBottomCardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        semanticContainer: true,
        margin: EdgeInsets.only(left: 5.0, right: 5.0),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(5),
              bottomLeft: Radius.circular(5)),
        ),
        elevation: 5,
        child: container,
      ),
    );
  }
}
