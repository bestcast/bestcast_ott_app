import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:helpers/helpers.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/common_files/background_loading_widget.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/video_viewer.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import 'components/quiz_overlay.dart';
import 'components/quiz_start_dialog.dart';
import 'package:bestcaststudios/streamingpalyer/models/quiz_data.dart';

/// SUMMARY
/// 1. Models
/// 2. Constants
/// 3. Main Aplications
/// 4. Pages
/// 5. Video Viewer Widgets
/// 6. Movie Card Widgets
/// 7. Misc Widgets

//------//
//MODELS//
//------//
enum MovieStyle { card, page }

class Movie {
  const Movie({
    required this.thumbnail,
    required this.title,
    required this.category,
    this.isFavorite = false,
  });

  final String thumbnail, title, category;
  final bool isFavorite;
}

class Serie extends Movie {
  const Serie({
    required this.source,
    required super.thumbnail,
    required super.title,
    required super.category,
    super.isFavorite,
  });

  final Map<String, SerieSource> source;
}

class SerieSource {
  const SerieSource({
    required this.thumbnail,
    required this.source,
  });

  final Map<String, String> source;
  final String thumbnail;
}

class CustomVideoViewerStyle extends VideoViewerStyle {
  CustomVideoViewerStyle({required Movie movie, required BuildContext context})
      : super(
          textStyle: context.textTheme.titleMedium,
          playAndPauseStyle: PlayAndPauseWidgetStyle(background: context.color.primary),
          progressBarStyle: ProgressBarStyle(
            bar: BarStyle.progress(color: context.color.primary),
          ),
          header: Container(
            width: double.infinity,
            padding: kAllPadding,
            child: Headline6(
              movie.title,
              style: TextStyle(color: AppDefaultColors.white),
            ),
          ),
        );
}

//---------//
//CONSTANTS//
//---------//
const double kButtonHeight = 48;
const double kCardAspectRatio = 0.75;

const double kPadding = 20;
const double kSectionPadding = 40;
const Margin kAllPadding = Margin.all(kPadding);
const Margin kAllSectionPadding = Margin.all(kSectionPadding);

const BorderRadius kAllBorderRadius = BorderRadius.all(
  Radius.circular(kPadding),
);

//---------------//
//MAIN APLICATION//
//---------------//

//--------------------//
//VIDEO VIEWER WIDGETS//
//--------------------//
// ignore: must_be_immutable
class MovieVideoViewer extends StatefulWidget {
  MovieVideoViewer({super.key, required this.movieTitle, required this.thumbnail, required this.getMainMovieUrl, required this.getMainMovieID, required this.getWatchTime, required this.playType});

  String getMainMovieUrl = "";
  String movieTitle = "";
  String thumbnail = "";
  String getMainMovieID = "";
  String getWatchTime = "";
  int playType = 1;

  @override
  _MovieVideoViewerState createState() => _MovieVideoViewerState();
}

class _MovieVideoViewerState extends State<MovieVideoViewer> {
  final VideoViewerController _controller = VideoViewerController();
  Timer? _timer;
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  bool isSeekDuration = false;
  bool enableController = false;
  late File _videoFile;

  // Quiz State
  bool _hasAskedQuiz = false;
  bool _quizEnabled = false;
  bool _isQuizActive = false;
  int _currentQuizIndex = 0;
  Timer? _quizGapTimer;
  QuizResponse? _quizResponse;

  // Import for QuizData
  // import 'package:bestcaststudios/streamingpalyer/models/quiz_data.dart';

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    Timer(Duration(seconds: 2), () {
      setState(() {
        enableController = true;
      });
      // Trigger Quiz Opt-In separate from controller enable to ensure UI is ready
      // Future: Replace fixed delay with API configuration or specific timestamp check
      Future.delayed(const Duration(seconds: 1), () {
        print("DEBUG: Checking trigger condition: mounted=$mounted, _hasAskedQuiz=$_hasAskedQuiz");
        if (mounted && !_hasAskedQuiz) {
          _showQuizOptIn();
        }
      });
    });
    super.initState();
    ScreenProtector.preventScreenshotOn();

    getInitalValue();
    initializeVideo();
    print("GetMainMovieUrl: ${widget.getMainMovieUrl}");
    print("getWatchTime: ${widget.getWatchTime}");
    if (widget.playType == 1) {
      getSeekPosition();
    }

    if (widget.getWatchTime != "" && widget.getWatchTime != "0") {
      isSeekDuration = true;
      Timer(Duration(seconds: 3), () {
        setState(() {
          isSeekDuration = false;
        });
        int seconds = int.parse(widget.getWatchTime);
        _controller.seekTo(Duration(seconds: seconds));
        _controller.play();
        print("Watch_Time:${widget.getWatchTime}");
      });
    }
  }

  void initializeVideo() async {
    if (widget.playType == 2) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String videoPath = '${appDocDir.path}/${widget.getMainMovieUrl}.mp4';

      _videoFile = File(videoPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    var movie = Movie(
      thumbnail: widget.getMainMovieUrl,
      title: widget.movieTitle,
      category: "",
      isFavorite: true,
    );

    return VideoViewerOrientation(
      controller: _controller,
      child: Stack(children: [
        Center(
          child: enableController
              ? VideoViewer(
                  controller: _controller,
                  onFullscreenFixLandscape: true, //TODO change if need as false
                  source: {
                    widget.movieTitle: VideoSource(
                      video: widget.playType == 1
                          ? VideoPlayerController.network(
                              // "https://bestcast-mobile-download-movies.s3.amazonaws.com/Movies/trailer-720p.mp4",
                              widget.getMainMovieUrl,
                            )
                          : VideoPlayerController.file(
                              // "https://bestcast-mobile-download-movies.s3.amazonaws.com/Movies/trailer-720p.mp4",
                              _videoFile,
                            ),
                    ),
                  },
                  style: CustomVideoViewerStyle(movie: movie, context: context),
                )
              : null,
        ),
        if (isSeekDuration) BackgroundLoadingWidget(),
        if (_quizResponse != null && _isQuizActive && _currentQuizIndex < _quizResponse!.questions.length)
          QuizOverlay(
            question: _quizResponse!.questions[_currentQuizIndex],
            questionIndex: _currentQuizIndex,
            totalQuestions: _quizResponse!.questions.length,
            onComplete: () {
              setState(() {
                _isQuizActive = false;
                try {
                  _controller.play();
                } catch (e) {
                  print("DEBUG: Error resuming video after quiz: $e");
                }
                _currentQuizIndex++;

                // Set timer for next question if available
                if (_quizResponse != null && _currentQuizIndex < _quizResponse!.questions.length) {
                  print("DEBUG: Starting 1 minute gap timer for next question (Index: $_currentQuizIndex)");
                  _quizGapTimer?.cancel();
                  // Debug: Reduced to 10 seconds for faster testing (will revert to 1 minute later)
                  _quizGapTimer = Timer(const Duration(seconds: 10), () {
                    print("DEBUG: Quiz Gap Timer Fired!");
                    if (mounted && _quizEnabled) {
                      setState(() {
                        print("DEBUG: Activating Next Question!");
                        _isQuizActive = true;
                        try {
                          _controller.pause();
                        } catch (e) {
                          print("DEBUG: Error pausing video for quiz: $e");
                        }
                      });
                    } else {
                      print("DEBUG: Quiz Timer Fired but aborted: mounted=$mounted, quizEnabled=$_quizEnabled");
                    }
                  });
                } else {
                  print("DEBUG: Quiz sequence finished");
                }
              });
            },
          ),
      ]),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quizGapTimer?.cancel();
    super.dispose();
    ScreenProtector.preventScreenshotOff();
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';

      print("_userToken1: $_token");

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';

      // Fetch Quiz Data
      if (_token.isNotEmpty && profileID.isNotEmpty) {
        getQuizData(_token, profileID, widget.getMainMovieID);
      }
    });
  }

  void getSeekPosition() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        if (_controller.isPlaying) {
          final Duration currentPostion = _controller.position;
          final Duration total = _controller.duration;
          var watchingSeconds = currentPostion.inSeconds;

          final percentage = (currentPostion.inSeconds / total.inSeconds * 100).truncate();
          print("currentPostion:${currentPostion.inSeconds} - Total: ${total.inSeconds}");
          print("Position percent:  $percentage%");
          print("_userToken: $_token");
          print("_watchingSeconds: $watchingSeconds");

          if (currentPostion == total) {
            final postValuesWatched = {
              'watched': 1,
            };
            setUserMovies(_token, profileID, widget.getMainMovieID, postValuesWatched);
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

  void setUserMovies(String token, String profileID, String movieID, Map<String, int> postValues) async {
    ApiServices().postRequestToken("${AppConfig.setUserMovie}$movieID?profile_id=$profileID", postValues, token).then((response) async {
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

  Future<File> decryptFile(File encryptedFile, String key, String outputFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$outputFileName';
    final outputFile = File(filePath);

    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

    final encryptedBytes = await encryptedFile.readAsBytes();
    final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

    await outputFile.writeAsBytes(decryptedBytes);

    return outputFile;
  }

  void _showQuizOptIn() {
    print("DEBUG: _showQuizOptIn called");
    if (!mounted) {
      print("DEBUG: _showQuizOptIn aborted - widget not mounted");
      return;
    }

    setState(() {
      _hasAskedQuiz = true;
    });

    // Pause video while asking
    try {
      if (_controller.isPlaying) {
        _controller.pause();
        print("DEBUG: Video paused for quiz");
      }
    } catch (e) {
      print("DEBUG: Error pausing video: $e");
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizStartDialog(
        onSelection: (bool accepted) {
          print("DEBUG: Quiz selection: $accepted");
          Navigator.of(context).pop(); // Close dialog
          if (mounted) {
            setState(() {
              _quizEnabled = accepted;
              _quizEnabled = accepted;
              if (accepted && _quizResponse != null && _quizResponse!.questions.isNotEmpty) {
                // Schedule First Question
                _currentQuizIndex = 0;
                final firstQuestion = _quizResponse!.questions[0];
                int startDelaySeconds = firstQuestion.popupTime;
                if (startDelaySeconds <= 0) startDelaySeconds = 0; // Immediate if 0

                print("DEBUG: Scheduling 1st Question in $startDelaySeconds seconds (popup_time: ${firstQuestion.popupTime})");

                if (startDelaySeconds == 0) {
                  _isQuizActive = true;
                  // Pause immediately if showing immediately
                  try {
                    _controller.pause();
                  } catch (e) {}
                } else {
                  _quizGapTimer?.cancel();
                  _quizGapTimer = Timer(Duration(seconds: startDelaySeconds), () {
                    if (mounted && _quizEnabled) {
                      setState(() {
                        print("DEBUG: 1st Question Timer Fired!");
                        _isQuizActive = true;
                        try {
                          _controller.pause();
                        } catch (e) {
                          print("DEBUG: Error pausing: $e");
                        }
                      });
                    }
                  });
                }
              }
            });

            // Resume video if we are WAITING for the quiz (startDelay > 0)
            // If startDelay == 0, we already paused above.
            // BUT strict instruction: "Resume video" block was here.
            // If we schedule a timer, we should Play video.
            // If we show immediately, we should Pause.

            // Refined Logic for Play/Pause:
            // 1. If accepted and StartDelay > 0: Play Video (wait for timer).
            // 2. If accepted and StartDelay == 0: Pause Video (show quiz).
            // 3. If !accepted: Play Video.

            bool shouldPlay = !accepted;
            if (accepted && _quizResponse != null && _quizResponse!.questions.isNotEmpty) {
              if (_quizResponse!.questions[0].popupTime * 60 > 0) {
                shouldPlay = true;
              } else {
                shouldPlay = false; // Immediate quiz, ensure paused
              }
            }

            try {
              if (shouldPlay) {
                _controller.play();
              } else {
                // Ensure paused if immediate
                _controller.pause();
              }
            } catch (e) {
              print("DEBUG: Error handling video state: $e");
            }
          }
        },
      ),
    );
  }

// # -----------------QUIZ-FETCH-API-----------------

  void getQuizData(String token, String profileID, String movieID) {
    final postValues = {
      'movie_id': movieID,
      'user_id': profileID,
      'device_token': token.split("|")[1],
    };
    ApiServices().postRequestToken(AppConfig.getQuiz, postValues, _token).then((response) {
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'success') {
            setState(() {
              _quizResponse = QuizResponse.fromJson(jsonResponse);
              print("Quiz loaded: ${_quizResponse?.total} questions");
              // Check if we should show opt-in (if we missed the initial timer check)
              if (mounted && !_hasAskedQuiz && enableController) {
                // Or we can rely on the timer. But if data comes late, we might want to trigger it?
                // For now, let's just stick to the timer trigger or user manual trigger if we had one.
                // But wait, if data loads LATER than the timer (which is 3s), the timer check found null data and skipped.
                // So we SHOULD trigger it here if it hasn't been asked.
                _showQuizOptIn();
              }
            });
          }
        } catch (e) {
          print("Quiz Parse Error: $e");
        }
      } else {
        print("Quiz API Error: ${response.statusCode}");
      }
    });
  }
}

class SerieVideoViewer extends StatefulWidget {
  const SerieVideoViewer(this.serie, {super.key});

  final Serie serie;

  @override
  _SerieVideoViewerState createState() => _SerieVideoViewerState();
}

class _SerieVideoViewerState extends State<SerieVideoViewer> {
  String episode = "";
  final VideoViewerController controller = VideoViewerController();
  late MapEntry<String, SerieSource> initial;

  @override
  void initState() {
    initial = widget.serie.source.entries.first;
    episode = initial.key;
    super.initState();
    ScreenProtector.preventScreenshotOn();
  }

  void onEpisodeThumbnailTap(MapEntry<String, SerieSource> entry) async {
    final String episodeName = entry.key;
    if (episode != episodeName) {
      final SerieSource qualities = entry.value;
      final String url = qualities.source.entries.first.value;

      late Map<String, VideoSource> sources;

      if (url.contains("m3u8")) {
        sources = await VideoSource.fromM3u8PlaylistUrl(url);
      } else {
        sources = VideoSource.fromNetworkVideoSources(qualities.source);
      }

      final MapEntry<String, VideoSource> video = sources.entries.first;

      controller.closeSettingsMenu();

      await controller.changeSource(
        inheritPosition: false, //RESET SPEED TO NORMAL AND POSITION TO ZERO
        source: video.value,
        name: video.key,
      );

      episode = episodeName;
      controller.source = sources;
      setState(() {});
    } else {
      controller.closeSettingsMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoViewerOrientation(
      controller: controller,
      child: VideoViewer(
        controller: controller,
        enableChat: true,
        onFullscreenFixLandscape: false,
        source: VideoSource.fromNetworkVideoSources(initial.value.source),
        style: CustomVideoViewerStyle(movie: widget.serie, context: context).copyWith(
          chatStyle: const VideoViewerChatStyle(chat: SerieChat()),
          settingsStyle: SettingsMenuStyle(
            paddingBetweenMainMenuItems: 10,
            items: [
              SettingsMenuItem(
                themed: SettingsMenuItemThemed(
                  title: "Episodes",
                  subtitle: episode,
                  icon: Icon(
                    Icons.view_module_outlined,
                    color: Colors.white,
                  ),
                ),
                secondaryMenuWidth: 300,
                secondaryMenu: Padding(
                  padding: const Margin.top(5),
                  child: Center(
                    child: Container(
                      child: Wrap(
                        spacing: kPadding,
                        runSpacing: kPadding,
                        children: [
                          for (var entry in widget.serie.source.entries)
                            SerieEpisodeThumbnail(
                              title: entry.key,
                              url: entry.value.thumbnail,
                              onTap: () => onEpisodeThumbnailTap(entry),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoViewerOrientation extends StatefulWidget {
  const VideoViewerOrientation({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final VideoViewerController controller;

  @override
  _VideoViewerOrientationState createState() => _VideoViewerOrientationState();
}

class _VideoViewerOrientationState extends State<VideoViewerOrientation> {
  late StreamSubscription<NativeDeviceOrientation> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
    ScreenProtector.preventScreenshotOff();
  }

  @override
  void initState() {
    _subscription = NativeDeviceOrientationCommunicator().onOrientationChanged().listen(_onOrientationChanged);
    super.initState();
    ScreenProtector.preventScreenshotOn();
  }

  void _onOrientationChanged(NativeDeviceOrientation orientation) {
    final bool isFullScreen = widget.controller.isFullScreen;
    final bool isLandscape = orientation == NativeDeviceOrientation.landscapeLeft || orientation == NativeDeviceOrientation.landscapeRight;
    if (!isFullScreen && isLandscape) {
      printGreen("OPEN FULLSCREEN");
      widget.controller.openFullScreen();
    } else if (isFullScreen && !isLandscape) {
      printRed("CLOSING FULLSCREEN");
      widget.controller.closeFullScreen();
      Misc.delayed(300, () {
        Misc.setSystemOverlay(SystemOverlay.values);
        Misc.setSystemOrientation(SystemOrientation.values);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SerieChat extends StatefulWidget {
  const SerieChat({super.key});

  @override
  _SerieChatState createState() => _SerieChatState();
}

class _SerieChatState extends State<SerieChat> {
  late Timer timer;

  final ScrollController _scontroller = ScrollController();
  final List<String> _texts = [];

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
    ScreenProtector.preventScreenshotOff();
  }

  @override
  void initState() {
    timer = Misc.periodic(500, () {
      if (mounted) {
        _texts.add("HELLO");
        _scontroller.jumpTo(_scontroller.position.maxScrollExtent);
        setState(() {});
      }
    });
    super.initState();
    ScreenProtector.preventScreenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      color: Colors.black.withOpacity(0.8),
      child: ListView.builder(
        controller: _scontroller,
        itemCount: _texts.length,
        itemBuilder: (_, int index) {
          return Text(
            "x$index ${_texts[index]}",
            style: context.textTheme.titleMedium,
          );
        },
      ),
    );
  }
}

class SerieEpisodeThumbnail extends StatelessWidget {
  const SerieEpisodeThumbnail({
    super.key,
    required this.title,
    required this.url,
    required this.onTap,
  });

  final VoidCallback onTap;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    const Margin padding = Margin.all(kPadding / 4);
    return ClipRRect(
      borderRadius: kAllBorderRadius,
      child: SizedBox(
        width: kSectionPadding * 2,
        height: kSectionPadding * 2,
        child: Stack(alignment: AlignmentDirectional.topEnd, children: [
          Positioned.fill(child: Image.network(url, fit: BoxFit.cover)),
          Padding(
            padding: padding,
            child: ClipRRect(
              borderRadius: kAllBorderRadius,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: padding,
                  color: context.color.card.withOpacity(0.16),
                  child: Subtitle1(title),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SplashTap(
              onTap: onTap,
              child: Container(color: Colors.transparent),
            ),
          ),
        ]),
      ),
    );
  }
}
