import 'package:flutter/material.dart';

class BackgroundLoadingWidget extends StatelessWidget {
  const BackgroundLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 5, color: Colors.red),
      ),
    );
  }
}
