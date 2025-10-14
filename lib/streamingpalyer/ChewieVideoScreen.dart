// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:chewie/chewie.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Project imports:
import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:bestcaststudios/common_files/loading_widget.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';

// import 'package:auto_orientation/auto_orientation.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
// import 'package:native_device_orientation/native_device_orientation.dart';

class ChewieVideoScreen extends StatefulWidget {
  String getMainMovieUrl = "";
  String getMainMovieID = "";
  String getWatchTime = "";
  int playType = 1;

  ChewieVideoScreen(
      {super.key,
      required this.getMainMovieUrl,
      required this.getMainMovieID,
      required this.getWatchTime,
      required this.playType});

  @override
  _ChewieVideoScreenState createState() => _ChewieVideoScreenState();
}

class _ChewieVideoScreenState extends State<ChewieVideoScreen> {
  late Timer _timer;

  final String _downloadUrl = "";
  final String _loadTrailerUrl = "";
  String _id = "";
  String _email = "";
  String _phone = "";
  String _name = "";
  String _firstname = "";
  String _lastname = "";
  String _dob = "";
  String _gender = "";
  String _plan = "";
  String _plan_expiry = "";
  String _photo = "";
  String _otp = "";
  String _tvcode = "";
  String _referal_code = "";
  String _credits_used = "";
  String _refferer = "";
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  TargetPlatform? _platform;
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  final double _progressValue = 0.0;
  double videoContainerRatio = 0.5;
  bool isWakeLockEnable = true;
  bool isControllerEnabled = false;

  double getScale() {
    double videoRatio = videoPlayerController.value.aspectRatio;

    if (videoRatio < videoContainerRatio) {
      ///for tall videos, we just return the inverse of the controller aspect ratio
      return videoContainerRatio / videoRatio;
    } else {
      ///for wide videos, divide the video AR by the fixed container AR
      ///so that the video does not over scale

      return videoRatio / videoContainerRatio;
    }
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _id = pref.getString(AppPreferences.id) ?? '';
      _email = pref.getString(AppPreferences.email) ?? '';
      _phone = pref.getString(AppPreferences.phone) ?? '';
      _name = pref.getString(AppPreferences.name) ?? '';
      _firstname = pref.getString(AppPreferences.firstname) ?? '';
      _lastname = pref.getString(AppPreferences.lastname) ?? '';
      _dob = pref.getString(AppPreferences.dob) ?? '';
      _gender = pref.getString(AppPreferences.gender) ?? '';
      _plan = pref.getString(AppPreferences.plan) ?? '';
      _plan_expiry = pref.getString(AppPreferences.plan_expiry) ?? '';
      _photo = pref.getString(AppPreferences.photo) ?? '';
      _otp = pref.getString(AppPreferences.otp) ?? '';
      _tvcode = pref.getString(AppPreferences.tvcode) ?? '';
      _referal_code = pref.getString(AppPreferences.referal_code) ?? '';
      _credits_used = pref.getString(AppPreferences.credits_used) ?? '';
      _refferer = pref.getString(AppPreferences.refferer) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';
    });
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
    ScreenProtector.preventScreenshotOn();
    // AutoOrientation.landscapeAutoMode();
    getInitalValue();
    initializeVideo();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);

    // NativeDeviceOrientationCommunicator()
    //     .onOrientationChanged(useSensor: true)
    //     .listen((event) {
    //   final bool isPortrait = (event == NativeDeviceOrientation.portraitUp ||
    //       event == NativeDeviceOrientation.portraitUp);
    //   final bool isLandscape =
    //       (event == NativeDeviceOrientation.landscapeLeft ||
    //           event == NativeDeviceOrientation.landscapeRight);
    //
    //   if (isPortrait && chewieController!.isFullScreen) {
    //     chewieController!.exitFullScreen();
    //     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    //   } else if (isLandscape && !chewieController!.isFullScreen) {
    //     chewieController!.enterFullScreen();
    //     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    //   }
    // });
  }

  Future initializeVideo() async {
    WakelockPlus.enable;

    print(
        "getMainMovieUrl: ${widget.getMainMovieUrl} -getWatchTime: ${widget.getWatchTime}");

    if (widget.playType == 1) {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.getMainMovieUrl));
      // videoPlayerController = VideoPlayerController.networkUrl(
      //     Uri.parse("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"));
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String videoPath = '${appDocDir.path}/${widget.getMainMovieUrl}.mp4';

      File videFile = File(videoPath);
      final decryptedVideo = await decryptFile(
          videFile, AppConfig.encryptionKey, '${widget.getMainMovieUrl}.mp4');

      // File videFile = new File(widget.getMainMovieUrl);
      // videoPlayerController = VideoPlayerController.file(videFile);
      videoPlayerController = VideoPlayerController.file(decryptedVideo);
    }

    await videoPlayerController.initialize();

    int seconds = int.parse(widget.getWatchTime);
    Duration seekPosition = Duration(seconds: seconds);
    videoPlayerController.seekTo(seekPosition);

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      // autoInitialize: true,
      // fullScreenByDefault: true,
      // allowFullScreen: true,
      allowedScreenSleep: false,
      showControls: true,
      hideControlsTimer: const Duration(seconds: 2),
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red, // Change this color as desired
      //   handleColor: Colors.redAccent,
      //   bufferedColor: Colors.grey,
      //   backgroundColor: Colors.grey,
      // ),
      subtitle: Subtitles([
        Subtitle(
          index: 0,
          start: Duration.zero,
          end: const Duration(seconds: 10),
          text: '',
        ),
        Subtitle(
          index: 1,
          start: const Duration(seconds: 10),
          end: const Duration(seconds: 20),
          text: '',
        ),
      ]),
      subtitleBuilder: (context, subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          subtitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      // customControls: CustomControls(chewieController: chewieController),
      // customControls: CustomControls(chewieController: isControllerEnabled?chewieController:null),
    );
    chewieController?.seekTo(seekPosition);

    // setState(() {
    //   chewieController?.enterFullScreen();-
    // });

    // videoPlayerController.addListener(() {
    //   setState(() {
    //     _progressValue =
    //         videoPlayerController.value.position.inSeconds.toDouble() / videoPlayerController.value.duration.inSeconds.toDouble();
    //   });
    // });

    WakelockPlus.toggle(enable: true);
    if (chewieController!.isPlaying) {
      WakelockPlus.enable;
    } else {
      WakelockPlus.disable;
    }

    chewieController?.addListener(() {
      if (chewieController!.isPlaying) {
        // WakelockPlus.toggle(enable: isWakeLockEnable);
        WakelockPlus.enable;
      } else {
        WakelockPlus.disable;
      }
    });

    // chewieController?.addListener(() {
    //   if (chewieController!.isFullScreen) {
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.portraitUp,
    //       DeviceOrientation.portraitDown,
    //     ]);
    //   } else {
    //     SystemChrome.setPreferredOrientations([
    //       DeviceOrientation.landscapeRight,
    //       DeviceOrientation.landscapeLeft,
    //     ]);
    //   }
    // });

    chewieController?.addListener(() {
      if (chewieController!.isFullScreen) {
        _platform = TargetPlatform.iOS;
      } else {
        _platform = TargetPlatform.iOS;
      }
    });

    if (chewieController != null &&
        chewieController!.videoPlayerController.value.isInitialized) {
      isControllerEnabled = true;
      setState(() {
        _platform = TargetPlatform.iOS;
      });
    }

    if (widget.playType == 1) {
      getSeekPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    // blockScreenShot();
    _platform = TargetPlatform.iOS;
    if (chewieController == null) {
      return Container(
        color: AppDefaultColors.appColor,
        child: LoadingWidget(),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        return true;
      },
      child: Theme(
        data: ThemeData(
          platform: TargetPlatform.iOS, // Change to the desired platform
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppDefaultColors.appColor,
            leading: const BackButton(color: Colors.white),
          ),
          // appBar: AppBar(
          //   backgroundColor: AppDefaultColors.appColor,
          //   leading: new IconButton(
          //       icon: new Icon(Icons.arrow_back),
          //       onPressed: () {
          //         Navigator.pop(context, true);
          //       }),
          // ),
          backgroundColor: AppDefaultColors.appColor,
          body:
              // AspectRatio(
              //   // aspectRatio: videoContainerRatio,
              //   aspectRatio: 16/9,
              //   child: Stack(
              //     children: [
              //       AspectRatio(
              //         aspectRatio: videoPlayerController.value.aspectRatio,
              //         child: Chewie(
              //           controller: chewieController!,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Container(
              //   height: 250,
              //   child: Transform.scale(
              //     child: Chewie(
              //       controller: chewieController!,
              //     ),
              //   ),
              // ),

              SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: chewieController != null &&
                        chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Stack(children: [
                        Chewie(controller: chewieController!),
                        // CustomControls(chewieController: chewieController!)
                      ])
                    : LoadingWidget(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    chewieController?.pause();
    _timer.cancel();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
    ScreenProtector.preventScreenshotOff();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('App paused');
        if (chewieController != null) {
          chewieController?.pause();
          // _isPlaying = false;
        }
        // Add your code here for when the app is paused
        break;
      case AppLifecycleState.resumed:
        print('App resumed');
        if (chewieController != null) {
          chewieController?.play();
          // _isPlaying = true;
        }
        // Add your code here for when the app is resumed
        break;
      case AppLifecycleState.inactive:
        pauseController();
        // The app is inactive, e.g., during a phone call
        break;
      case AppLifecycleState.detached:
        // The app is no longer visible
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
    // setState(() {
    //   _notification = state;
    // });
  }

  void pauseController() {
    if (chewieController!.videoPlayerController.value.isPlaying) {
      chewieController?.pause();
      // _isPlaying = false;
    }
  }

  void playController() {
    if (!chewieController!.videoPlayerController.value.isPlaying) {
      chewieController?.play();
      // _isPlaying = true;
    }
  }

  void getSeekPosition() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        if (chewieController!.videoPlayerController.value.isPlaying) {
          final Duration currentPostion =
              chewieController!.videoPlayerController.value.position;
          final Duration total =
              chewieController!.videoPlayerController.value.duration;
          var watchingSeconds = currentPostion.inSeconds;

          final percentage =
              (currentPostion.inSeconds / total.inSeconds * 100).truncate();
          print(
              "currentPostion:${currentPostion.inSeconds} - Total: ${total.inSeconds}");
          print("Position percent:  $percentage%");
          print("_userToken: $_token");

          if (currentPostion == total) {
            final postValuesWatched = {
              'watched': 1,
            };
            setUserMovies(
                _token, profileID, widget.getMainMovieID, postValuesWatched);
          } else {
            final postValues = {
              'watching': 1,
              'watch_time': watchingSeconds,
              'watched_percent': percentage,
            };
            setUserMovies(_token, profileID, widget.getMainMovieID, postValues);
          }
        }
      });
    });
  }

  // Future<void> blockScreenShot() async {
  //   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // }

  void setUserMovies(String token, String profileID, String movieID,
      Map<String, int> postValues) async {
    ApiServices()
        .postRequestToken(
            "${AppConfig.setUserMovie}$movieID?profile_id=$profileID",
            postValues,
            token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("setuserMovie_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          print('set user movie added');
        } catch (e) {
          print('UserMovieResponseException:$e');
        }
      } else {
        print("UserMovieResponseError: $response");
      }
    });
  }

  Future<File> decryptFile(
      File encryptedFile, String key, String outputFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$outputFileName';
    final outputFile = File(filePath);

    // Convert key to 32 bytes (256 bits)
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

    final encryptedBytes = await encryptedFile.readAsBytes();
    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

    await outputFile.writeAsBytes(decryptedBytes);

    return outputFile;
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomControls extends StatelessWidget {
  final ChewieController? chewieController;

  const CustomControls({super.key, required this.chewieController});

  @override
  Widget build(BuildContext context) {
    return chewieController != null &&
            chewieController!.videoPlayerController.value.isInitialized
        ? Column(
            children: [
              // Play/Pause Button
              IconButton(
                icon: Icon(
                  chewieController!.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  chewieController!.isPlaying
                      ? chewieController!.pause()
                      : chewieController!.play();
                },
              ),
              // Time Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '00:00', // Current time
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '00:00', // Total duration
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              // Forward/Backward Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.fast_rewind),
                    onPressed: () {
                      // Add backward functionality here
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.fast_forward),
                    onPressed: () {
                      // Add forward functionality here
                    },
                  ),
                ],
              ),
              // Slider for seeking
              Slider(
                onChanged: (double value) {
                  // Add seek functionality here
                },
                min: 0.0,
                max: 100.0,
                // Adjust maximum value according to the duration of the video
                value: 0.0, // Set initial value to current position
              ),
            ],
          )
        : LoadingWidget();
  }
}

class CustomControlss extends StatelessWidget {
  final ChewieController controller;

  const CustomControlss({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 200),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image(
                    image: AssetImage("images/rotate_left.png"),
                    height: 50,
                  ),
                  onPressed: () {
                    final Duration newPosition =
                        controller.videoPlayerController.value.position -
                            Duration(seconds: 10);
                    controller.seekTo(newPosition);
                  },
                ),
                SizedBox(
                  width: 150,
                ),
                IconButton(
                  icon: Image(
                    image: AssetImage("images/rotate_right.png"),
                    height: 50,
                  ),
                  onPressed: () {
                    final Duration newPosition =
                        controller.videoPlayerController.value.position +
                            Duration(seconds: 10);
                    controller.seekTo(newPosition);
                  },
                ),
                // ChewiePlaybackSpeedButton(controller: controller),
              ],
            ),
            // ChewiePlaybackControls(controller: controller),
          ],
        ),
      ),
    );
  }
}
