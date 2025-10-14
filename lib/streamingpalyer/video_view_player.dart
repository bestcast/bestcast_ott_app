// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/common_files/background_loading_widget.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/video_viewer.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';

// import 'package:flutter_windowmanager/flutter_windowmanager.dart';

// import 'package:video_player/video_player.dart';
// import 'package:video_player_source/video_viewer.dart';
// import 'package:video_viewer.dart';

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
          playAndPauseStyle:
              PlayAndPauseWidgetStyle(background: context.color.primary),
          // PlayAndPauseWidgetStyle(background: AppDefaultColors.thikRed),
          // PlayAndPauseWidgetStyle(background:  Theme.of(context).colorScheme.primary),

          progressBarStyle: ProgressBarStyle(
            // bar: BarStyle.progress(color: AppDefaultColors.thikRed),
            bar: BarStyle.progress(color: context.color.primary),
            // bar: BarStyle.progress(color: Theme.of(context).colorScheme.primary,),
          ),
          header: Container(
            width: double.infinity,
            padding: kAllPadding,
            child: Headline6(
              movie.title,
              // style: TextStyle(color: context.textTheme.headlineMedium?.color),
              style: TextStyle(color: AppDefaultColors.white),
            ),
          ),
          // thumbnail: Stack(children: [
          //   Positioned.fill(child: MovieImage(movie)),
          //   Positioned.fill(
          //     child: Image.network(movie.thumbnail, fit: BoxFit.cover),
          //   ),
          // ]),
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

class VideoViewerApp extends StatelessWidget {
  VideoViewerApp(
      {super.key,
      required this.movieTitle,
      required this.thumbnail,
      required this.getMainMovieUrl,
      required this.getMainMovieID,
      required this.getWatchTime,
      required this.playType});

  // const MovieVideoViewer(
  //     this.movie, {Key? key}
  //     ) : super(key: key);

  // final Movie movie;

  String getMainMovieUrl = "";
  String movieTitle = "";
  String thumbnail = "";
  String getMainMovieID = "";
  String getWatchTime = "";
  int playType = 1;

  @override
  Widget build(BuildContext context) {
    Misc.setSystemOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    );
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFf9fbfe),
        cardColor: Color(0xFFfbfafe),
        primaryColor: Color(0xFFd81e27),
        shadowColor: Color(0xFF324754).withOpacity(0.24),
        textTheme: TextTheme(
          headlineMedium: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
          headlineSmall: GoogleFonts.montserrat(
            color: Color(0xFF324754),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: GoogleFonts.montserrat(
            color: Color(0xFF324754),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: GoogleFonts.montserrat(
            color: Color(0xFF324754),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleMedium: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 12,
          ),
          titleSmall: GoogleFonts.montserrat(
            color: Color(0xFF819ab1),
            fontSize: 12,
          ),
          labelLarge: GoogleFonts.montserrat(
            color: Colors.white,
            letterSpacing: 0.8,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // home: const MainPage(),
      home: MovieVideoViewer(
        getMainMovieUrl: getMainMovieUrl,
        getMainMovieID: getMainMovieID,
        getWatchTime: getWatchTime,
        playType: 1,
        movieTitle: movieTitle,
        thumbnail: thumbnail,
      ),
    );
  }
}

//--------------------//
//VIDEO VIEWER WIDGETS//
//--------------------//
class MovieVideoViewer extends StatefulWidget {
  MovieVideoViewer(
      {super.key,
      required this.movieTitle,
      required this.thumbnail,
      required this.getMainMovieUrl,
      required this.getMainMovieID,
      required this.getWatchTime,
      required this.playType});

  // const MovieVideoViewer(
  //     this.movie, {Key? key}
  //     ) : super(key: key);

  // final Movie movie;

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
  late Timer _timer;
  final String _downloadUrl = "";
  final String _loadTrailerUrl = "";
  String _id = "";
  String _email = "";
  String _phone = "";
  String _name = "";
  final String _firstname = "";
  final String _lastname = "";
  final String _dob = "";
  final String _gender = "";
  String _plan = "";
  String _plan_expiry = "";
  final String _photo = "";
  final String _otp = "";
  String _tvcode = "";
  String _referal_code = "";
  String _credits_used = "";
  String _refferer = "";
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  bool isSeekDuration = false;
  late final _decryptedVideo;
  bool enableController = false;
  late File _videoFile;

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
    });
    super.initState();
    ScreenProtector.preventScreenshotOn();
    // blockScreenShot();

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
      // _decryptedVideo = await decryptFile(videFile, AppConfig.encryptionKey, widget.getMainMovieUrl + '.mp4');

      // File videFile = new File(widget.getMainMovieUrl);
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
      ]),
    );
  }

  @override
  void dispose() {
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
      _id = pref.getString(AppPreferences.id) ?? '';
      _email = pref.getString(AppPreferences.email) ?? '';
      _phone = pref.getString(AppPreferences.phone) ?? '';
      _name = pref.getString(AppPreferences.name) ?? '';
      _plan = pref.getString(AppPreferences.plan) ?? '';
      _plan_expiry = pref.getString(AppPreferences.plan_expiry) ?? '';
      _tvcode = pref.getString(AppPreferences.tvcode) ?? '';
      _referal_code = pref.getString(AppPreferences.referal_code) ?? '';
      _credits_used = pref.getString(AppPreferences.credits_used) ?? '';
      _refferer = pref.getString(AppPreferences.refferer) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';

      print("_userToken1: $_token");

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';
    });
  }

  void getSeekPosition() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        if (_controller.isPlaying) {
          final Duration currentPostion = _controller.position;
          final Duration total = _controller.duration;
          var watchingSeconds = currentPostion.inSeconds;

          final percentage =
              (currentPostion.inSeconds / total.inSeconds * 100).truncate();
          print(
              "currentPostion:${currentPostion.inSeconds} - Total: ${total.inSeconds}");
          print("Position percent:  $percentage%");
          print("_userToken: $_token");
          print("_watchingSeconds: $watchingSeconds");

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

class SerieVideoViewer extends StatefulWidget {
  const SerieVideoViewer(this.serie, {super.key});

  final Serie serie;

  @override
  _SerieVideoViewerState createState() => _SerieVideoViewerState();
}

class _SerieVideoViewerState extends State<SerieVideoViewer> {
  final VideoViewerController controller = VideoViewerController();
  String episode = "";
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
        style: CustomVideoViewerStyle(movie: widget.serie, context: context)
            .copyWith(
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
    //TODO enable auto orientation
    _subscription = NativeDeviceOrientationCommunicator()
        .onOrientationChanged()
        .listen(_onOrientationChanged);
    super.initState();
    ScreenProtector.preventScreenshotOn();
    // widget.controller.openFullScreen();
  }

  void _onOrientationChanged(NativeDeviceOrientation orientation) {
    final bool isFullScreen = widget.controller.isFullScreen;
    final bool isLandscape =
        orientation == NativeDeviceOrientation.landscapeLeft ||
            orientation == NativeDeviceOrientation.landscapeRight;
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
