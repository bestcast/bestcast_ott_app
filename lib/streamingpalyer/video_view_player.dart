import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bestcaststudios/streamingpalyer/components/quiz_reward_claim.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:helpers/helpers.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_files/background_loading_widget.dart';
import '../streamingpalyer/video_player_source/video_viewer.dart';
import '../streamingpalyer/models/quiz_data.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import 'components/quiz_dialog.dart';
import 'components/quiz_start_dialog.dart';
import 'package:flutter/foundation.dart';

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

const double kButtonHeight = 48;
const double kCardAspectRatio = 0.75;
const double kPadding = 20;
const double kSectionPadding = 40;
const Margin kAllPadding = Margin.all(kPadding);
const Margin kAllSectionPadding = Margin.all(kSectionPadding);
const BorderRadius kAllBorderRadius = BorderRadius.all(Radius.circular(kPadding));

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
  Timer? _seekTimer;
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String userID = "";
  String profilePictureID = "";

  bool isSeekDuration = false;
  bool enableController = false;
  late File _videoFile;

  // Quiz State
  bool _useStaticQuizTimeForTesting = true; // Toggle to true to force exactly 10 seconds between popups
  bool _hasAskedQuiz = false;
  bool _quizEnabled = false;
  bool _isQuizActive = false;
  int _currentQuizIndex = 0;
  Timer? _quizGapTimer;
  QuizResponse? _quizResponse;
  bool _isLoadingQuiz = false;

  // New variables for pause/resume validation
  Duration? _quizGapRemaining;
  DateTime? _quizGapStartedAt;
  bool? _wasPlayingLast;

  void _startQuizGapTimer(Duration duration) {
    _quizGapTimer?.cancel();
    _quizGapRemaining = duration;
    _quizGapStartedAt = DateTime.now();
    print("DEBUG: Starting quiz gap timer for ${duration.inSeconds} seconds");
    _quizGapTimer = Timer(duration, _onQuizGapTimerFired);
  }

  void _onQuizGapTimerFired() {
    if (mounted && _quizEnabled) {
      setState(() {
        print("DEBUG: Quiz Gap Timer Fired!");
        _isQuizActive = true;
        _quizGapRemaining = null;
        _quizGapStartedAt = null;
        try {
          _controller.pause();
          if (_controller.isFullScreen) {
            _controller.closeFullScreen();
          }
        } catch (e) {
          print("DEBUG: Error pausing video for quiz: $e");
        }
      });
    } else {
      print("DEBUG: Quiz Timer Fired but aborted: mounted=$mounted, quizEnabled=$_quizEnabled");
    }
  }

  void _videoPlayerListener() {
    if (!mounted) return;
    final bool currentPlaying = _controller.isPlaying;
    if (_wasPlayingLast != currentPlaying) {
      final bool wasPlaying = _wasPlayingLast ?? false;
      _wasPlayingLast = currentPlaying;
      if (currentPlaying && !wasPlaying) {
        _onResumeVideo();
      } else if (!currentPlaying && wasPlaying) {
        _onPauseVideo();
      }
    }
  }

  void _onPauseVideo() {
    if (_quizGapTimer != null && _quizGapTimer!.isActive && _quizGapStartedAt != null) {
      final elapsed = DateTime.now().difference(_quizGapStartedAt!);
      _quizGapRemaining = _quizGapRemaining! - elapsed;
      if (_quizGapRemaining! < Duration.zero) {
        _quizGapRemaining = Duration.zero;
      }
      _quizGapTimer!.cancel();
      _quizGapStartedAt = null;
      print("DEBUG: Paused quiz gap timer. Remaining: ${_quizGapRemaining!.inSeconds} seconds");
    }
  }

  void _onResumeVideo() {
    if (_quizGapRemaining != null && _quizGapRemaining! > Duration.zero && _quizGapStartedAt == null) {
      print("DEBUG: Resuming quiz gap timer with ${_quizGapRemaining!.inSeconds} seconds remaining");
      _startQuizGapTimer(_quizGapRemaining!);
    }
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Timer(Duration(seconds: 2), () {
      setState(() {
        enableController = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_hasAskedQuiz) {
          _showQuizOptIn();
        }
      });
    });
    super.initState();
    ScreenProtector.preventScreenshotOn();

    getInitalValue();
    initializeVideo();
    _controller.addListener(_videoPlayerListener);
    if (widget.playType == 1) {
      getSeekPosition();
    }

    if (widget.getWatchTime != "" && widget.getWatchTime != "0") {
      isSeekDuration = true;
      _seekTimer = Timer(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isSeekDuration = false;
          });
          int seconds = int.parse(widget.getWatchTime);
          _controller.seekTo(Duration(seconds: seconds));
          _controller.play();
          print("Watch_Time:${widget.getWatchTime}");
        }
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
                  onFullscreenFixLandscape: true,
                  source: {
                    widget.movieTitle: VideoSource(
                      video: widget.playType == 1
                          // ignore: deprecated_member_use
                          ? VideoPlayerController.network(widget.getMainMovieUrl)
                          : VideoPlayerController.file(_videoFile),
                    ),
                  },
                  style: CustomVideoViewerStyle(movie: movie, context: context),
                )
              : null,
        ),
        if (isSeekDuration) BackgroundLoadingWidget(),
        if (_isLoadingQuiz)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.amberAccent,
              ),
            ),
          ),
        if (_quizResponse != null && _isQuizActive && _currentQuizIndex < _quizResponse!.questions.length)
          QuizOverlay(
            question: _quizResponse!.questions[_currentQuizIndex],
            questionIndex: _currentQuizIndex,
            totalQuestions: _quizResponse!.questions.length,
            userId: userID,
            movieId: widget.getMainMovieID,
            attemptId: _quizResponse?.attemptId ?? "",
            token: _token,
            controller: _controller,
            durationSeconds: 20, // Hardecoded 10 sec question popup time
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
                  final nextQuestion = _quizResponse!.questions[_currentQuizIndex];
                  final previousQuestion = _quizResponse!.questions[_currentQuizIndex - 1];
                  int gapSeconds = nextQuestion.popupTime - previousQuestion.popupTime;

                  int nextDelaySeconds = _useStaticQuizTimeForTesting ? 10 : (gapSeconds > 0 ? gapSeconds : 0);
                  _startQuizGapTimer(Duration(seconds: nextDelaySeconds));
                } else {
                  print("DEBUG: Quiz sequence finished");
                  getQuizResult(userID, widget.getMainMovieID, _quizResponse?.attemptId ?? "");
                }
              });
            },
          ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoPlayerListener);
    _timer?.cancel();
    _quizGapTimer?.cancel();
    _seekTimer?.cancel();
    super.dispose();
    ScreenProtector.preventScreenshotOff();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';
      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      userID = pref.getString(AppPreferences.id) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';

      // Fetch Quiz Data
      if (_token.isNotEmpty && userID.isNotEmpty) {
        getQuizData(_token, userID, widget.getMainMovieID);
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

          if (currentPostion == total) {
            final postValuesWatched = {
              'watched': 1,
            };
            setUserMovies(_token, userID, widget.getMainMovieID, postValuesWatched);
          } else {
            final postValues = {
              'watching': 1,
              'watch_time': watchingSeconds,
              'watched_percent': percentage,
            };
            setUserMovies(_token, userID, widget.getMainMovieID, postValues);
          }
        }
      });
    });
  }

  void setUserMovies(String token, String userID, String movieID, Map<String, int> postValues) async {
    ApiServices().postRequestToken("${AppConfig.setUserMovie}$movieID?profile_id=$userID", postValues, token).then((response) async {
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
    if (!mounted) {
      return;
    }
    if (_quizResponse == null || _quizResponse!.questions.isEmpty) {
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
        onSelection: (bool accepted, String language) async {
          print("DEBUG: Quiz selection: $accepted, language: $language");
          Navigator.of(context).pop(); // Close dialog
          if (mounted) {
            if (accepted) {
              setState(() {
                _isLoadingQuiz = true;
              });

              await getQuizData(_token, userID, widget.getMainMovieID, language: language);

              if (mounted) {
                setState(() {
                  _isLoadingQuiz = false;
                });
              }

              setState(() {
                _quizEnabled = accepted;
                _controller.enableSkip = !accepted;
                if (accepted && _quizResponse != null && _quizResponse!.questions.isNotEmpty) {
                  // Schedule First Question
                  _currentQuizIndex = 0;
                  final firstQuestion = _quizResponse!.questions[0];
                  int startDelaySeconds = _useStaticQuizTimeForTesting ? 10 : (firstQuestion.popupTime > 0 ? firstQuestion.popupTime : 0);
                  print("DEBUG: Scheduling 1st Question in $startDelaySeconds seconds (popup_time: ${firstQuestion.popupTime}, static override: $_useStaticQuizTimeForTesting)");
                  if (startDelaySeconds == 0) {
                    _isQuizActive = true;
                    // Pause immediately if showing immediately
                    try {
                      _controller.pause();
                      if (_controller.isFullScreen) {
                        _controller.closeFullScreen();
                      }
                    } catch (e) {}
                  } else {
                    _startQuizGapTimer(Duration(seconds: startDelaySeconds));
                  }
                }
              });

              _seekTimer?.cancel();
              bool shouldPlay = true;
              if (accepted && _quizResponse != null && _quizResponse!.questions.isNotEmpty) {
                int initialDelay = _useStaticQuizTimeForTesting ? 10 : _quizResponse!.questions[0].popupTime;
                if (initialDelay == 0) {
                  shouldPlay = false; // Immediate quiz, ensure paused
                }
              }
              try {
                if (shouldPlay) {
                  _controller.seekTo(Duration.zero);
                  _controller.play();
                } else {
                  // Ensure paused if immediate
                  _controller.seekTo(Duration.zero);
                  _controller.pause();
                }
              } catch (e) {
                print("DEBUG: Error handling video state: $e");
              }
            } else {
              setState(() {
                _quizEnabled = false;
                _controller.enableSkip = true;
              });
              if (_seekTimer != null && _seekTimer!.isActive) {
                _seekTimer!.cancel();
                if (widget.getWatchTime != "" && widget.getWatchTime != "0") {
                  int seconds = int.parse(widget.getWatchTime);
                  _controller.seekTo(Duration(seconds: seconds));
                }
              }
              try {
                _controller.play();
              } catch (e) {
                print("DEBUG: Error resuming video: $e");
              }
            }
          }
        },
      ),
    );
  }

// # -----------------QUIZ-FETCH-API-----------------
  Future<void> getQuizData(String token, String userID, String movieID, {String language = 'english'}) async {
    final postValues = {
      'movie_id': movieID,
      'user_id': userID,
      'device_token': token.split("|")[1],
      'language': language,
    };
    try {
      final response = await ApiServices().postRequestToken(AppConfig.getQuiz, postValues, _token);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _quizResponse = QuizResponse.fromJson(jsonResponse);
            print("Quiz loaded: ${_quizResponse?.total} questions");
            if (mounted && !_hasAskedQuiz && enableController) {
              _showQuizOptIn();
            }
            print("API Response Start:--------------");
            debugPrint(
              "Quiz loaded: ${jsonResponse['questions']} questions",
              wrapWidth: 1024,
            );
            print("API Response End:--------------");
            print("Quiz Attempt ID: ${_quizResponse?.attemptId}");
            debugPrint("Full Quiz Response: $jsonResponse");
          });
        }
      } else {
        print("Quiz API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Quiz Parse Error: $e");
    }
  }

// # -----------------QUIZ-RESULT-API-----------------
  void getQuizResult(String userID, String movieID, String attemptId) async {
    final postValues = {
      'attemptId': attemptId,
      'tokenEncrypted': _token,
      'user_id': userID,
      'movieId': movieID,
    };
    print("Post Values GGG: $postValues");
    try {
      final response = await ApiServices().postRequestToken(AppConfig.quizResult, postValues, _token);

      if (response.statusCode != 200) {
        debugPrint("Quiz API Error: AAA ${response.statusCode} - ${response.body}");
        return;
      }
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        debugPrint("Quiz Result Success");

        final int correct = jsonResponse['correctAnswerCount'] ?? 0;
        final int total = jsonResponse['totalQuestions'] ?? 0;

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              final bool won = (total > 0 && correct == total); // Correct question Logic
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF031634),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          won ? "Congratulations!" : "Quiz Completed",
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          won ? "You won the quiz!" : "Better luck next time!",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (won) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Pause video before navigating to the reward claim
                                    try {
                                      _controller.pause();
                                      printGreen("DEBUG: Paused video for Reward Claim dialog");
                                    } catch (e) {
                                      printRed("DEBUG: Error pausing video: $e");
                                    }

                                    // Navigate to QuizRewardClaim and wait for return
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizRewardClaim(
                                          userID: userID,
                                          token: _token,
                                          onSuccess: () {
                                            // Handle success
                                            printGreen("FORM SUBMITTED");
                                            Navigator.of(ctx).pop(); // Also close the completed quiz dialog
                                          },
                                        ),
                                      ),
                                    );

                                    // Resume video after returning
                                    printGreen("DEBUG: Returned from Reward Claim, resuming video");
                                    try {
                                      _controller.play();
                                    } catch (e) {
                                      printRed("DEBUG: Error resuming video: $e");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amberAccent.withValues(alpha: 0.2),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: const BorderSide(color: Colors.amberAccent, width: 2),
                                    ),
                                    elevation: 10,
                                  ),
                                  child: const Text(
                                    "Claim Reward",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  // Resume video
                                  try {
                                    _controller.play();
                                  } catch (e) {
                                    print("DEBUG: Error resuming video: $e");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(color: Colors.blueAccent, width: 2),
                                  ),
                                  elevation: 10,
                                ),
                                child: const Text(
                                  "OK",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      } else {
        debugPrint("Server message: ${jsonResponse['message']}");
      }
    } catch (e) {
      debugPrint("Quiz Submit Error: CCC $e");
    }
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
      // ignore: deprecated_member_use
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
                  // ignore: deprecated_member_use
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
