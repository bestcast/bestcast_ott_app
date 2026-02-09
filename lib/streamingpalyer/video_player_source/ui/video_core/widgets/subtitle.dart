import 'package:flutter/material.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context).subtitleStyle;
    final subtitle = query.video(context, listen: true).activeCaptionData;

    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.padding,
        child: Text(
          subtitle != null ? subtitle.text : "",
          style: style.style,
          textAlign: style.textAlign,
        ),
      ),
    );
  }
}
