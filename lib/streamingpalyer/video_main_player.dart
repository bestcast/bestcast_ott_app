// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import '../common_files/app_default_colors.dart';

// import 'package:native_device_orientation/native_device_orientation.dart';

void main() => runApp(const VideoMainPlayer());

/// Stateful widget to fetch and then display video content.
class VideoMainPlayer extends StatefulWidget {
  const VideoMainPlayer({super.key});

  @override
  _VideoMainPlayer createState() => _VideoMainPlayer();
}

class _VideoMainPlayer extends State<VideoMainPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  final bool _isRated = false;
  double _progressValue = 0.0;
  late ChewieController _chewieController;
  late MaterialDesktopControls _materialDesktopControls;

  // double _aspectRatio = 16 / 9;
  final double _aspectRatio = 3 / 2;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
        'https://d2vkl8k9v6nxyr.cloudfront.net/Movies/Anbulla_Ghilli_Encoded/Anbulla_Ghilli.m3u8'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});

        _controller.addListener(() {
          setState(() {
            _progressValue = _controller.value.position.inSeconds.toDouble() /
                _controller.value.duration.inSeconds.toDouble();
          });
        });
      });

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
    //     // aspectRatio: _aspectRatio,
    //     autoInitialize: true,
    //     autoPlay: true,
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

    // _chewieController.enterFullScreen();

    // _chewieController.addListener(() {
    //   if (_chewieController.isFullScreen) {
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.landscapeRight,
    //       DeviceOrientation.landscapeLeft,
    //     ]);
    //   } else {
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.portraitUp,
    //       DeviceOrientation.portraitDown,
    //     ]);
    //   }
    // });
  }

  @override
  dispose() {
    _controller.dispose();
    _chewieController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SafeArea(
  //       child: PopScope(
  //         onPopInvoked: (didPop) {
  //           SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  //         },
  //         child: Container(
  //           child: AspectRatio(
  //             aspectRatio: 32 / 16,
  //             child: Chewie(
  //               controller: _chewieController,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      // appBar: AppBar(
      //   backgroundColor: AppDefaultColors.appColor,
      //   leading: const BackButton(color: Colors.white),
      // ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Center(
            child: Container(
              child: _controller.value.isInitialized
                  ? RotatedBox(
                      quarterTurns:
                          orientation == Orientation.landscape ? 3 : 0,
                      child: Column(
                        children: [
                          Stack(children: <Widget>[
                            AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                            LayoutBuilder(builder: (context, constraints) {
                              return Slider(
                                value: _progressValue,
                                activeColor: AppDefaultColors.thikRed,
                                inactiveColor: AppDefaultColors.white,
                                onChanged: (double value) {
                                  setState(() {
                                    _progressValue = value;
                                    final Duration newPosition = Duration(
                                        seconds: (_controller
                                                    .value.duration.inSeconds *
                                                _progressValue)
                                            .toInt());
                                    _controller.seekTo(newPosition);
                                  });
                                },
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Image(
                                      image:
                                          AssetImage("images/rotate_left.png"),
                                      height: 30,
                                    ),
                                    onPressed: () {
                                      _controller.seekTo(Duration(
                                          seconds: _controller
                                                  .value.position.inSeconds -
                                              10));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPlaying
                                            ? _controller.pause()
                                            : _controller.play();
                                        _isPlaying = !_isPlaying;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Image(
                                      image:
                                          AssetImage("images/rotate_right.png"),
                                      height: 30,
                                    ),
                                    onPressed: () {
                                      _controller.seekTo(Duration(
                                          seconds: _controller
                                                  .value.position.inSeconds +
                                              10));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ]),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     IconButton(
                          //       icon: Image(
                          //         image: AssetImage("images/rotate_left.png"),
                          //         height: 30,
                          //       ),
                          //       onPressed: () {
                          //         _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
                          //       },
                          //     ),
                          //     IconButton(
                          //       icon: Icon(
                          //         _isPlaying ? Icons.pause : Icons.play_arrow,
                          //         color: Colors.white,
                          //         size: 40,
                          //       ),
                          //       onPressed: () {
                          //         setState(() {
                          //           _isPlaying ? _controller.pause() : _controller.play();
                          //           _isPlaying = !_isPlaying;
                          //         });
                          //       },
                          //     ),
                          //     IconButton(
                          //       icon: Image(
                          //         image: AssetImage("images/rotate_right.png"),
                          //         height: 30,
                          //       ),
                          //       onPressed: () {
                          //         _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
                          //       },
                          //     ),
                          //   ],
                          // ),
                          // LinearProgressIndicator(
                          //   value: _controller.value.buffered.isNotEmpty
                          //       ? _controller.value.buffered.last.end.inSeconds / _controller.value.duration.inSeconds
                          //       : 0.0,
                          // ),
                        ],
                      ),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: AppDefaultColors.thikRed,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
