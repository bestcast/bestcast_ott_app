// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:helpers/helpers.dart';

class VideoCoreForwardAndRewindLayout extends StatelessWidget {
  const VideoCoreForwardAndRewindLayout({
    super.key,
    required this.rewind,
    required this.forward,
  });

  final Widget rewind;
  final Widget forward;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: context.media.width / 3),
      Expanded(child: forward),
    ]);
  }
}
