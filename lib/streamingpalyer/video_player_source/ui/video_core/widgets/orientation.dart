// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';

class VideoCoreOrientation extends StatelessWidget {
  const VideoCoreOrientation({super.key, this.builder});

  final Widget Function(bool)? builder;

  @override
  Widget build(BuildContext _) {
    return OrientationBuilder(builder: (context, Orientation orientation) {
      final video = VideoQuery().video(context, listen: false);
      return builder!(
        video.isFullScreen && orientation == Orientation.landscape,
      );
    });
  }
}
