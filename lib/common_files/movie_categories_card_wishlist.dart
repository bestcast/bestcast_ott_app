import 'package:flutter/material.dart';

class MovieCardWishListBackgroundView extends StatelessWidget {
  final Container container;

  const MovieCardWishListBackgroundView(this.container, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(width: 0.2, color: Colors.white),
        ),
        elevation: 5,
        child: container,
      ),
    );
  }
}
