// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/settings_menu/widgets/secondary_menu_item.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final double speed = video.video!.value.playbackSpeed;

    return SecondaryMenu(children: [
      for (double i = 0.5; i <= 2; i += 0.25)
        SecondaryMenuItem(
          onTap: () {
            final video = query.video(context);
            video.video!.setPlaybackSpeed(i);
            video.closeAllSecondarySettingsMenus();
          },
          text: i == 1.0 ? metadata.language.normalSpeed : "$i",
          selected: i == speed,
        ),
    ]);
  }
}
