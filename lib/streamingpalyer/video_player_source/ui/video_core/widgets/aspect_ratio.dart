import 'package:flutter/material.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';

class VideoCoreAspectRadio extends StatelessWidget {
  const VideoCoreAspectRadio({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = VideoQuery().video(context).video!;
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: child,
    );
  }
}
