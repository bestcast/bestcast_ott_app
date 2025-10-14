// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import '../common_files/app_default_colors.dart';

// import 'package:native_device_orientation/native_device_orientation.dart';

// void main() => runApp( MainVideoPlayer());

/// Stateful widget to fetch and then display video content.
class MainVideoPlayer extends StatefulWidget {
  String getMainMovieUrl = "";
  MainVideoPlayer({super.key, required this.getMainMovieUrl});

  @override
  _MainVideoPlayer createState() => _MainVideoPlayer();
}

class _MainVideoPlayer extends State<MainVideoPlayer> {
  late VideoPlayerController _controller;
  final bool _isPlaying = false;
  final bool _isRated = false;
  double _progressValue = 0.0;
  late ChewieController _chewieController;
  late MaterialDesktopControls _materialDesktopControls;

  // double _aspectRatio = 16 / 9;
  final double _aspectRatio = 3 / 2;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    print("getMainMovieUrl: ${widget.getMainMovieUrl}");
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
        // 'https://d2vkl8k9v6nxyr.cloudfront.net/Movies/Anbulla_Ghilli_Encoded/Anbulla_Ghilli.m3u8'))
        widget.getMainMovieUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        // setState(() {});

        _controller.addListener(() {
          setState(() {
            _progressValue = _controller.value.position.inSeconds.toDouble() /
                _controller.value.duration.inSeconds.toDouble();
          });
        });
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: false,
      showControls: false,
      showControlsOnInitialize: false,
      aspectRatio: 0.6,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    // NativeDeviceOrientationCommunicator().onOrientationChanged(useSensor: true).listen((event) {
    //   final bool isPortrait = (event == NativeDeviceOrientation.portraitUp || event == NativeDeviceOrientation.portraitUp);
    //   final bool isLandscape =
    //       (event == NativeDeviceOrientation.landscapeLeft || event == NativeDeviceOrientation.landscapeRight);
    //
    //   if (isPortrait && _chewieController.isFullScreen) {
    //     _chewieController.exitFullScreen();
    //     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    //   } else if (isLandscape && !_chewieController.isFullScreen) {
    //     _chewieController.enterFullScreen();
    //     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    //   }
    // });

    // _chewieController = ChewieController(
    //     allowedScreenSleep: false,
    //     allowFullScreen: true,
    //     // deviceOrientationsAfterFullScreen: [
    //     //   DeviceOrientation.landscapeRight,
    //     //   DeviceOrientation.landscapeLeft,
    //     //   // DeviceOrientation.portraitUp,
    //     //   // DeviceOrientation.portraitDown,
    //     // ],
    //     videoPlayerController: _controller,
    //     aspectRatio: _aspectRatio,
    //     // autoInitialize: true,
    //     // autoPlay: true,
    //     showControls: true,
    //     fullScreenByDefault: true
    //
    //     // subtitle: Subtitles([
    //     //   Subtitle(
    //     //     index: 0,
    //     //     start: Duration.zero,
    //     //     end: const Duration(seconds: 10),
    //     //     text: 'Hello from subtitles',
    //     //   ),
    //     //   Subtitle(
    //     //     index: 1,
    //     //     start: const Duration(seconds: 10),
    //     //     end: const Duration(seconds: 20),
    //     //     text: 'Whats up? :)',
    //     //   ),
    //     // ]),
    //     // subtitleBuilder: (context, subtitle) => Container(
    //     //   padding: const EdgeInsets.all(10.0),
    //     //   child: Text(
    //     //     subtitle,
    //     //     style: const TextStyle(color: Colors.white),
    //     //   ),
    //     // ),
    //     );
    //
    // _chewieController.enterFullScreen();

    _chewieController.addListener(() {
      if (_chewieController.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      body: SafeArea(
        child: PopScope(
            onPopInvoked: (didPop) {
              SystemChrome.setPreferredOrientations(DeviceOrientation.values);
            },
            child: Container(
              child: AspectRatio(
                aspectRatio: 32 / 16,
                child: Chewie(
                  controller: _chewieController,
                ),
              ),
            )
            // child: Container(
            //   child: Chewie(
            //     controller: _chewieController,
            //   ),
            // ),
            ),
      ),
    );
  }
}
