// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/helpers.dart';

enum PlayAndPauseType { center, bottom }

class PlayAndPause extends StatelessWidget {
  const PlayAndPause({
    super.key,
    required this.type,
    this.padding,
  });

  final PlayAndPauseType type;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoMetadata(context).style.playAndPauseStyle;
    final bool isPlaying = !controller.isPlaying;

    return SplashCircularIcon(
      onTap: controller.playOrPause,
      padding: padding,
      child: type == PlayAndPauseType.bottom
          ? isPlaying
              ? style.play
              : style.pause
          : controller.position >= controller.duration
              ? style.replayWidget
              : isPlaying
                  ? style.playWidget
                  : style.pauseWidget,
    );
  }
}
