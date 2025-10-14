// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../domain/bloc/metadata.dart';
import '../../domain/repositories/video.dart';
import '../../video_viewer.dart';

class VideoQuery extends VideoQueryRepository {
  @override
  VideoViewerMetadata videoMetadata(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<VideoViewerMetadata>(context, listen: listen);
  }

  @override
  VideoViewerController video(BuildContext context, {bool listen = false}) {
    return Provider.of<VideoViewerController>(context, listen: listen);
  }

  @override
  VideoViewerStyle videoStyle(BuildContext context, {bool listen = false}) {
    return Provider.of<VideoViewerMetadata>(context, listen: listen).style;
  }

  @override
  String durationFormatter(Duration duration) {
    final int hours = duration.inHours;
    final String formatter = [
      if (hours != 0) hours,
      duration.inMinutes,
      duration.inSeconds
    ]
        .map((seg) => seg.abs().remainder(60).toString().padLeft(2, '0'))
        .join(':');
    return duration.inSeconds < 0 ? "-$formatter" : formatter;
  }
}
