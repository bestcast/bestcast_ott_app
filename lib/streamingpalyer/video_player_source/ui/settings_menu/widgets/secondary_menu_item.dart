// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/widgets/helpers.dart';

class SecondaryMenuItem extends StatelessWidget {
  const SecondaryMenuItem({
    super.key,
    required this.onTap,
    required this.text,
    required this.selected,
  });

  final VoidCallback onTap;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: false);
    final style = metadata.style.settingsStyle;

    return CustomInkWell(
      onTap: onTap,
      child: Padding(
        padding: style.paddingSecondaryMenuItems,
        child: CustomText(
          text: text,
          selected: selected,
        ),
      ),
    );
  }
}
