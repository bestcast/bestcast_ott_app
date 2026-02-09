import 'dart:async';

import 'package:flutter/material.dart';

import 'package:helpers/helpers.dart';

import 'package:bestcaststudios/streamingpalyer/video_player_source/data/repositories/video.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/ui/video_core/video_core.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({
    super.key,
    required this.fixedLandscape,
  });

  final bool fixedLandscape;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  final VideoQuery _query = VideoQuery();
  late Timer _systemResetTimer;

  @override
  void initState() {
    _systemResetTimer = Misc.periodic(3000, _hideSystemOverlay);
    if (widget.fixedLandscape) _setLandscapeFixed();
    super.initState();
  }

  @override
  void dispose() {
    _systemResetTimer.cancel();
    super.dispose();
  }

  Future<void> _setLandscapeFixed() async {
    await Misc.setSystemOrientation([
      ...SystemOrientation.landscapeLeft,
      ...SystemOrientation.landscapeRight
    ]);
    await _hideSystemOverlay();
  }

  Future<void> _hideSystemOverlay() async {
    await Misc.setSystemOverlay([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          _systemResetTimer.cancel();
          await _query.video(context).openOrCloseFullscreen();
          return false;
        },
        child: Center(
          child: VideoViewerCore(),
        ),
      ),
    );
  }
}
