import 'package:flutter/cupertino.dart';

import 'package:helpers/helpers/widgets/align.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/overlay/widgets/background.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/overlay/widgets/bottom.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/settings_menu/settings_menu.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/play_and_pause.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/transitions.dart';

class VideoCoreOverlay extends StatelessWidget {
  const VideoCoreOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final style = query.videoMetadata(context, listen: true).style;
    final controller = query.video(context, listen: true);

    final header = style.header;
    final bool overlayVisible = controller.isShowingOverlay;

    return CustomOpacityTransition(
      visible: !controller.isShowingThumbnail,
      child: Stack(children: [
        if (header != null)
          CustomSwipeTransition(
            axisAlignment: 1.0,
            visible: overlayVisible,
            child: Align(
              alignment: Alignment.topLeft,
              child: GradientBackground(
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
                child: header,
              ),
            ),
          ),
        BottomCenterAlign(
          child: CustomSwipeTransition(
            visible: overlayVisible,
            axisAlignment: -1.0,
            child: const OverlayBottom(),
          ),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) => CustomOpacityTransition(
            visible: overlayVisible,
            child: const Center(
              child: PlayAndPause(type: PlayAndPauseType.center),
            ),
          ),
        ),
        CustomOpacityTransition(
          visible: controller.isShowingSettingsMenu,
          child: const SettingsMenu(),
        ),
      ]),
    );
  }
}
