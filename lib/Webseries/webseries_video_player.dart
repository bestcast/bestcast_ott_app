import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:bestcaststudios/app_config/app_preferences.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/loading_widget.dart';
import 'Models/webseries_models.dart';
import 'webseries_api_service.dart';

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
  late VideoPlayerController _controller;
  final WebseriesApiService _apiService = WebseriesApiService();

  late WebseriesEpisodeModel _currentEpisode;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _progressSyncTimer;

  String _token = "";
  String _profileId = "";

  // Auto-next overlay state
  bool _showNextOverlay = false;
  bool _nextOverlayCancelled = false;
  int _overlayCountdown = 10;
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.episode;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final pref = await SharedPreferences.getInstance();
    _token = pref.getString(AppPreferences.token) ?? '';
    _profileId = pref.getString(AppPreferences.profileID) ?? '';

    String videoUrl = _currentEpisode.videoUrl.isNotEmpty
        ? _currentEpisode.videoUrl
        : _currentEpisode.moviesource;

    if (videoUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video source URL not available")),
        );
      }
      return;
    }

    if (!videoUrl.startsWith('http://') && !videoUrl.startsWith('https://')) {
      videoUrl = videoUrl.startsWith('/')
          ? '${AppConfig.BaseUrl}$videoUrl'
          : '${AppConfig.BaseUrl}/$videoUrl';
    }

    print("Initializing Webseries Player with URL: $videoUrl");

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await _controller.initialize();
      _controller.addListener(_videoPlayerListener);

      // Check resume position
      int resumeSecs = 0;
      if (_currentEpisode.episodeUser != null &&
          _currentEpisode.episodeUser!.watchTime.isNotEmpty) {
        resumeSecs = int.tryParse(_currentEpisode.episodeUser!.watchTime) ?? 0;
      }
      if (resumeSecs > 0 && resumeSecs < _controller.value.duration.inSeconds - 5) {
        await _controller.seekTo(Duration(seconds: resumeSecs));
      }

      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
      }

      _startProgressSyncTimer();
      _startHideControlsTimer();
    } catch (e) {
      print("Error initializing video player: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Playback error: $e")),
        );
      }
    }
  }

  void _videoPlayerListener() {
    if (!mounted || !_isInitialized) return;

    final Duration position = _controller.value.position;
    final Duration duration = _controller.value.duration;

    if (duration.inSeconds > 0) {
      int remainingSecs = duration.inSeconds - position.inSeconds;

      // Show auto-next overlay in last 10 seconds if next episode exists
      WebseriesEpisodeModel? nextEp = _getNextEpisode();
      if (nextEp != null && remainingSecs <= 10 && remainingSecs > 0 && !_nextOverlayCancelled) {
        if (!_showNextOverlay) {
          _startNextOverlayCountdown(nextEp);
        }
      }

      // Automatically play next when episode ends
      if (position >= duration && !_controller.value.isPlaying) {
        _syncProgress(isCompleted: true);
        if (nextEp != null && !_nextOverlayCancelled) {
          _playNextEpisode(nextEp);
        }
      }
    }
  }

  WebseriesEpisodeModel? _getNextEpisode() {
    int currentIndex = widget.seasonEpisodes.indexWhere((ep) => ep.id == _currentEpisode.id);
    if (currentIndex >= 0 && currentIndex < widget.seasonEpisodes.length - 1) {
      return widget.seasonEpisodes[currentIndex + 1];
    }
    return null;
  }

  void _startNextOverlayCountdown(WebseriesEpisodeModel nextEp) {
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
    _overlayTimer?.cancel();
    _progressSyncTimer?.cancel();
    _hideControlsTimer?.cancel();

    await _syncProgress();
    await _controller.pause();
    _controller.removeListener(_videoPlayerListener);
    _controller.dispose();

    if (mounted) {
      setState(() {
        _isInitialized = false;
        _currentEpisode = nextEp;
        _showNextOverlay = false;
        _nextOverlayCancelled = false;
      });
      _initPlayer();
    }
  }

  void _startProgressSyncTimer() {
    _progressSyncTimer?.cancel();
    _progressSyncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isInitialized && _controller.value.isPlaying) {
        _syncProgress();
      }
    });
  }

  Future<void> _syncProgress({bool isCompleted = false}) async {
    if (!_isInitialized) return;
    int currentSecs = _controller.value.position.inSeconds;
    int totalSecs = _controller.value.duration.inSeconds;
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
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
        _startHideControlsTimer();
      }
    });
  }

  @override
  void dispose() {
    _syncProgress();
    _progressSyncTimer?.cancel();
    _hideControlsTimer?.cancel();
    _overlayTimer?.cancel();
    if (_isInitialized) {
      _controller.removeListener(_videoPlayerListener);
      _controller.dispose();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WebseriesEpisodeModel? nextEp = _getNextEpisode();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                  if (_showControls) {
                    _startHideControlsTimer();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio > 0
                            ? _controller.value.aspectRatio
                            : 16 / 9,
                        child: VideoPlayer(_controller),
                      ),
                    ),

                    // Controls Overlay
                    if (_showControls) ...[
                      // Top Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${widget.webseriesTitle} - ${_currentEpisode.title}",
                                  style: const TextStyle(
                                    color: Colors.white,
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

                      // Center Play/Pause
                      Center(
                        child: IconButton(
                          iconSize: 64,
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),

                      // Bottom Progress Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.white24,
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_controller.value.position),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.duration),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Next Episode Overlay (Bottom Right)
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
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                    onPressed: () => _playNextEpisode(nextEp),
                                    child: const Text("Play Now", style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                      side: const BorderSide(color: Colors.white38),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              )
            : const LoadingWidget(),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
