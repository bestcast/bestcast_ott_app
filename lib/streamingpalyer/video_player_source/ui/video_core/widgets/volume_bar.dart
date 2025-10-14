// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/transitions.dart';

class VideoCoreVolumeBar extends StatelessWidget {
  const VideoCoreVolumeBar({
    super.key,
    required this.visible,
    required this.progress,
  });

  final bool visible;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context).volumeBarStyle;
    final double axisAlignment;

    if (style.alignment == Alignment.topRight ||
        style.alignment == Alignment.centerRight ||
        style.alignment == Alignment.bottomRight) {
      axisAlignment = -1.0;
    } else {
      axisAlignment = 1.0;
    }

    return CustomSwipeTransition(
      visible: visible,
      axisAlignment: axisAlignment,
      axis: Axis.horizontal,
      child: _VolumeBar(progress: progress),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context).volumeBarStyle;

    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.margin,
        child: ClipRRect(
          borderRadius: style.bar.borderRadius,
          child: SizedBox(
            height: style.bar.height,
            width: style.bar.width,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(color: style.bar.background),
                Container(
                  height: progress! * style.bar.height,
                  color: style.bar.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
