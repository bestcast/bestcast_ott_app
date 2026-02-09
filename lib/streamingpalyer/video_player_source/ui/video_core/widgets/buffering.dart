import 'package:flutter/material.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/transitions.dart';

class VideoCoreBuffering extends StatelessWidget {
  const VideoCoreBuffering({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final style = query.videoStyle(context);

    return CustomOpacityTransition(
      visible: video.isBuffering,
      child: style.buffering,
    );
  }
}
