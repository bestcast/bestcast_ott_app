// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:chewie/chewie.dart';
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

class ChewieVideoScreen1 extends StatefulWidget {
  String getMainMovieUrl = "";
  String getMainMovieID = "";
  int playType = 1;

  ChewieVideoScreen1(
      {super.key,
      required this.getMainMovieUrl,
      required this.getMainMovieID,
      required this.playType});

  @override
  _ChewieVideoScreen1State createState() => _ChewieVideoScreen1State();
}

class _ChewieVideoScreen1State extends State<ChewieVideoScreen1> {
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
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    super.initState();
    ScreenProtector.preventScreenshotOn();
    // AutoOrientation.landscapeAutoMode();
    initializeVideo();
    getInitalValue();
  }

  Future initializeVideo() async {
    WakelockPlus.enable;

    print("getMainMovieUrl: ${widget.getMainMovieUrl}");

    if (widget.playType == 1) {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.getMainMovieUrl));
      // videoPlayerController = VideoPlayerController.networkUrl(
      //     Uri.parse("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"));
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String videoPath = '${appDocDir.path}/${widget.getMainMovieUrl}.mp4';

      // File videFile = new File(widget.getMainMovieUrl);
      File videFile = File(videoPath);
      videoPlayerController = VideoPlayerController.file(videFile);
    }

    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      // autoInitialize: true,
      // fullScreenByDefault: true,
      // allowFullScreen: true,
      // allowedScreenSleep: false,
      // showControls: true,
      // hideControlsTimer: const Duration(seconds: 2),
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red, // Change this color as desired
      //   handleColor: Colors.redAccent,
      //   bufferedColor: Colors.grey,
      //   backgroundColor: Colors.grey,
      // ),
    );

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

    chewieController?.addListener(() {
      if (chewieController!.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      }
    });

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

              Center(
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
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    chewieController?.pause();
    _timer.cancel();
    WakelockPlus.disable();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
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
}
