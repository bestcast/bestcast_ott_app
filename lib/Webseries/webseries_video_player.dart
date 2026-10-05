import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpers/helpers.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:bestcaststudios/app_config/app_preferences.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:bestcaststudios/common_files/background_loading_widget.dart';
import 'package:bestcaststudios/streamingpalyer/video_player_source/video_viewer.dart';
import 'package:bestcaststudios/streamingpalyer/video_view_player.dart';
import 'Models/webseries_models.dart';
import 'webseries_api_service.dart';

class CustomWebseriesViewerStyle extends VideoViewerStyle {
  CustomWebseriesViewerStyle({
    required String seriesTitle,
    required String episodeTitle,
    required BuildContext context,
    required VoidCallback onBack,
  }) : super(
          textStyle: context.textTheme.titleMedium,
          playAndPauseStyle: PlayAndPauseWidgetStyle(
            background: context.color.primary,
          ),
          progressBarStyle: ProgressBarStyle(
            bar: BarStyle.progress(color: context.color.primary),
          ),
          header: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$seriesTitle - $episodeTitle",
                      style: const TextStyle(
                        color: AppDefaultColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
}

class WebseriesVideoPlayer extends StatefulWidget {
  final WebseriesEpisodeModel episode;
  final String webseriesTitle;
  final List<WebseriesEpisodeModel> seasonEpisodes;
  final String webseriesId;

  const WebseriesVideoPlayer({
    super.key,
    required this.episode,
    required this.webseriesTitle,
    required this.seasonEpisodes,
    required this.webseriesId,
  });

  @override
  State<WebseriesVideoPlayer> createState() => _WebseriesVideoPlayerState();
}

class _WebseriesVideoPlayerState extends State<WebseriesVideoPlayer> {
  VideoViewerController _controller = VideoViewerController();
  final WebseriesApiService _apiService = WebseriesApiService();

  late WebseriesEpisodeModel _currentEpisode;
  bool enableController = false;
  bool isSeekDuration = false;

  String _token = "";
  String _profileId = "";

  // Auto-next overlay state
  bool _showNextOverlay = false;
  bool _nextOverlayCancelled = false;
  bool _isSwitchingEpisode = false;
  int _overlayCountdown = 10;
  Timer? _overlayTimer;
  Timer? _playbackTimer;
  Timer? _seekTimer;
  int _syncTickCounter = 0;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.episode;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    ScreenProtector.preventScreenshotOn();
    _controller.addListener(_videoPlayerListener);

    _loadPreferences();

    int resumeSecs = _getEpisodeResumeSeconds(_currentEpisode);
    if (resumeSecs > 0) {
      isSeekDuration = true;
    }

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          enableController = true;
        });

        if (resumeSecs > 0) {
          _seekTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                isSeekDuration = false;
              });
              _controller.seekTo(Duration(seconds: resumeSecs));
              _controller.play();
            }
          });
        }

        _startPlaybackTimer();
      }
    });
  }

  Future<void> _loadPreferences() async {
    final pref = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _token = pref.getString(AppPreferences.token) ?? '';
        _profileId = pref.getString(AppPreferences.profileID) ?? '';
      });
    }
  }

  int _getEpisodeResumeSeconds(WebseriesEpisodeModel ep) {
    int resumeSecs = 0;
    if (ep.episodeUser != null && ep.episodeUser!.watchTime.isNotEmpty) {
      resumeSecs = int.tryParse(ep.episodeUser!.watchTime) ?? 0;
    }
    return resumeSecs;
  }

  String _getVideoUrl(WebseriesEpisodeModel ep) {
    String videoUrl = ep.videoUrl.isNotEmpty ? ep.videoUrl : ep.moviesource;
    if (videoUrl.isEmpty) return "";

    if (!videoUrl.startsWith('http://') && !videoUrl.startsWith('https://')) {
      videoUrl = videoUrl.startsWith('/')
          ? '${AppConfig.BaseUrl}$videoUrl'
          : '${AppConfig.BaseUrl}/$videoUrl';
    }
    return videoUrl;
  }

  void _videoPlayerListener() {
    if (!mounted || !enableController) return;

    final Duration position = _controller.position;
    final Duration duration = _controller.duration;

    if (duration.inSeconds > 0) {
      int remainingSecs = duration.inSeconds - position.inSeconds;

      WebseriesEpisodeModel? nextEp = _getNextEpisode();
      if (nextEp != null && remainingSecs <= 10 && remainingSecs > 0 && !_nextOverlayCancelled) {
        if (!_showNextOverlay) {
          _startNextOverlayCountdown(nextEp);
        }
      }

      if (position >= duration && !_controller.isPlaying && !_isSwitchingEpisode) {
        _syncProgress(isCompleted: true);
        if (nextEp != null && !_nextOverlayCancelled) {
          _playNextEpisode(nextEp);
        }
      }
    }
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !enableController) return;

      if (_controller.isPlaying) {
        final Duration position = _controller.position;
        final Duration duration = _controller.duration;

        if (duration.inSeconds > 0) {
          int remainingSecs = duration.inSeconds - position.inSeconds;

          WebseriesEpisodeModel? nextEp = _getNextEpisode();
          if (nextEp != null && remainingSecs <= 10 && remainingSecs > 0 && !_nextOverlayCancelled) {
            if (!_showNextOverlay) {
              _startNextOverlayCountdown(nextEp);
            }
          }

          if ((position >= duration || (duration.inSeconds > 5 && remainingSecs <= 1 && !_controller.isPlaying)) &&
              !_isSwitchingEpisode) {
            _syncProgress(isCompleted: true);
            if (nextEp != null && !_nextOverlayCancelled) {
              _playNextEpisode(nextEp);
            }
          }
        }

        _syncTickCounter++;
        if (_syncTickCounter >= 15) {
          _syncTickCounter = 0;
          _syncProgress();
        }
      }
    });
  }

  WebseriesEpisodeModel? _getNextEpisode() {
    int currentIndex = widget.seasonEpisodes.indexWhere((ep) => ep.id == _currentEpisode.id);
    if (currentIndex >= 0 && currentIndex < widget.seasonEpisodes.length - 1) {
      return widget.seasonEpisodes[currentIndex + 1];
    }
    return null;
  }

  void _startNextOverlayCountdown(WebseriesEpisodeModel nextEp) {
    if (_controller.isFullScreen) {
      _controller.closeFullScreen();
    }
    setState(() {
      _showNextOverlay = true;
      _overlayCountdown = 10;
    });

    _overlayTimer?.cancel();
    _overlayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_overlayCountdown > 1) {
        setState(() {
          _overlayCountdown--;
        });
      } else {
        timer.cancel();
        _playNextEpisode(nextEp);
      }
    });
  }

  void _cancelNextOverlay() {
    _overlayTimer?.cancel();
    setState(() {
      _showNextOverlay = false;
      _nextOverlayCancelled = true;
    });
  }

  void _playNextEpisode(WebseriesEpisodeModel nextEp) async {
    if (_isSwitchingEpisode) return;
    _isSwitchingEpisode = true;

    _overlayTimer?.cancel();
    _playbackTimer?.cancel();
    _seekTimer?.cancel();

    await _syncProgress(isCompleted: true);

    if (!mounted) return;

    if (_controller.isFullScreen) {
      _controller.closeFullScreen();
    }

    int nextResumeSecs = _getEpisodeResumeSeconds(nextEp);

    setState(() {
      enableController = false;
      _currentEpisode = nextEp;
      _showNextOverlay = false;
      _nextOverlayCancelled = false;
      _syncTickCounter = 0;
      isSeekDuration = nextResumeSecs > 0;
    });

    _controller.removeListener(_videoPlayerListener);

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    _controller = VideoViewerController();
    _controller.addListener(_videoPlayerListener);

    setState(() {
      enableController = true;
    });

    if (nextResumeSecs > 0) {
      _seekTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isSeekDuration = false;
          });
          _controller.seekTo(Duration(seconds: nextResumeSecs));
          _controller.play();
        }
      });
    }

    _startPlaybackTimer();
    _isSwitchingEpisode = false;
  }

  Future<void> _syncProgress({bool isCompleted = false}) async {
    if (!enableController) return;
    try {
      int currentSecs = _controller.position.inSeconds;
      int totalSecs = _controller.duration.inSeconds;
      if (totalSecs <= 0) return;

      int percent = isCompleted ? 100 : ((currentSecs / totalSecs) * 100).truncate();
      int watchedStatus = (isCompleted || percent >= 90) ? 1 : 0;

      await _apiService.setUserEpisodeProgress(
        token: _token,
        profileId: _profileId,
        episodeId: _currentEpisode.id,
        watchTime: currentSecs,
        watchedPercent: percent,
        watching: 1,
        watched: watchedStatus,
        movieDuration: totalSecs,
      );
    } catch (e) {
      print("Error syncing webseries episode progress: $e");
    }
  }

  void _handleBack() {
    if (_controller.isFullScreen) {
      _controller.closeFullScreen();
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _syncProgress();
    _playbackTimer?.cancel();
    _overlayTimer?.cancel();
    _seekTimer?.cancel();
    _controller.removeListener(_videoPlayerListener);
    ScreenProtector.preventScreenshotOff();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WebseriesEpisodeModel? nextEp = _getNextEpisode();
    String videoUrl = _getVideoUrl(_currentEpisode);

    return PopScope(
      canPop: !_controller.isFullScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _controller.isFullScreen) {
          _controller.closeFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: VideoViewerOrientation(
          controller: _controller,
          child: Stack(
            children: [
              Center(
                child: enableController && videoUrl.isNotEmpty
                    ? VideoViewer(
                        key: ValueKey(_currentEpisode.id),
                        controller: _controller,
                        autoPlay: true,
                        onFullscreenFixLandscape: true,
                        source: {
                          _currentEpisode.title.isNotEmpty ? _currentEpisode.title : "Episode": VideoSource(
                            video: VideoPlayerController.networkUrl(Uri.parse(videoUrl)),
                          ),
                        },
                        style: CustomWebseriesViewerStyle(
                          seriesTitle: widget.webseriesTitle,
                          episodeTitle: _currentEpisode.title,
                          context: context,
                          onBack: _handleBack,
                        ),
                      )
                    : null,
              ),
              if (isSeekDuration || !enableController)
                const BackgroundLoadingWidget(),
              if (_showNextOverlay && nextEp != null)
                Positioned(
                  bottom: 60,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Up Next in $_overlayCountdown s",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextEp.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => _playNextEpisode(nextEp),
                              child: const Text("Play Now", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white38),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: _cancelNextOverlay,
                              child: const Text("Cancel", style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
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
