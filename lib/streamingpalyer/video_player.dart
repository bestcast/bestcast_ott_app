import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:bestcaststudios/streamingpalyer/test_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:bestcaststudios/common_files/shimmer/shimmer_skeletons.dart';
import 'package:bestcaststudios/streamingpalyer/models/casts_models.dart';
import 'package:bestcaststudios/streamingpalyer/models/main_movie_details_models.dart';
import 'package:bestcaststudios/streamingpalyer/models/related_movie_modelss.dart';
import 'package:bestcaststudios/streamingpalyer/models/subtitle_models.dart';
import 'package:bestcaststudios/streamingpalyer/video_view_player.dart';
import '../Dashboard/Models/Movie.dart';
import '../Dashboard/Models/Usermovies.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/login_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/lifecycle_event_handler.dart';
import '../common_files/submit_transparent_button.dart';
import '../common_files/submit_white_button.dart';
import '../database_helper/DatabaseHelper.dart';
import '../download_files/dowloadmoviefiles.dart';
import '../plan_details/plan_details.dart';
import 'more_like_movies_models.dart';
import 'components/video_action_buttons.dart';
import 'components/more_like_this_grid.dart';

// ignore: must_be_immutable
class VideoApp extends StatefulWidget {
  String getMovieID = "";

  VideoApp({super.key, required this.getMovieID});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  late final SimulatedDownloadController _downloadControllers = SimulatedDownloadController(
      onOpenDownload: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DownloadMovieFiles()));
      },
      downloadUrl: movieData!.moviesource.toString(),
      downloadMovieID: movieData!.id.toString(),
      downloadThumnail: movieData!.thumbnail.toString(),
      downloadMovieTitle: movieData!.title.toString());

  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isRated = false;
  bool _isLike = false;
  bool _isDisLike = false;
  double _progressValue = 0.0;
  var watchTime = "0";
  bool _showControls = true;
  Timer? _hideControlsTimer;
  LifecycleEventHandler? _lifecycleHandler;

  late MovieData? movieData;
  List<CastElement> castElementList = [];
  List<RelatedMovieData> relatedMovieData = [];
  String _DirectorName = "";
  String _directorLabel = "Director";
  String _producersNames = "";
  String _producersLabel = "Producer";

  bool isLoading = false;

  final AppUtils appUtils = AppUtils();

  String _plan_status = "";
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  SubTitleModel? subTitleModel;

  String mobileDataUsage = "";
  bool enabelNotification = false;
  bool readyToPlay = false;
  bool downloadDataOption = false;
  bool downloadedPlayBTOption = false;
  bool loggedStatus = false;
  String downloadQuality = "";

  List<MoreLikeMoviesModel> moreLikeMoviesModel = [];

  var staringNames = "";
  var thumnailPic = ["images/sample_home_screen.jpg", "images/sample_movie_2.jpg", "images/sample_movie_3.jpg", "images/sample_movie_4.jpg", "images/sample_movie_5.jpg", "images/sample_movie_1.jpg"];

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    getInitalValue();

    _lifecycleHandler = LifecycleEventHandler(
      resumeCallBack: () async {
        if (mounted) {
          setState(() {
            print("Page Resumed");
          });
        }
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleHandler!);
  }

  void _onControllerProgress() {
    if (!mounted) return;
    try {
      if (!_controller.value.isInitialized) return;
      final double duration = _controller.value.duration.inSeconds.toDouble();
      if (duration > 0) {
        final double progress = (_controller.value.position.inSeconds.toDouble() / duration).clamp(0.0, 1.0);
        if ((progress - _progressValue).abs() > 0.005) {
          if (mounted) {
            setState(() {
              _progressValue = progress;
            });
          }
        }
      }
    } catch (_) {}
  }

  void getPlayerController(String loaderUrl) {
    print("LoaderUrl:$loaderUrl");
    try {
      _controller.removeListener(_onControllerProgress);
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
      _controller.dispose();
    } catch (_) {}

    _controller = VideoPlayerController.networkUrl(Uri.parse(loaderUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.addListener(_onControllerProgress);
      }).catchError((error) {
        print("VideoPlayerController init error: $error");
      });

    _controller.play();
    _isPlaying = true;

    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          print("HideConrolles");
          _showControls = false;
        });
      }
    });
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _plan_status = pref.getString(AppPreferences.plan_status) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';

      mobileDataUsage = pref.getString(AppPreferences.mobileDataUsage) ?? '';
      enabelNotification = pref.getBool(AppPreferences.enabelNotification) ?? false;
      downloadDataOption = pref.getBool(AppPreferences.downloadDataOption) ?? false;
      downloadQuality = pref.getString(AppPreferences.downloadQuality) ?? '';
      loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;
    });

    print("getMovieID: ${widget.getMovieID}");
    print("Main_token: $_token");
    if (widget.getMovieID != "") {
      getUserMoviesDetails(_token, profileID, widget.getMovieID);

      var movieId = widget.getMovieID.toString();
      var getDownloadMovieId = await dbHelper.getMovieId(movieId);
      if (getDownloadMovieId != "") {
        downloadedPlayBTOption = true;
      }
    }
  }

  void getMoreMovieListsTemp() {
    for (int i = 0; i < thumnailPic.length; i++) {
      moreLikeMoviesModel.add(MoreLikeMoviesModel(movieID: i.toString(), movieName: "Movie Name", thumnailPicture: thumnailPic[i]));
    }
  }

  void pauseController() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
    }
  }

  void playController() {
    if (!_controller.value.isPlaying) {
      _controller.play();
      _isPlaying = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: AppDefaultColors.appColor,
        leading: const BackButton(color: Colors.white),
      ),
      body: isLoading == false
          ? readyToPlay
              ? SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // height: 270,
                          child: _controller.value.isInitialized
                              ? Column(
                                  children: [
                                    Stack(children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showControls = !_showControls;
                                            if (_showControls && _controller.value.isPlaying) {
                                              _startHideControlsTimer();
                                            }
                                          });
                                        },
                                        child: AspectRatio(
                                          aspectRatio: _controller.value.aspectRatio,
                                          child: VideoPlayer(_controller),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isMuted ? Icons.volume_off : Icons.volume_up,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isMuted = !_isMuted;
                                            _controller.setVolume(_isMuted ? 0.0 : 1.0);
                                          });
                                        },
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: -10,
                                        right: -10,
                                        child: LayoutBuilder(builder: (context, constraints) {
                                          return Slider(
                                            value: _progressValue.clamp(0.0, 1.0),
                                            activeColor: AppDefaultColors.thikRed,
                                            inactiveColor: AppDefaultColors.white,
                                            onChanged: (double value) {
                                              setState(() {
                                                _progressValue = value.clamp(0.0, 1.0);
                                                final Duration newPosition = Duration(seconds: (_controller.value.duration.inSeconds * _progressValue).toInt());
                                                _controller.seekTo(newPosition);
                                              });
                                            },
                                          );
                                        }),
                                      ),
                                      if (_showControls)
                                        Positioned(
                                          bottom: 0,
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: AnimatedOpacity(
                                            opacity: _showControls ? 1.0 : 0.0,
                                            duration: Duration(milliseconds: 1000),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Image(
                                                    image: AssetImage("images/rotate_left.png"),
                                                    height: 30,
                                                  ),
                                                  onPressed: () {
                                                    _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 40,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isPlaying ? _controller.pause() : _controller.play();
                                                      _isPlaying = !_isPlaying;
                                                      _startHideControlsTimer();
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Image(
                                                    image: AssetImage("images/rotate_right.png"),
                                                    height: 30,
                                                  ),
                                                  onPressed: () {
                                                    _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ]),

                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //         height: 30,
                                    //         _isPlaying ? Icons.pause : Icons.play_arrow,
                                    //         color: Colors.white,
                                    //         size: 40,
                                    //         height: 30,
                                    //   value: _controller.value.buffered.isNotEmpty
                                    //       ? _controller.value.buffered.last.end.inSeconds / _controller.value.duration.inSeconds
                                    //       : 0.0,
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    color: AppDefaultColors.thikRed,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 10,
                            left: 10,
                            bottom: 5,
                          ),
                          child: Text(
                            movieData!.title.toString(),
                            // "Movie Time Name",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                appUtils.getDateTimeToYear(movieData!.releaseDate.toString()),
                                // '2024 2h 22m',
                                style: TextStyle(color: AppDefaultColors.textLightGray),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0, right: 3.0),
                              child: Container(
                                height: 25,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppDefaultColors.textLightGray, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Text(
                                      movieData!.certificate.toString(),
                                      // '2024 2h 22m',
                                      style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 12),
                                    ),
                                  ),
                                ), // Your content inside the container
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                movieData!.durationText.toString(),
                                style: TextStyle(color: AppDefaultColors.textLightGray),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            movieData!.content.toString(),
                            // 'Wrongfully suspended while pursuing the culprit in a missing persons case, a cop seeks '
                            // 'redemption-and'
                            // 'justice-when he gets a new assignment.',
                            style: TextStyle(color: AppDefaultColors.white),
                          ),
                        ),
                        if (staringNames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                getStartingBottomWidget();
                              },
                              child: RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Starring: ',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: staringNames,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (castElementList.isNotEmpty || staringNames.length > 25)
                                      const TextSpan(
                                        text: '  more...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_DirectorName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_directorLabel: ',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _DirectorName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_producersNames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_producersLabel: ',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _producersNames,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            right: 8.0,
                            left: 8.0,
                            bottom: 0.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            margin: EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.only(right: 5.0),
                            child: SubmitWhiteButton(
                              _plan_status == "1" || movieData!.movie_access == "1" ? "Play" : "Subscribe to Watch",
                              Icons.play_arrow,
                              onTap: () async {
                                //     context,

                                print("movie_watchTime: $watchTime");

                                if (loggedStatus) {
                                  if (mobileDataUsage == "Wi-FiOnly") {
                                    if (await CommonWidget().isWifiConnectivity()) {
                                      if (_plan_status == "0") {
                                        if (movieData!.movie_access == "1") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => MovieVideoViewer(
                                                        getMainMovieUrl: movieData!.videoUrl.toString(),
                                                        getMainMovieID: movieData!.id.toString(),
                                                        getWatchTime: watchTime,
                                                        playType: 1,
                                                        movieTitle: movieData!.title,
                                                        thumbnail: movieData!.thumbnail,
                                                        subtitles: movieData!.subtitle,
                                                      ))).then((value) {
                                            setState(() {
                                              getUserWatchingMoviesDetails(_token, profileID, widget.getMovieID);
                                            });
                                          });
                                        } else {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => PlanDetailsPage()));
                                        }
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MovieVideoViewer(
                                                      getMainMovieUrl: movieData!.videoUrl.toString(),
                                                      getMainMovieID: movieData!.id.toString(),
                                                      getWatchTime: watchTime,
                                                      playType: 1,
                                                      movieTitle: movieData!.title,
                                                      thumbnail: movieData!.thumbnail,
                                                      subtitles: movieData!.subtitle,
                                                    ))).then((value) {
                                          setState(() {
                                            getUserWatchingMoviesDetails(_token, profileID, widget.getMovieID);
                                          });
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Enable Wi-fi on your device.\nYour settings enabled wifi video playback option'),
                                        duration: Duration(seconds: 2),
                                      ));
                                    }
                                  } else {
                                    pauseController();

                                    //     context,
                                    //         builder: (context) =>
                                    //               getMainMovieUrl:
                                    //               getMainMovieID:
                                    //               getWatchTime:watchTime,
                                    //               playType: 1,
                                    print("_plan_status: $_plan_status");
                                    if (_plan_status == "0") {
                                      if (movieData!.movie_access == "1") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MovieVideoViewer(
                                                      getMainMovieUrl: movieData!.videoUrl.toString(),
                                                      getMainMovieID: movieData!.id.toString(),
                                                      getWatchTime: watchTime,
                                                      playType: 1,
                                                      movieTitle: movieData!.title,
                                                      thumbnail: movieData!.thumbnail,
                                                      subtitles: movieData!.subtitle,
                                                    ))).then((value) {
                                          setState(() {
                                            getUserWatchingMoviesDetails(_token, profileID, widget.getMovieID);
                                          });
                                        });
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => PlanDetailsPage()));
                                      }
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MovieVideoViewer(
                                            getMainMovieUrl: movieData!.videoUrl.toString(),
                                            getMainMovieID: movieData!.id.toString(),
                                            getWatchTime: watchTime,
                                            playType: 1,
                                            movieTitle: movieData!.title,
                                            thumbnail: movieData!.thumbnail,
                                            subtitles: movieData!.subtitle,
                                          ),
                                        ),
                                      ).then((value) {
                                        setState(() {
                                          getUserWatchingMoviesDetails(_token, profileID, widget.getMovieID);
                                        });
                                      });
                                    }
                                  }
                                } else {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                }
                              },
                            ),
                          ),
                        ),

                        //Downloaded video play option
                        _plan_status == "1"
                            ? downloadedPlayBTOption
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      right: 8.0,
                                      left: 8.0,
                                      bottom: 0.0,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      padding: const EdgeInsets.only(right: 5.0),
                                      child: SubmitTransparentButton(
                                        "Play Downloaded movie",
                                        Icons.play_circle,
                                        onTap: () async {
                                          var movieId = widget.getMovieID.toString();
                                          var movieLocalTitle = await dbHelper.getMovieTitle(movieId);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => MovieVideoViewer(
                                                        getMainMovieUrl: movieLocalTitle,
                                                        getMainMovieID: '',
                                                        getWatchTime: '0',
                                                        playType: 2,
                                                        movieTitle: movieData!.title,
                                                        thumbnail: movieData!.thumbnail,
                                                      )));
                                        },
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: AnimatedBuilder(
                                        animation: _downloadControllers,
                                        builder: (context, child) {
                                          return DownloadButton(
                                            status: _downloadControllers.downloadStatus,
                                            downloadProgress: _downloadControllers.progress,
                                            onDownload: _downloadControllers.startDownload,
                                            onCancel: _downloadControllers.stopDownload,
                                            onOpen: _downloadControllers.openDownload,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                            : Text(""),

                        //User mylist

                        if (loggedStatus)
                          VideoActionButtons(
                            isRated: _isRated,
                            isLike: _isLike,
                            isDisLike: _isDisLike,
                            onRate: () {
                              var isMyList = 0;
                              setState(() {
                                if (_isRated) {
                                  _isRated = false;
                                  isMyList = 0;
                                } else {
                                  _isRated = true;
                                  isMyList = 1;
                                }
                              });

                              final postValues = {
                                'mylist': isMyList,
                              };
                              setUserMovies(_token, profileID, movieData!.id.toString(), postValues);
                            },
                            onLike: () {
                              var isLikeValue = 0;
                              setState(() {
                                _isDisLike = false;
                                if (_isLike) {
                                  _isLike = false;
                                  isLikeValue = 0;
                                } else {
                                  _isLike = true;
                                  isLikeValue = 1;
                                }
                              });

                              final postValues = {
                                'likes': isLikeValue,
                              };
                              setUserMovies(_token, profileID, movieData!.id.toString(), postValues);
                            },
                            onDislike: () {
                              var isDisLikeValue = 0;
                              setState(() {
                                _isLike = false;
                                if (_isDisLike) {
                                  _isDisLike = false;
                                  isDisLikeValue = 0;
                                } else {
                                  _isDisLike = true;
                                  isDisLikeValue = 2;
                                }
                              });

                              final postValues = {
                                'likes': isDisLikeValue,
                              };
                              setUserMovies(_token, profileID, movieData!.id.toString(), postValues);
                            },
                            onShare: () {
                              final encodedTitle = Uri.encodeComponent(movieData!.title.toString());
                              Share.share('Watch ${movieData!.title} on Bestcast OTT, \n\nCheck it out here: ${AppConfig.BaseUrl}/search?search=$encodedTitle');
                            },
                          ),

                        Divider(
                          color: AppDefaultColors.textLightGray,
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "More Like This",
                            style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700),
                          ),
                        ),
                        // TEST BUTTON START ------------------------------------------
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => TestComponent(),
                        //       ),
                        //     );
                        //   },
                        //   child: Text("TEST"),
                        // ),
                        // TEST BUTTON END --------------------------------------------
                        MoreLikeThisGrid(
                          relatedMovieData: relatedMovieData,
                          onMovieTap: (movieId) {
                            getUserMoviesDetails(
                              _token,
                              profileID,
                              movieId,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : const DetailScreenSkeleton()
          : const DetailScreenSkeleton(),
    );
  }

  void getStartingBottomWidget() {
    // 1. Deduplicate members by name and combine multiple roles
    final Map<String, CastElement> uniqueMap = {};
    for (var item in castElementList) {
      final name = item.cast?.name?.toString().trim() ?? "";
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (uniqueMap.containsKey(key)) {
        final existingRole = uniqueMap[key]!.groupLabel?.toString().trim() ?? "";
        final newRole = item.groupLabel?.toString().trim() ?? "";
        if (newRole.isNotEmpty && !existingRole.toLowerCase().contains(newRole.toLowerCase())) {
          uniqueMap[key]!.groupLabel = "$existingRole, $newRole";
        }
      } else {
        uniqueMap[key] = item;
      }
    }

    final uniqueList = uniqueMap.values.toList();

    // 2. Organize into categorized sections
    String getCategory(String rawRole) {
      final r = rawRole.toLowerCase().trim();
      if (r.contains('director') && !r.contains('music') && !r.contains('art')) {
        return 'Director';
      }
      if (r.contains('actor') || r.contains('actress') || r.contains('cast') || r.contains('starring') || r.contains('lead') || r.contains('hero')) {
        return 'Cast & Starring';
      }
      if (r.contains('producer') || r.contains('production')) {
        return 'Producers';
      }
      if (r.contains('music') || r.contains('composer') || r.contains('singer') || r.contains('audio') || r.contains('sound')) {
        return 'Music & Audio';
      }
      return 'Crew & Technical';
    }

    final Map<String, List<CastElement>> grouped = {
      'Director': [],
      'Cast & Starring': [],
      'Producers': [],
      'Music & Audio': [],
      'Crew & Technical': [],
    };

    for (var item in uniqueList) {
      final role = item.groupLabel?.toString().trim() ?? "";
      final cat = getCategory(role);
      grouped[cat]!.add(item);
    }

    final List<MapEntry<String, List<CastElement>>> activeSections = [];
    for (var entry in grouped.entries) {
      if (entry.value.isNotEmpty) {
        String title = entry.key;
        if (title == 'Director' && entry.value.length > 1) {
          title = 'Directors';
        } else if (title == 'Producers' && entry.value.length == 1) {
          title = 'Producer';
        }
        activeSections.add(MapEntry(title, entry.value));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (BuildContext sheetContext) {
        Widget buildMonogram(String name) {
          String initials = "•";
          final trimmed = name.trim();
          if (trimmed.isNotEmpty) {
            final parts = trimmed.split(RegExp(r'\s+'));
            if (parts.length == 1) {
              initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
            } else if (parts.length >= 2) {
              initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
            }
          }
          return Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C2C3A),
                  Color(0xFF1C1C26),
                ],
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          );
        }

        Widget buildCastAvatar(String name, String photoUrl) {
          final hasPhoto = photoUrl.isNotEmpty && photoUrl != "null" && photoUrl != "false";
          return Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22222E),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: hasPhoto
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => buildMonogram(name),
                    )
                  : buildMonogram(name),
            ),
          );
        }

        Widget buildMemberTile(String personName, String role, String photoUrl) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF171720),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              children: [
                buildCastAvatar(personName, photoUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        personName.isNotEmpty ? personName : "Unknown",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      if (role.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121217),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimal drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header with title, counter pill, and close icon
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Row(
                    children: [
                      const Text(
                        "Starring & Crew",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (uniqueList.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${uniqueList.length} members",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          shape: const CircleBorder(),
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1, thickness: 1),
                // Categorized list
                Flexible(
                  child: uniqueList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            "No cast details available",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 24, top: 4),
                          physics: const BouncingScrollPhysics(),
                          itemCount: activeSections.length,
                          itemBuilder: (context, sectionIndex) {
                            final section = activeSections[sectionIndex];
                            final sectionTitle = section.key;
                            final members = section.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Subtle Minimalist Section Header
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 3.5,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppDefaultColors.primaryRed,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        sectionTitle.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "(${members.length})",
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Responsive 2-column or 1-column grid
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: members.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: members.length == 1 ? 1 : 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      mainAxisExtent: 60,
                                    ),
                                    itemBuilder: (context, idx) {
                                      final castItem = members[idx];
                                      final personName = castItem.cast?.name?.toString().trim() ?? "";
                                      final role = castItem.groupLabel?.toString().trim() ?? "";
                                      final rawPhoto = castItem.cast?.photo?.toString().trim() ?? "";

                                      String photoUrl = "";
                                      if (rawPhoto.isNotEmpty &&
                                          rawPhoto != "null" &&
                                          rawPhoto != "false") {
                                        if (rawPhoto.startsWith("http")) {
                                          photoUrl = rawPhoto;
                                        } else {
                                          photoUrl = "${AppConfig.BaseUrl}/$rawPhoto";
                                        }
                                      }

                                      return buildMemberTile(personName, role, photoUrl);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_lifecycleHandler != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleHandler!);
    }
    _hideControlsTimer?.cancel();
    try {
      _controller.removeListener(_onControllerProgress);
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
      _controller.dispose();
    } catch (_) {}
    _isPlaying = false;
    super.dispose();
  }

  Future openAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppDefaultColors.appColor..withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: SizedBox(
              height: 90.0,
              width: 270.0,
              child: Container(
                padding: EdgeInsets.only(bottom: 5, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.thumb_down_off_alt_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {},
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Not for me',
                            style: TextStyle(fontSize: 12, color: AppDefaultColors.textLightGray),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Image(
                            image: AssetImage("images/icon_like.png"),
                            height: 25,
                          ),
                          onPressed: () {},
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'I like this',
                            style: TextStyle(fontSize: 12, color: AppDefaultColors.textLightGray),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.thumb_up_off_alt_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {},
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'I love this',
                            style: TextStyle(fontSize: 12, color: AppDefaultColors.textLightGray),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void downloadFile(String url, String moveTitle) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      await dio.download(url, "${dir.path}/$moveTitle.mp4", onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
      });
    } catch (e) {
      print(e);
    }
    print("Download completed");
  }

  void getUserMoviesDetails(String token, String profileId, String movieID) async {
    setState(() {
      isLoading = true;
    });
    castElementList.clear();
    relatedMovieData.clear();
    var url = "";
    if (loggedStatus) {
      url = AppConfig.userMainMovieDetails;
      print("MovieDetailsUrl: $url$movieID");
    } else {
      url = AppConfig.userMovieDetails;
      print("MovieDetailsUrl: $url");
    }
    print("TOKen$token\n$profileId\n$url");

    ApiServices().getRequestData("$url$movieID?profile_id=$profileId", token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("MovieDetailes_Response: $jsonsDataString");

      var jsonReponse = jsonDecode(jsonsDataString);
      if (response.statusCode == 201) {
        String status = jsonReponse['status'];
        if (status == "error") {
          getTokenValid(token);
        }
      }

      if (response.statusCode == 200) {
        try {
          var data = jsonReponse['data'];
          print("MovieDetailesDataObject:$data");
          String id = data["id"].toString();
          String urlkey = data["urlkey"].toString();
          String title = data["title"].toString();
          String content = data["content_plain"].toString();
          String publishedDate = data["published_date"].toString();
          String releaseDate = data["release_date"].toString();

          String image = "${AppConfig.BaseUrl}/${data["image"]}";
          String medium = "${AppConfig.BaseUrl}/${data["medium"]}";
          String thumbnail = "${AppConfig.BaseUrl}/${data["thumbnail"]}";
          String portraitsmall = "${AppConfig.BaseUrl}/${data["portraitsmall"]}";
          String portrait = "${AppConfig.BaseUrl}/${data["portrait"]}";

          String duration = data["duration"].toString();
          String durationText = data["duration_text"].toString();
          String certificate = data["certificate"].toString();
          String certificateText = data["certificate_text"].toString();
          String tagText = data["tag_text"].toString();
          String topten = data["topten"].toString();
          String trailer = data["trailer"].toString();
          String trailer480p = data["trailer_480p"].toString();
          String videoUrl = data["video_url_720p"].toString();
          String movieAccess = data["movie_access"].toString();
          String moviesource = data["moviesource"].toString();
          String subtitleStatus = data["subtitle_status"].toString();

          print("MainMoiveDetails:$title");
          print("moviesource:$moviesource");

          List<SubTitleModel>? subtitleList;
          if (data["subtitle"] != null && data["subtitle"] is List) {
            subtitleList = List<SubTitleModel>.from(
                data["subtitle"].map((x) => SubTitleModel.fromJson(x)));
          }

          movieData = MovieData(
              id: id.toString(),
              urlkey: urlkey.toString(),
              title: title.toString(),
              movie_access: movieAccess.toString(),
              content: content.toString(),
              publishedDate: publishedDate.toString(),
              releaseDate: releaseDate.toString(),
              image: image.toString(),
              medium: medium.toString(),
              thumbnail: thumbnail.toString(),
              portraitsmall: portraitsmall.toString(),
              portrait: portrait.toString(),
              duration: duration.toString(),
              durationText: durationText.toString(),
              certificate: certificate.toString(),
              certificateText: certificateText.toString(),
              tagText: tagText.toString(),
              topten: topten.toString(),
              trailer: trailer.toString(),
              trailer480P: trailer480p.toString(),
              videoUrl: videoUrl.toString(),
              moviesource: moviesource.toString(),
              subtitleStatus: subtitleStatus.toString(),
              subtitle: subtitleList);

          var jsonValues = Usermovies.fromJson(data['usermovies']);

          if (jsonValues.id != "null") {
            var myList = data["usermovies"]["mylist"].toInt();
            var likeStatus = data["usermovies"]["likes"].toInt();
            watchTime = data["usermovies"]["watch_time"].toString();
            print("get_watchTime:$watchTime");
            print("myListDetails:$myList");
            if (myList == 0) {
              _isRated = false;
            } else {
              _isRated = true;
            }

            if (likeStatus == 2) {
              _isDisLike = true;
              _isLike = false;
            } else if (likeStatus == 1) {
              _isDisLike = false;
              _isLike = true;
            } else {
              _isDisLike = false;
              _isLike = false;
            }
          }

          castElementList.clear();
          _DirectorName = "";
          _directorLabel = "Director";
          _producersNames = "";
          _producersLabel = "Producer";
          staringNames = "";

          List<String> starringArray = [];
          List<String> directorsArray = [];
          List<String> producersArray = [];

          if (data["casts"] != null && data["casts"] is Iterable) {
            for (var castsData in data["casts"]) {
              print("castsDataCasts${castsData["cast"]}");
              CastCast? castCast;
              if (castsData['cast'] != null && castsData['cast'] != "") {
                print("castsDataCastName:${castsData["cast"]["name"]}");
                castCast = CastCast(
                  id: castsData["cast"]["id"]?.toString() ?? "",
                  name: castsData["cast"]["name"]?.toString() ?? "",
                  firstname: castsData["cast"]["firstname"]?.toString() ?? "",
                  lastname: castsData["cast"]["lastname"]?.toString() ?? "",
                  dob: castsData["cast"]["dob"]?.toString() ?? "",
                  gender: castsData["cast"]["gender"]?.toString() ?? "",
                  photo: castsData["cast"]["photo"]?.toString() ?? "",
                );

                String groupLabel = castsData["group_label"]?.toString().trim() ?? "";
                String castPersonName = castsData["cast"]["name"]?.toString().trim() ?? "";

                if (castPersonName.isNotEmpty) {
                  final grp = groupLabel.toLowerCase();
                  if (grp.contains("director") && !grp.contains("music") && !grp.contains("art")) {
                    if (!directorsArray.contains(castPersonName)) {
                      directorsArray.add(castPersonName);
                    }
                  } else if (grp.contains("producer")) {
                    if (!producersArray.contains(castPersonName)) {
                      producersArray.add(castPersonName);
                    }
                  } else if (grp.contains("actor") || grp.contains("actress") || grp.contains("cast") || grp.contains("starring") || grp.contains("lead")) {
                    if (!starringArray.contains(castPersonName)) {
                      starringArray.add(castPersonName);
                    }
                  } else {
                    if (!grp.contains("music") && !grp.contains("crew")) {
                      if (!starringArray.contains(castPersonName)) {
                        starringArray.add(castPersonName);
                      }
                    }
                  }
                }
              }

              CastElement castElement = CastElement(
                group: castsData["group"]?.toString(),
                groupLabel: castsData["group_label"]?.toString(),
                groupSlug: castsData["group_slug"]?.toString(),
                cast: castCast,
              );

              castElementList.add(castElement);
            }
          }

          if (data["related"] != null && data["related"] is Iterable) {
            for (var castsData in data["related"]) {
              Usermovies? usermovies;

              if (castsData["movie"]['usermovies'] != "") {
                print("usermoviesDetailsPage: ${castsData["movie"]["usermovies"]["id"]}");
                usermovies = Usermovies(
                  id: castsData["movie"]["usermovies"]["id"].toString(),
                  movieId: castsData["movie"]["usermovies"]["movieId"].toString(),
                  mylist: castsData["movie"]["usermovies"]["mylist"].toString(),
                  likes: castsData["movie"]["usermovies"]["likes"].toString(),
                  watchTime: castsData["movie"]["usermovies"]["watchTime"].toString(),
                  watching: castsData["movie"]["usermovies"]["watching"].toString(),
                  watched: castsData["movie"]["usermovies"]["watched"].toString(),
                  watchedPercent: castsData["movie"]["usermovies"]["watchedPercent"].toString(),
                  viewed: castsData["movie"]["usermovies"]["viewed"].toString(),
                );
              }

              String thumbnailUrl = "${AppConfig.BaseUrl}/${castsData["movie"]["thumbnail"]}";
              String portraitsmallUrl = "${AppConfig.BaseUrl}/${castsData["movie"]["portraitsmall"]}";
              String portraitUrl = "${AppConfig.BaseUrl}/${castsData["movie"]["portrait"]}";

              relatedMovieData.add(RelatedMovieData(
                  movie: Movies(
                id: castsData["movie"]["id"].toString(),
                title: castsData["movie"]["title"].toString(),
                movie_access: castsData["movie"]["movie_access"].toString(),
                topten: castsData["movie"]["topten"].toString(),
                trailer: castsData["movie"]["trailer"].toString(),
                certificate: castsData["movie"]["certificate"].toString(),
                duration: castsData["movie"]["duration"].toString(),
                tagText: castsData["movie"]["tag_text"].toString(),
                publishedDate: castsData["movie"]["published_date"].toString(),
                userlist: castsData["movie"]["userlist"].toString(),
                userlike: castsData["movie"]["userlike"].toString(),
                thumbnail: thumbnailUrl,
                portraitsmall: portraitsmallUrl,
                portrait: portraitUrl,
                usermovies: usermovies,
              )));

              print("RelatedMovieDataID${castsData["movie"]["id"]}");
            }
          }

          if (directorsArray.isNotEmpty) {
            _directorLabel = directorsArray.length > 1 ? "Directors" : "Director";
            _DirectorName = directorsArray.join(', ');
          }
          if (producersArray.isNotEmpty) {
            _producersLabel = producersArray.length > 1 ? "Producers" : "Producer";
            _producersNames = producersArray.join(', ');
          }
          if (starringArray.isNotEmpty) {
            staringNames = starringArray.join(', ');
          } else {
            staringNames = castElementList
                .map((e) => e.cast?.name?.toString().trim() ?? "")
                .where((n) => n.isNotEmpty && !directorsArray.contains(n) && !producersArray.contains(n))
                .toSet()
                .join(', ');
          }
          setState(() {
            readyToPlay = true;

            isLoading = false;
          });
          getPlayerController(trailer.toString());
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('GetMovieDetailsException:$e');
        }
      } else {
        print("Error: $response");
        isLoading = false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void getUserWatchingMoviesDetails(String token, String profileId, String movieID) async {
    setState(() {
      isLoading = true;
    });
    var url = "";
    if (loggedStatus) {
      url = AppConfig.userMainMovieDetails;
    } else {
      url = AppConfig.userMovieDetails;
    }

    ApiServices().getRequestData("$url$movieID?profile_id=$profileId", token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("MovieWatched_Response: $jsonsDataString");

      var jsonReponse = jsonDecode(jsonsDataString);
      if (response.statusCode == 201) {
        String status = jsonReponse['status'];
        if (status == "error") {
          getTokenValid(token);
        }
      }

      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);

          var data = jsonReponse['data'];

          print("DataObject:$data");

          var jsonValues = Usermovies.fromJson(data['usermovies']);

          if (jsonValues.id != "null") {
            var watchTime = data["usermovies"]["watch_time"].toString();
            setState(() {
              watchTime = watchTime;
            });
            print("watchTime:$watchTime");
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('GetWMovieDetailsException:$e');
        }
      } else {
        print("Error: $response");
        isLoading = false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getTokenValid(String token) async {
    if (token.isEmpty) return;
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiServices()
          .postRequestTokenWithoutBody(AppConfig.tokenexist, token)
          .timeout(const Duration(seconds: 10));

      String jsonsDataString = response.body.toString();
      print("getTokenExist_Response: $jsonsDataString");
      print("getTokenExist_Token: $token");

      if (response.statusCode == 200) {
        var jsonReponse = jsonDecode(jsonsDataString);
        String status = jsonReponse['status'] ?? "";

        if (status == "error") {
          final pref = await SharedPreferences.getInstance();
          await AppPreferences.clearUserSession(pref);

          if (mounted) {
            setState(() {
              _token = "";
              profileID = "";
              loggedStatus = false;
            });

            getUserMoviesDetails("", "", widget.getMovieID);
          }
        }
      } else if (response.statusCode == 401) {
        final pref = await SharedPreferences.getInstance();
        await AppPreferences.clearUserSession(pref);

        if (mounted) {
          setState(() {
            _token = "";
            profileID = "";
            loggedStatus = false;
          });

          getUserMoviesDetails("", "", widget.getMovieID);
        }
      }
    } catch (e) {
      print('getTokenExistException:$e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void setUserMovies(String token, String profileID, String movieID, Map<String, int> postValues) async {
    String resolvedProfileId = profileID;
    if (resolvedProfileId.isEmpty) {
      final pref = await SharedPreferences.getInstance();
      resolvedProfileId = pref.getString(AppPreferences.profileID) ?? pref.getString(AppPreferences.id) ?? '';
    }
    ApiServices().postRequestToken("${AppConfig.setUserMovie}$movieID?profile_id=$resolvedProfileId", postValues, token).then((response) async {
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

//     // Ensure that the window object is available
//         // Do nothing when a screenshot is detected
}

Dialog rateDialog = Dialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
  child: Container(
    color: AppDefaultColors.darkGray,
    height: 120.0,
    width: 300.0,
    child: Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.thumb_down_off_alt_outlined,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {},
              ),
              Text(
                'Not for me',
                style: TextStyle(fontSize: 12, color: AppDefaultColors.textLightGray),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Image(
                  image: AssetImage("images/icon_like.png"),
                  height: 25,
                ),
                onPressed: () {},
              ),
              Text(
                'I like this',
                style: TextStyle(fontSize: 12, color: AppDefaultColors.textLightGray),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.thumb_up_off_alt_outlined,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {},
              ),
              Text(
                'I love this',
                style: TextStyle(fontSize: 12, color: AppDefaultColors.textLightGray),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0.0,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  final DownloadStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Duration transitionDuration;

  bool get _isDownloading => status == DownloadStatus.downloading;

  bool get _isFetching => status == DownloadStatus.fetchingDownload;

  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded:
        onDownload();
      case DownloadStatus.fetchingDownload:
        // do nothing.
        break;
      case DownloadStatus.downloading:
        onCancel();
      case DownloadStatus.downloaded:
        onOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.only(right: 5.0),
            child: ButtonShapeWidget(
              downloadProgress: downloadProgress,
              transitionDuration: transitionDuration,
              isDownloaded: _isDownloaded,
              isDownloading: _isDownloading,
              isFetching: _isFetching,
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isDownloaded;
  final bool isFetching;
  final Duration transitionDuration;

  Null get onTap => null;

  @override
  Widget build(BuildContext context) {
    //   color: CupertinoColors.lightBackgroundGray,
    //

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppDefaultColors.boxDarkGray.withOpacity(0.5)),
          foregroundColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
          textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // BorderRadius
            ),
          ),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            isDownloading || isFetching
                ? SizedBox(
                    height: 30,
                    child: AnimatedOpacity(
                      duration: transitionDuration,
                      opacity: isDownloading || isFetching ? 1.0 : 0.0,
                      curve: Curves.ease,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ProgressIndicatorWidget(
                            downloadProgress: downloadProgress,
                            isDownloading: isDownloading,
                            isFetching: isFetching,
                          ),
                          if (isDownloading)
                            const Icon(
                              Icons.stop,
                              size: 14,
                              color: AppDefaultColors.thikRed,
                            ),
                        ],
                      ),
                    ),
                  )
                : Icon(
                    Icons.file_download_outlined,
                    color: AppDefaultColors.white,
                    size: 40.0,
                  ),
            SizedBox(
              width: 10,
            ),
            Text(
              isDownloaded ? 'Download Completed' : 'Download',
              style: TextStyle(color: AppDefaultColors.white, fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor: isDownloading ? CupertinoColors.lightBackgroundGray : Colors.white.withOpacity(0),
            valueColor: AlwaysStoppedAnimation(isFetching ? CupertinoColors.lightBackgroundGray : AppDefaultColors.thikRed),
            strokeWidth: 2,
            value: isFetching ? null : progress,
          );
        },
      ),
    );
  }
}

enum DownloadStatus {
  notDownloaded,
  fetchingDownload,
  downloading,
  downloaded,
}

abstract class DownloadController implements ChangeNotifier {
  DownloadStatus get downloadStatus;

  double get progress;

  void startDownload();

  void stopDownload();

  void openDownload();
}

class SimulatedDownloadController extends DownloadController with ChangeNotifier {
  SimulatedDownloadController({
    DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
    double progress = 0.0,
    required String downloadUrl,
    required String downloadMovieID,
    required String downloadThumnail,
    required String downloadMovieTitle,
    required VoidCallback onOpenDownload,
  })  : _downloadStatus = downloadStatus,
        _progress = progress,
        _onOpenDownload = onOpenDownload,
        _downloadUrl = downloadUrl,
        _downloadMovieID = downloadMovieID,
        _downloadThumnail = downloadThumnail,
        _downloadMovieTitle = downloadMovieTitle;

  DownloadStatus _downloadStatus;

  @override
  DownloadStatus get downloadStatus => _downloadStatus;

  double _progress;

  @override
  double get progress => _progress;

  final VoidCallback _onOpenDownload;

  bool _isDownloading = false;

  CancelToken cancelToken = CancelToken();
  final percentNotifier = ValueNotifier<double?>(null);
  final dbHelper = DatabaseHelper();
  String movieDirPath = "";
  final String _downloadUrl;
  final String _downloadMovieID;
  final String _downloadThumnail;
  final String _downloadMovieTitle;

  void _cancel() {
    cancelToken.cancel();
    percentNotifier.value = null;
    print("percentNotifier: cancel");
  }

  void _onReceiveProgress(int received, int total) {
    if (!cancelToken.isCancelled) {
      percentNotifier.value = received / total;
      print("percentNotifier_value :${percentNotifier.value}");
    }
  }

  @override
  void startDownload() {
    if (downloadStatus == DownloadStatus.notDownloaded) {
      _doSimulatedDownload();
    }
  }

  @override
  void stopDownload() {
    if (_isDownloading) {
      _cancel();
      _isDownloading = false;
      _downloadStatus = DownloadStatus.notDownloaded;
      _progress = 0.0;
      notifyListeners();
    }
  }

  @override
  void openDownload() {
    if (downloadStatus == DownloadStatus.downloaded) {
      _onOpenDownload();
    }
  }

  Future<void> _doSimulatedDownload() async {
    //
    //
    //

    if (await verifyDataOption()) {
      print("C_downloadUrl: $_downloadUrl");
      if (_downloadUrl != "null" && _downloadUrl != "") {
        _isDownloading = true;
        _downloadStatus = DownloadStatus.fetchingDownload;
        notifyListeners();

        if (cancelToken.isCancelled) {
          cancelToken = CancelToken();
        }
        await Future<void>.delayed(const Duration(seconds: 1));

        // If the user chose to cancel the download, stop the simulation.
        if (!_isDownloading) {
          return;
        }

        // Shift to the downloading phase.
        _downloadStatus = DownloadStatus.downloading;
        notifyListeners();

        bool downloadSuccess = false;
        try {
          Dio dio = Dio();
          double downloadProgress = 0;
          var dir = await getApplicationDocumentsDirectory();
          final sanitizedTitle = _downloadMovieTitle.replaceAll(RegExp(r'[\/\\:?*"<>|]'), '_');
          movieDirPath = "${dir.path}/$sanitizedTitle.mp4";
          print("DownloadDirectory: ${dir.path}");
          print("_downloadUrl: $_downloadUrl");

          await dio.download(_downloadUrl, movieDirPath, cancelToken: cancelToken, onReceiveProgress: (rec, total) {
            _onReceiveProgress(rec, total);
            if (total > 0) {
              downloadProgress = ((rec / total) * 100.toInt()) / 100;
            }
            print("Rec: $rec , Total: $total, Progress percent: $downloadProgress");

            if (rec == total && total > 0) {
              downloadProgress = 1;
            }

            if (!_isDownloading) {
              return;
            }

            _progress = downloadProgress;
            notifyListeners();
          });
          downloadSuccess = true;
        } catch (e) {
          print("Download_Error: $e");
          if (!cancelToken.isCancelled) {
            Fluttertoast.showToast(msg: "Download failed. Please check your connection.");
          }
        }

        if (!downloadSuccess || !_isDownloading || cancelToken.isCancelled) {
          _isDownloading = false;
          _downloadStatus = DownloadStatus.notDownloaded;
          _progress = 0.0;
          notifyListeners();
          return;
        }

        print("Download completed");

        await Future<void>.delayed(const Duration(seconds: 1));

        if (!_isDownloading) {
          return;
        }

        // Shift to the downloaded state, completing the simulation.
        _downloadStatus = DownloadStatus.downloaded;
        _isDownloading = false;

        var dbValue = {
          'movieUrl': movieDirPath.toString(),
          'movieID': _downloadMovieID.toString(),
          'movieThumnail': _downloadThumnail.toString(),
          'movieTitle': _downloadMovieTitle.toString()
        };
        await dbHelper.insertData(dbValue);

        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: "Download option not enabled for this movie");
      }
    } else {
      Fluttertoast.showToast(msg: "Enable Wi-fi on your device.\nYour settings enabled wifi dowload option");
    }
  }

  Future<bool> verifyDataOption() async {
    final pref = await SharedPreferences.getInstance();
    var downloadDataOption = pref.getBool(AppPreferences.downloadDataOption) ?? false;

    if (downloadDataOption) {
      if (await CommonWidget().isWifiConnectivity()) {
        print("downloadDataOption: true");
        return true;
      } else {
        print("downloadDataOption: false");
        return false;
      }
    } else {
      print("downloadDataOption: true");
      return true;
    }
  }

  Future<File> encryptFile(File inputFile, String key, String outputFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$outputFileName';
    final outputFile = File(filePath);

    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

    final inputBytes = await inputFile.readAsBytes();
    final encryptedBytes = encrypter.encryptBytes(inputBytes, iv: iv).bytes;

    await outputFile.writeAsBytes(encryptedBytes);

    return outputFile;
  }
}
