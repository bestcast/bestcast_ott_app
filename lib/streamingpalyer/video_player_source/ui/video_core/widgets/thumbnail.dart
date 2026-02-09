import 'package:flutter/material.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/play_and_pause.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/transitions.dart';

class VideoCoreThumbnail extends StatelessWidget {
  const VideoCoreThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoStyle(context);

    final Widget? thumbnail = style.thumbnail;

    return CustomOpacityTransition(
      visible: controller.isShowingThumbnail,
      child: Stack(children: [
        if (thumbnail != null) Positioned.fill(child: thumbnail),
        Center(child: PlayAndPause(type: PlayAndPauseType.center)),
        Positioned.fill(
          child: GestureDetector(
            onTap: () async {
              await controller.play();
              controller.showAndHideOverlay();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ]),
    );
  }
}
