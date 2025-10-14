// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';

class VideoCorePlayer extends StatefulWidget {
  const VideoCorePlayer({super.key});

  @override
  _VideoCorePlayerState createState() => _VideoCorePlayerState();
}

class _VideoCorePlayerState extends State<VideoCorePlayer> {
  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final style = query.videoStyle(context);
    final controller = VideoQuery().video(context, listen: true);

    return Center(
      child: AspectRatio(
        aspectRatio: controller.video!.value.aspectRatio,
        child: !controller.isChangingSource
            ? VideoPlayer(controller.video!)
            : Container(color: Colors.black, child: style.loading),
      ),
    );
  }
}
