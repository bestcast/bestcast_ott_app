// Flutter imports:
import 'package:flutter/material.dart';

class MovieTopCardBackgroundView extends StatelessWidget {
  final Container container;

  const MovieTopCardBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.only(left: 5, right: 5),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(0),
              bottomLeft: Radius.circular(0)),
          // side: BorderSide(width: 1,color: Colors.white),
        ),
        child: container,
        // elevation: 5,
        // margin: EdgeInsets.all(10),
      ),
    );
  }
}
