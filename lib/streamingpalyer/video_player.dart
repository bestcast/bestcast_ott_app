import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

import 'package:bestcaststudios/common_files/loading_widget.dart';
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

  late final SimulatedDownloadController _downloadControllers =
      SimulatedDownloadController(
          onOpenDownload: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DownloadMovieFiles()));
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

  late MovieData? movieData;
  List<CastElement> castElementList = [];
  List<RelatedMovieData> relatedMovieData = [];
  String _DirectorName = "";

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
  var thumnailPic = [
    "images/sample_home_screen.jpg",
    "images/sample_movie_2.jpg",
    "images/sample_movie_3.jpg",
    "images/sample_movie_4.jpg",
    "images/sample_movie_5.jpg",
    "images/sample_movie_1.jpg"
  ];

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    getInitalValue();

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => setState(() {
              print("Page Resumed");
            })));
  }

  void getPlayerController(String loaderUrl) {
    print("LoaderUrl:$loaderUrl");
    _controller = VideoPlayerController.networkUrl(Uri.parse(loaderUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.addListener(() {
          setState(() {
            _progressValue = _controller.value.position.inSeconds.toDouble() /
                _controller.value.duration.inSeconds.toDouble();
          });
        });
      });

    _controller.play();
    _isPlaying = true;

    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        print("HideConrolles");
        _showControls = false;
      });
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
      enabelNotification =
          pref.getBool(AppPreferences.enabelNotification) ?? false;
      downloadDataOption =
          pref.getBool(AppPreferences.downloadDataOption) ?? false;
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
      moreLikeMoviesModel.add(MoreLikeMoviesModel(
          movieID: i.toString(),
          movieName: "Movie Name",
          thumnailPicture: thumnailPic[i]));
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
                                            if (_showControls &&
                                                _controller.value.isPlaying) {
                                              _startHideControlsTimer();
                                            }
                                          });
                                        },
                                        child: AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: VideoPlayer(_controller),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isMuted
                                              ? Icons.volume_off
                                              : Icons.volume_up,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isMuted = !_isMuted;
                                            _controller.setVolume(
                                                _isMuted ? 0.0 : 1.0);
                                          });
                                        },
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: -10,
                                        right: -10,
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return Slider(
                                            value: _progressValue,
                                            activeColor:
                                                AppDefaultColors.thikRed,
                                            inactiveColor:
                                                AppDefaultColors.white,
                                            onChanged: (double value) {
                                              setState(() {
                                                _progressValue = value;
                                                final Duration newPosition =
                                                    Duration(
                                                        seconds: (_controller
                                                                    .value
                                                                    .duration
                                                                    .inSeconds *
                                                                _progressValue)
                                                            .toInt());
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
                                            duration:
                                                Duration(milliseconds: 1000),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Image(
                                                    image: AssetImage(
                                                        "images/rotate_left.png"),
                                                    height: 30,
                                                  ),
                                                  onPressed: () {
                                                    _controller.seekTo(Duration(
                                                        seconds: _controller
                                                                .value
                                                                .position
                                                                .inSeconds -
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
                                                      _startHideControlsTimer();
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Image(
                                                    image: AssetImage(
                                                        "images/rotate_right.png"),
                                                    height: 30,
                                                  ),
                                                  onPressed: () {
                                                    _controller.seekTo(Duration(
                                                        seconds: _controller
                                                                .value
                                                                .position
                                                                .inSeconds +
                                                            10));
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
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                appUtils.getDateTimeToYear(
                                    movieData!.releaseDate.toString()),
                                // '2024 2h 22m',
                                style: TextStyle(
                                    color: AppDefaultColors.textLightGray),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 8.0, bottom: 8.0, right: 3.0),
                              child: Container(
                                height: 25,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppDefaultColors
                                        .textLightGray, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Text(
                                      movieData!.certificate.toString(),
                                      // '2024 2h 22m',
                                      style: TextStyle(
                                          color: AppDefaultColors.textLightGray,
                                          fontSize: 12),
                                    ),
                                  ),
                                ), // Your content inside the container
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                movieData!.durationText.toString(),
                                style: TextStyle(
                                    color: AppDefaultColors.textLightGray),
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
                        Padding(
                          padding: EdgeInsets.only(top: 10, left: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 230,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  // 'Starring: Tovino Thomas, Siddique, Vineeth Thattil David.',
                                  'Starring: $staringNames',
                                  style:
                                      TextStyle(color: AppDefaultColors.white),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    getStartingBottomWidget();
                                  },
                                  child: Text(
                                    maxLines: 1,
                                    'more.',
                                    style: TextStyle(
                                        color: AppDefaultColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Director: $_DirectorName',
                            style: TextStyle(color: AppDefaultColors.white),
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
                              _plan_status == "1" ||
                                      movieData!.movie_access == "1"
                                  ? "Play"
                                  : "Subscribe to Watch",
                              Icons.play_arrow,
                              onTap: () async {
                                //     context,

                                print("movie_watchTime: $watchTime");

                                if (loggedStatus) {
                                  if (mobileDataUsage == "Wi-FiOnly") {
                                    if (await CommonWidget()
                                        .isWifiConnectivity()) {
                                      if (_plan_status == "0") {
                                        if (movieData!.movie_access == "1") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MovieVideoViewer(
                                                        getMainMovieUrl:
                                                            movieData!.videoUrl
                                                                .toString(),
                                                        getMainMovieID:
                                                            movieData!.id
                                                                .toString(),
                                                        getWatchTime: watchTime,
                                                        playType: 1,
                                                        movieTitle:
                                                            movieData!.title,
                                                        thumbnail: movieData!
                                                            .thumbnail,
                                                      ))).then((value) {
                                            setState(() {
                                              getUserWatchingMoviesDetails(
                                                  _token,
                                                  profileID,
                                                  widget.getMovieID);
                                            });
                                          });
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlanDetailsPage()));
                                        }
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MovieVideoViewer(
                                                      getMainMovieUrl:
                                                          movieData!.videoUrl
                                                              .toString(),
                                                      getMainMovieID: movieData!
                                                          .id
                                                          .toString(),
                                                      getWatchTime: watchTime,
                                                      playType: 1,
                                                      movieTitle:
                                                          movieData!.title,
                                                      thumbnail:
                                                          movieData!.thumbnail,
                                                    ))).then((value) {
                                          setState(() {
                                            getUserWatchingMoviesDetails(_token,
                                                profileID, widget.getMovieID);
                                          });
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'Enable Wi-fi on your device.\nYour settings enabled wifi video playback option'),
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
                                                builder: (context) =>
                                                    MovieVideoViewer(
                                                      getMainMovieUrl:
                                                          movieData!.videoUrl
                                                              .toString(),
                                                      getMainMovieID: movieData!
                                                          .id
                                                          .toString(),
                                                      getWatchTime: watchTime,
                                                      playType: 1,
                                                      movieTitle:
                                                          movieData!.title,
                                                      thumbnail:
                                                          movieData!.thumbnail,
                                                    ))).then((value) {
                                          setState(() {
                                            getUserWatchingMoviesDetails(_token,
                                                profileID, widget.getMovieID);
                                          });
                                        });
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PlanDetailsPage()));
                                      }
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MovieVideoViewer(
                                            getMainMovieUrl:
                                                movieData!.videoUrl.toString(),
                                            getMainMovieID:
                                                movieData!.id.toString(),
                                            getWatchTime: watchTime,
                                            playType: 1,
                                            movieTitle: movieData!.title,
                                            thumbnail: movieData!.thumbnail,
                                          ),
                                        ),
                                      ).then((value) {
                                        setState(() {
                                          getUserWatchingMoviesDetails(_token,
                                              profileID, widget.getMovieID);
                                        });
                                      });
                                    }
                                  }
                                } else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()));
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
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: SubmitTransparentButton(
                                        "Play Downloaded movie",
                                        Icons.play_circle,
                                        onTap: () async {
                                          var movieId =
                                              widget.getMovieID.toString();
                                          var movieLocalTitle = await dbHelper
                                              .getMovieTitle(movieId);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MovieVideoViewer(
                                                        getMainMovieUrl:
                                                            movieLocalTitle,
                                                        getMainMovieID: '',
                                                        getWatchTime: '0',
                                                        playType: 2,
                                                        movieTitle:
                                                            movieData!.title,
                                                        thumbnail: movieData!
                                                            .thumbnail,
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
                                            status: _downloadControllers
                                                .downloadStatus,
                                            downloadProgress:
                                                _downloadControllers.progress,
                                            onDownload: _downloadControllers
                                                .startDownload,
                                            onCancel: _downloadControllers
                                                .stopDownload,
                                            onOpen: _downloadControllers
                                                .openDownload,
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
                              setUserMovies(_token, profileID,
                                  movieData!.id.toString(), postValues);
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
                              setUserMovies(_token, profileID,
                                  movieData!.id.toString(), postValues);
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
                              setUserMovies(_token, profileID,
                                  movieData!.id.toString(), postValues);
                            },
                            onShare: () {
                              final encodedTitle = Uri.encodeComponent(
                                  movieData!.title.toString());
                              Share.share(
                                  'Watch ${movieData!.title} on Bestcast OTT, \n\nCheck it out here: ${AppConfig.BaseUrl}/search?search=$encodedTitle');
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
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700),
                          ),
                        ),

                        //   itemCount: thumnailPic.length,
                        //     crossAxisCount: 3, // Number of columns
                        //     crossAxisSpacing: 0, // Spacing between columns
                        //     mainAxisSpacing: 0, // Spacing between rows

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

                        //       itemCount: relatedMovieData.length,
                        //         crossAxisCount: 3, // Number of columns
                        //         crossAxisSpacing: 0, // Spacing between columns
                        //         mainAxisSpacing: 0, // Spacing between rows
                        //

                        //       itemCount: moreLikeMoviesModel.length,
                        //         crossAxisCount: 2, // Number of columns
                        //         crossAxisSpacing: 0, // Spacing between columns
                        //         mainAxisSpacing: 0, // Spacing between rows
                      ],
                    ),
                  ),
                )
              : LoadingWidget()
          : LoadingWidget(),
    );
  }

  void getStartingBottomWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDefaultColors.darkGray.withOpacity(0.7),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: Duration(milliseconds: 700), // Set the animation duration
      ),
      enableDrag: true,
      // backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedOpacity(
          duration: Duration(milliseconds: 500), // Set the animation duration
          opacity: 1.0, // Set the initial opacity to 0 for fade-out effect
          onEnd: () {
            Navigator.pop(
                context); // Close the bottom sheet after the animation completes
          },

          child: SingleChildScrollView(
            child: SizedBox(
              // height: 500,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20),
                child: Column(
                  children: [
                    Text(
                      "Staring",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w700),
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        // itemCount: staringNames.length,
                        itemCount: castElementList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Align(
                              alignment: Alignment.center,
                              child: Text(
                                castElementList[index].cast!.name.toString(),
                                style: const TextStyle(
                                    color: AppDefaultColors.textLightGray,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            onTap: () {
                              // Add your onTap logic here
                              Navigator.pop(
                                  context); // Close the bottom sheet when item is tapped
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.cancel_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.pause();
    _isPlaying = false;
    super.dispose();
  }

  Future openAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppDefaultColors.appColor..withOpacity(0.2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50.0))),
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
                            style: TextStyle(
                                fontSize: 12,
                                color: AppDefaultColors.textLightGray),
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
                            style: TextStyle(
                                fontSize: 12,
                                color: AppDefaultColors.textLightGray),
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
                            style: TextStyle(
                                fontSize: 12,
                                color: AppDefaultColors.textLightGray),
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
      await dio.download(url, "${dir.path}/$moveTitle.mp4",
          onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
      });
    } catch (e) {
      print(e);
    }
    print("Download completed");
  }

  void getUserMoviesDetails(
      String token, String profileId, String movieID) async {
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

    ApiServices()
        .getRequestData("$url$movieID?profile_id=$profileId", token)
        .then((response) async {
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
          String portraitsmall =
              "${AppConfig.BaseUrl}/${data["portraitsmall"]}";
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
              subtitleStatus: subtitleStatus.toString());

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

          var staringNamesArray = [];
          for (var castsData in data["casts"]) {
            print("castsDataCasts${castsData["cast"]}");
            CastCast? castCast;
            if (castsData['cast'] != "") {
              print("castsDataCastName:${castsData["cast"]["name"]}");
              castCast = CastCast(
                id: castsData["cast"]["id"].toString(),
                name: castsData["cast"]["name"].toString(),
                firstname: castsData["cast"]["firstname"].toString(),
                lastname: castsData["cast"]["lastname"].toString(),
                dob: castsData["cast"]["dob"].toString(),
                gender: castsData["cast"]["gender"].toString(),
                photo: castsData["cast"]["photo"].toString(),
              );

              if (castsData["group_label"] == "Producer") {
                setState(() {
                  _DirectorName = castsData["group_label"].toString();
                });
              }
              staringNamesArray.add(castsData["cast"]["name"].toString());
            }

            CastElement castElement = CastElement(
                group: castsData["group"].toString(),
                groupLabel: castsData["group_label"].toString(),
                groupSlug: castsData["group_slug"].toString(),
                cast: castCast);

            castElementList.add(castElement);
          }

          if (data["related"] != "" && data["related"] != null) {
            for (var castsData in data["related"]) {
              Usermovies? usermovies;

              if (castsData["movie"]['usermovies'] != "") {
                print(
                    "usermoviesDetailsPage: ${castsData["movie"]["usermovies"]["id"]}");
                usermovies = Usermovies(
                  id: castsData["movie"]["usermovies"]["id"].toString(),
                  movieId:
                      castsData["movie"]["usermovies"]["movieId"].toString(),
                  mylist: castsData["movie"]["usermovies"]["mylist"].toString(),
                  likes: castsData["movie"]["usermovies"]["likes"].toString(),
                  watchTime:
                      castsData["movie"]["usermovies"]["watchTime"].toString(),
                  watching:
                      castsData["movie"]["usermovies"]["watching"].toString(),
                  watched:
                      castsData["movie"]["usermovies"]["watched"].toString(),
                  watchedPercent: castsData["movie"]["usermovies"]
                          ["watchedPercent"]
                      .toString(),
                  viewed: castsData["movie"]["usermovies"]["viewed"].toString(),
                );
              }

              String thumbnailUrl =
                  "${AppConfig.BaseUrl}/${castsData["movie"]["thumbnail"]}";
              String portraitsmallUrl =
                  "${AppConfig.BaseUrl}/${castsData["movie"]["portraitsmall"]}";
              String portraitUrl =
                  "${AppConfig.BaseUrl}/${castsData["movie"]["portrait"]}";

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
          staringNames = staringNamesArray.join(', ');
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

  void getUserWatchingMoviesDetails(
      String token, String profileId, String movieID) async {
    setState(() {
      isLoading = true;
    });
    var url = "";
    if (loggedStatus) {
      url = AppConfig.userMainMovieDetails;
    } else {
      url = AppConfig.userMovieDetails;
    }

    ApiServices()
        .getRequestData("$url$movieID?profile_id=$profileId", token)
        .then((response) async {
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

  void getTokenValid(String token) async {
    setState(() {
      isLoading = true;
    });
    ApiServices()
        .postRequestTokenWithoutBody(AppConfig.tokenexist, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("getTokenExist_Response: $jsonsDataString");
      print("getTokenExist_Token: $token");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "error") {
            final pref = await SharedPreferences.getInstance();
            pref.clear();

            setState(() {
              loggedStatus = false;
            });

            getUserMoviesDetails(_token, profileID, widget.getMovieID);
          }
        } catch (e) {
          print('getTokenExistException:$e');
        }
      } else {
        print("geTokenResError: $response");
      }
    });
    setState(() {
      isLoading = false;
    });
  }

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
                style: TextStyle(
                    fontSize: 12, color: AppDefaultColors.textLightGray),
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
                style: TextStyle(
                    fontSize: 12, color: AppDefaultColors.textLightGray),
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
                style: TextStyle(
                    fontSize: 12, color: AppDefaultColors.textLightGray),
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
          backgroundColor: WidgetStateProperty.all(
              AppDefaultColors.boxDarkGray.withOpacity(0.5)),
          foregroundColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
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
              style: TextStyle(
                  color: AppDefaultColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
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
            backgroundColor: isDownloading
                ? CupertinoColors.lightBackgroundGray
                : Colors.white.withOpacity(0),
            valueColor: AlwaysStoppedAnimation(isFetching
                ? CupertinoColors.lightBackgroundGray
                : AppDefaultColors.thikRed),
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

class SimulatedDownloadController extends DownloadController
    with ChangeNotifier {
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

        try {
          Dio dio = Dio();
          double downloadProgress = 0;
          var dir = await getApplicationDocumentsDirectory();
          print("DownloadDirectory: ${dir.path}");
          print("_downloadUrl: $_downloadUrl");
          movieDirPath = "${dir.path}/$_downloadMovieTitle.mp4";
          await dio.download(
              _downloadUrl, "${dir.path}/$_downloadMovieTitle.mp4",
              cancelToken: cancelToken, onReceiveProgress: (rec, total) {
            _onReceiveProgress(rec, total);
            downloadProgress = ((rec / total) * 100.toInt()) / 100;
            print(
                "Rec: $rec , Total: $total, Progress percent: $downloadProgress");

            if (rec == total) {
              downloadProgress = 1;
            }

            if (!_isDownloading) {
              return;
            }

            _progress = downloadProgress;
            notifyListeners();
          });
        } catch (e) {
          print(e);
          print("Download_Error: $e");
        }

        print("Download completed");

        //
        //   // If the user chose to cancel the download, stop the simulation.
        //
        //   // Update the download progress.

        await Future<void>.delayed(const Duration(seconds: 1));

        // If the user chose to cancel the download, stop the simulation.
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
        Fluttertoast.showToast(
            msg: "Download option not enabled for this movie");
      }
    } else {
      Fluttertoast.showToast(
          msg:
              "Enable Wi-fi on your device.\nYour settings enabled wifi dowload option");
    }
  }

  Future<bool> verifyDataOption() async {
    final pref = await SharedPreferences.getInstance();
    var downloadDataOption =
        pref.getBool(AppPreferences.downloadDataOption) ?? false;

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

  Future<File> encryptFile(
      File inputFile, String key, String outputFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$outputFileName';
    final outputFile = File(filePath);

    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

    final inputBytes = await inputFile.readAsBytes();
    final encryptedBytes = encrypter.encryptBytes(inputBytes, iv: iv).bytes;

    await outputFile.writeAsBytes(encryptedBytes);

    return outputFile;
  }
}
