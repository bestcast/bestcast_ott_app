import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:bestcaststudios/app_config/app_preferences.dart';
import 'package:bestcaststudios/app_config/app_utils.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/authendication/login_page.dart';
import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:bestcaststudios/common_files/shimmer/shimmer_skeletons.dart';
import 'package:bestcaststudios/common_files/shimmer/app_shimmer_image.dart';
import 'package:bestcaststudios/streamingpalyer/components/video_action_buttons.dart';
import 'package:bestcaststudios/plan_details/plan_details.dart';
import 'package:bestcaststudios/Webseries/Models/webseries_models.dart';
import 'package:bestcaststudios/Webseries/webseries_api_service.dart';
import 'package:bestcaststudios/Webseries/webseries_video_player.dart';

class WebseriesDetailScreen extends StatefulWidget {
  final String webseriesId;
  final WebseriesItemModel? initialItem;

  const WebseriesDetailScreen({
    super.key,
    required this.webseriesId,
    this.initialItem,
  });

  @override
  State<WebseriesDetailScreen> createState() => _WebseriesDetailScreenState();
}

class _WebseriesDetailScreenState extends State<WebseriesDetailScreen> {
  final WebseriesApiService _apiService = WebseriesApiService();

  bool _isLoading = true;
  bool _isAuthLoaded = false;
  String _token = "";
  String _profileId = "";
  bool _loggedStatus = false;
  String _planStatus = "";

  bool get _hasSubscription =>
      _isAuthLoaded && (_planStatus == "1" || (_webseriesDetail?.movieAccess == 1));

  WebseriesItemModel? _webseriesDetail;
  int _selectedSeasonIndex = 0;

  // Trailer Player Controller
  VideoPlayerController? _trailerController;
  bool _isTrailerPlaying = false;
  bool _isTrailerMuted = true;
  bool _showTrailerControls = false;
  double _trailerProgressValue = 0.0;
  Timer? _hideControlsTimer;
  bool _isSynopsisExpanded = false;

  // Interaction States
  bool _isRated = false;
  bool _isLike = false;
  bool _isDisLike = false;

  Widget _buildPlayerCircleButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: isPrimary
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: isPrimary ? 1.5 : 1.0,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _webseriesDetail = widget.initialItem;
    // Always keep loading true until auth & subscription status is verified from SharedPreferences
    _isLoading = true;
    _isAuthLoaded = false;

    if (_webseriesDetail != null && _webseriesDetail!.trailer.isNotEmpty) {
      _initTrailerPlayer(_webseriesDetail!.trailer);
    }

    _loadInitialData();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    try {
      _trailerController?.removeListener(_onTrailerProgress);
      _trailerController?.pause();
      _trailerController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onTrailerProgress() {
    if (!mounted || _trailerController == null) return;
    try {
      if (!_trailerController!.value.isInitialized) return;
      final double duration = _trailerController!.value.duration.inSeconds.toDouble();
      if (duration > 0) {
        final double progress = (_trailerController!.value.position.inSeconds.toDouble() / duration).clamp(0.0, 1.0);
        if ((progress - _trailerProgressValue).abs() > 0.005) {
          if (mounted) {
            setState(() {
              _trailerProgressValue = progress;
            });
          }
        }
      }
    } catch (_) {}
  }

  void _initTrailerPlayer(String trailerUrl) {
    if (trailerUrl.isEmpty || !trailerUrl.startsWith('http')) return;
    try {
      _trailerController?.removeListener(_onTrailerProgress);
      _trailerController?.dispose();
    } catch (_) {}

    _trailerController = VideoPlayerController.networkUrl(Uri.parse(trailerUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        _trailerController?.setVolume(_isTrailerMuted ? 0.0 : 1.0);
        _trailerController?.setLooping(true);
        _trailerController?.play();
        setState(() {
          _isTrailerPlaying = true;
        });
        _trailerController?.addListener(_onTrailerProgress);
        _startHideControlsTimer();
      }).catchError((error) {
        print("Trailer player error: $error");
      });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showTrailerControls = false;
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String token = pref.getString(AppPreferences.token) ?? '';
      final String profileId = pref.getString(AppPreferences.profileID) ?? '';
      final bool logged = pref.getBool(AppPreferences.loggedStatus) ?? false;
      final String plan = pref.get(AppPreferences.plan_status)?.toString() ?? '';

      if (mounted) {
        setState(() {
          _token = token;
          _profileId = profileId;
          _loggedStatus = logged;
          _planStatus = plan;
          _isAuthLoaded = true;

          // If initial item already contains seasons, reveal content immediately
          // with verified auth and subscription status to prevent any flicker!
          if (_webseriesDetail != null && _webseriesDetail!.seasons.isNotEmpty) {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthLoaded = true;
        });
      }
    }

    await _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_webseriesDetail == null || _webseriesDetail!.seasons.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      WebseriesItemModel? watchDetail;
      WebseriesItemModel? fullDetail;
      WebseriesBannerModel? bannerDetail;

      if (_token.isNotEmpty) {
        final results = await Future.wait([
          _apiService.getWebseriesWatchDetail(
            token: _token,
            webseriesId: widget.webseriesId,
            profileId: _profileId,
          ),
          _apiService.getWebseriesDetail(
            token: _token,
            webseriesId: widget.webseriesId,
            profileId: _profileId,
          ),
          _apiService.getSeasonEpisodeBannerList(
            token: _token,
            webseriesId: widget.webseriesId,
            profileId: _profileId,
          ),
        ]);

        watchDetail = results[0] as WebseriesItemModel?;
        fullDetail = results[1] as WebseriesItemModel?;
        bannerDetail = results[2] as WebseriesBannerModel?;
      }

      // Guest / Fallback: If logged out or authenticated calls yielded empty seasons
      WebseriesItemModel? guestDetail;
      if (watchDetail == null && fullDetail == null && (_webseriesDetail == null || _webseriesDetail!.seasons.isEmpty)) {
        guestDetail = await _apiService.getGuestWebseriesDetail(widget.webseriesId);
      }

      if (mounted) {
        setState(() {
          WebseriesItemModel? base = watchDetail ?? fullDetail ?? guestDetail ?? widget.initialItem;
          if (base != null) {
            String image = '';
            if (base.image.isNotEmpty && base.image != 'null') {
              image = base.image;
            } else if (fullDetail?.image.isNotEmpty == true && fullDetail!.image != 'null') {
              image = fullDetail.image;
            } else if (bannerDetail?.image.isNotEmpty == true && bannerDetail!.image != 'null') {
              image = bannerDetail.image;
            } else if (bannerDetail?.webseries?.image.isNotEmpty == true && bannerDetail!.webseries!.image != 'null') {
              image = bannerDetail.webseries!.image;
            } else if (guestDetail?.image.isNotEmpty == true && guestDetail!.image != 'null') {
              image = guestDetail.image;
            } else if (widget.initialItem?.image.isNotEmpty == true && widget.initialItem!.image != 'null') {
              image = widget.initialItem!.image;
            }

            String thumbnail = '';
            if (base.thumbnail.isNotEmpty && base.thumbnail != 'null') {
              thumbnail = base.thumbnail;
            } else if (fullDetail?.thumbnail.isNotEmpty == true && fullDetail!.thumbnail != 'null') {
              thumbnail = fullDetail.thumbnail;
            } else if (bannerDetail?.thumbnail.isNotEmpty == true && bannerDetail!.thumbnail != 'null') {
              thumbnail = bannerDetail.thumbnail;
            } else if (bannerDetail?.webseries?.thumbnail.isNotEmpty == true && bannerDetail!.webseries!.thumbnail != 'null') {
              thumbnail = bannerDetail.webseries!.thumbnail;
            } else if (guestDetail?.thumbnail.isNotEmpty == true && guestDetail!.thumbnail != 'null') {
              thumbnail = guestDetail.thumbnail;
            } else if (widget.initialItem?.thumbnail.isNotEmpty == true && widget.initialItem!.thumbnail != 'null') {
              thumbnail = widget.initialItem!.thumbnail;
            }

            String medium = base.medium.isNotEmpty && base.medium != 'null' ? base.medium : (fullDetail?.medium ?? guestDetail?.medium ?? widget.initialItem?.medium ?? '');
            String portrait = base.portrait.isNotEmpty && base.portrait != 'null' ? base.portrait : (fullDetail?.portrait ?? guestDetail?.portrait ?? widget.initialItem?.portrait ?? '');
            String portraitsmall = base.portraitsmall.isNotEmpty && base.portraitsmall != 'null' ? base.portraitsmall : (fullDetail?.portraitsmall ?? guestDetail?.portraitsmall ?? widget.initialItem?.portraitsmall ?? '');
            String content = base.content.isNotEmpty ? base.content : (fullDetail?.content ?? guestDetail?.content ?? widget.initialItem?.content ?? '');

            List<WebseriesCastModel> casts = fullDetail != null && fullDetail.casts.isNotEmpty ? fullDetail.casts : (guestDetail?.casts.isNotEmpty == true ? guestDetail!.casts : base.casts);

            List<WebseriesSeasonModel> seasons = base.seasons.isNotEmpty ? base.seasons : (fullDetail?.seasons ?? guestDetail?.seasons ?? widget.initialItem?.seasons ?? []);

            String trailer = base.trailer.isNotEmpty ? base.trailer : (fullDetail?.trailer ?? guestDetail?.trailer ?? widget.initialItem?.trailer ?? '');

            String publishedDate = base.publishedDate.isNotEmpty ? base.publishedDate : (fullDetail?.publishedDate ?? guestDetail?.publishedDate ?? widget.initialItem?.publishedDate ?? '');

            String certificate = base.certificate.isNotEmpty ? base.certificate : (fullDetail?.certificate ?? guestDetail?.certificate ?? widget.initialItem?.certificate ?? '');

            String tagText = base.tagText.isNotEmpty ? base.tagText : (fullDetail?.tagText ?? guestDetail?.tagText ?? widget.initialItem?.tagText ?? '');

            _webseriesDetail = WebseriesItemModel(
              id: base.id,
              title: base.title.isNotEmpty ? base.title : (fullDetail?.title ?? guestDetail?.title ?? widget.initialItem?.title ?? ''),
              content: content,
              publishedDate: publishedDate,
              certificate: certificate,
              tagText: tagText,
              thumbnail: thumbnail,
              image: image,
              medium: medium,
              portrait: portrait,
              portraitsmall: portraitsmall,
              movieAccess: base.movieAccess != 0 ? base.movieAccess : (guestDetail?.movieAccess ?? widget.initialItem?.movieAccess ?? 0),
              trailer: trailer,
              topten: base.topten,
              resumeEpisodeId: base.resumeEpisodeId,
              resumeDate: base.resumeDate,
              firstEpisodeId: base.firstEpisodeId,
              seasons: seasons,
              casts: casts,
            );

            if (_trailerController == null && trailer.isNotEmpty) {
              _initTrailerPlayer(trailer);
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching webseries details: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildImageUrl(String path) {
    if (path.isEmpty || path == 'null') return '';
    path = path.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '${AppConfig.BaseUrl}$path';
    }
    return '${AppConfig.BaseUrl}/$path';
  }

  String _getHeaderBannerUrl() {
    if (_webseriesDetail != null) {
      if (_webseriesDetail!.image.isNotEmpty && _webseriesDetail!.image != 'null') {
        return _buildImageUrl(_webseriesDetail!.image);
      }
      if (_webseriesDetail!.medium.isNotEmpty && _webseriesDetail!.medium != 'null') {
        return _buildImageUrl(_webseriesDetail!.medium);
      }
      if (_webseriesDetail!.thumbnail.isNotEmpty && _webseriesDetail!.thumbnail != 'null') {
        return _buildImageUrl(_webseriesDetail!.thumbnail);
      }
      if (_webseriesDetail!.portrait.isNotEmpty && _webseriesDetail!.portrait != 'null') {
        return _buildImageUrl(_webseriesDetail!.portrait);
      }
      if (_webseriesDetail!.portraitsmall.isNotEmpty && _webseriesDetail!.portraitsmall != 'null') {
        return _buildImageUrl(_webseriesDetail!.portraitsmall);
      }
    }

    if (widget.initialItem != null) {
      if (widget.initialItem!.image.isNotEmpty && widget.initialItem!.image != 'null') {
        return _buildImageUrl(widget.initialItem!.image);
      }
      if (widget.initialItem!.thumbnail.isNotEmpty && widget.initialItem!.thumbnail != 'null') {
        return _buildImageUrl(widget.initialItem!.thumbnail);
      }
      if (widget.initialItem!.medium.isNotEmpty && widget.initialItem!.medium != 'null') {
        return _buildImageUrl(widget.initialItem!.medium);
      }
      if (widget.initialItem!.portrait.isNotEmpty && widget.initialItem!.portrait != 'null') {
        return _buildImageUrl(widget.initialItem!.portrait);
      }
    }

    // Fallback: check episodes for an image/thumbnail
    if (_webseriesDetail != null && _webseriesDetail!.seasons.isNotEmpty) {
      for (var season in _webseriesDetail!.seasons) {
        for (var ep in season.episodes) {
          if (ep.image.isNotEmpty && ep.image != 'null') {
            return _buildImageUrl(ep.image);
          }
          if (ep.thumbnail.isNotEmpty && ep.thumbnail != 'null') {
            return _buildImageUrl(ep.thumbnail);
          }
        }
      }
    }

    return '';
  }

  String _stripHtml(String htmlString) {
    if (htmlString.isEmpty) return "";
    String text = htmlString.replaceAll(RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true), ' ');

    const Map<String, String> htmlEntities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&quot;': '"',
      '&apos;': "'",
      '&rsquo;': "’",
      '&lsquo;': "‘",
      '&rdquo;': '”',
      '&ldquo;': '“',
      '&ndash;': '–',
      '&mdash;': '—',
      '&hellip;': '…',
      '&bull;': '•',
      '&copy;': '©',
      '&trade;': '™',
      '&reg;': '®',
      '&lt;': '<',
      '&gt;': '>',
    };

    htmlEntities.forEach((entity, replacement) {
      text = text.replaceAll(entity, replacement);
    });

    text = text.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1) ?? '');
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    text = text.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1) ?? '', radix: 16);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    return text.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  }

  String _formatYear(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      return AppUtils().getDateTimeToYear(dateStr);
    } catch (_) {
      try {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) return dt.year.toString();
      } catch (_) {}
      return dateStr.length >= 4 ? dateStr.substring(0, 4) : dateStr;
    }
  }

  WebseriesEpisodeModel? _findResumeOrFirstEpisode() {
    if (_webseriesDetail == null || _webseriesDetail!.seasons.isEmpty) {
      return null;
    }

    if (_webseriesDetail!.resumeEpisodeId != null && _webseriesDetail!.resumeEpisodeId!.isNotEmpty) {
      for (var season in _webseriesDetail!.seasons) {
        for (var ep in season.episodes) {
          if (ep.id == _webseriesDetail!.resumeEpisodeId) {
            return ep;
          }
        }
      }
    }

    // Fallback to first episode of first season that has episodes
    for (var season in _webseriesDetail!.seasons) {
      if (season.episodes.isNotEmpty) {
        return season.episodes.first;
      }
    }
    return null;
  }

  void _playEpisode(WebseriesEpisodeModel episode, List<WebseriesEpisodeModel> currentSeasonEpisodes) {
    if (!_isAuthLoaded) return;
    if (!_loggedStatus || _token.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      ).then((_) => _loadInitialData());
      return;
    }

    if (!_hasSubscription) {
      _trailerController?.pause();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlanDetailsPage()),
      ).then((_) => _loadInitialData());
      return;
    }

    _trailerController?.pause();
    setState(() {
      _isTrailerPlaying = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebseriesVideoPlayer(
          episode: episode,
          webseriesTitle: _webseriesDetail?.title ?? '',
          seasonEpisodes: currentSeasonEpisodes,
          webseriesId: widget.webseriesId,
        ),
      ),
    ).then((_) {
      // Refresh progress after returning from player
      _fetchDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isAuthLoaded) {
      return Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          backgroundColor: AppDefaultColors.appColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 48,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              _trailerController?.pause();
              Navigator.pop(context);
            },
          ),
        ),
        body: const DetailScreenSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: AppDefaultColors.appColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            _trailerController?.pause();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTrailerMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isTrailerMuted = !_isTrailerMuted;
                _trailerController?.setVolume(_isTrailerMuted ? 0.0 : 1.0);
              });
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _webseriesDetail == null
          ? const Center(
              child: Text(
                "Webseries details not found",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVideoPlayerOrBanner(),
                        _buildInfoSection(),
                        if (_loggedStatus) ...[
                          _buildSeasonTabs(),
                          _buildEpisodeList(),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.2),
            const Color(0xFFFF8C00).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _trailerController?.pause();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanDetailsPage()),
            ).then((_) => _loadInitialData());
          },
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SUBSCRIBE TO WATCH",
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Unlock this webseries & entire Bestcast library in Full HD",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerOrBanner() {
    final bool hasTrailer = _trailerController != null && _trailerController!.value.isInitialized;
    final double aspectRatio = hasTrailer
        ? (_trailerController!.value.aspectRatio > 0 ? _trailerController!.value.aspectRatio : 16 / 9)
        : (16 / 9);

    if (hasTrailer) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showTrailerControls = !_showTrailerControls;
                    if (_showTrailerControls && _trailerController!.value.isPlaying) {
                      _startHideControlsTimer();
                    }
                  });
                },
                child: VideoPlayer(_trailerController!),
              ),
              // Controls Overlay
              if (_showTrailerControls)
                AnimatedOpacity(
                  opacity: _showTrailerControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.38),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildPlayerCircleButton(
                            icon: Icons.replay_10_rounded,
                            size: 42,
                            iconSize: 24,
                            onTap: () {
                              if (_trailerController != null && _trailerController!.value.isInitialized) {
                                _trailerController!.seekTo(
                                  Duration(seconds: _trailerController!.value.position.inSeconds - 10),
                                );
                                _startHideControlsTimer();
                              }
                            },
                          ),
                          const SizedBox(width: 30),
                          _buildPlayerCircleButton(
                            icon: _isTrailerPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 56,
                            iconSize: 34,
                            isPrimary: true,
                            onTap: () {
                              setState(() {
                                if (_trailerController != null && _trailerController!.value.isInitialized) {
                                  if (_isTrailerPlaying) {
                                    _trailerController!.pause();
                                  } else {
                                    _trailerController!.play();
                                  }
                                  _isTrailerPlaying = !_isTrailerPlaying;
                                }
                                _startHideControlsTimer();
                              });
                            },
                          ),
                          const SizedBox(width: 30),
                          _buildPlayerCircleButton(
                            icon: Icons.forward_10_rounded,
                            size: 42,
                            iconSize: 24,
                            onTap: () {
                              if (_trailerController != null && _trailerController!.value.isInitialized) {
                                _trailerController!.seekTo(
                                  Duration(seconds: _trailerController!.value.position.inSeconds + 10),
                                );
                                _startHideControlsTimer();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Bottom Timeline Scrim & Progress Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 2, top: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                      activeTrackColor: AppDefaultColors.thikRed,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.35),
                      thumbColor: AppDefaultColors.thikRed,
                      overlayColor: AppDefaultColors.thikRed.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _trailerProgressValue.clamp(0.0, 1.0),
                      onChanged: (double value) {
                        setState(() {
                          _trailerProgressValue = value.clamp(0.0, 1.0);
                          if (_trailerController != null && _trailerController!.value.isInitialized) {
                            final Duration newPosition = Duration(
                              seconds: (_trailerController!.value.duration.inSeconds * _trailerProgressValue).toInt(),
                            );
                            _trailerController!.seekTo(newPosition);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Static Backdrop Banner Fallback
    String bgUrl = _getHeaderBannerUrl();
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppShimmerImage(
            imageUrl: bgUrl,
            fit: BoxFit.cover,
            errorAsset: 'images/default_portrate_large.jpg',
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    String cleanContent = _stripHtml(_webseriesDetail!.content);
    String yearText = _formatYear(_webseriesDetail!.publishedDate);
    WebseriesEpisodeModel? targetEp = _findResumeOrFirstEpisode();

    final bool hasSubscription = _hasSubscription;

    String playButtonTitle = "Play";
    IconData playButtonIcon = Icons.play_arrow_rounded;

    if (!hasSubscription) {
      playButtonTitle = "Subscribe to Watch";
      playButtonIcon = Icons.workspace_premium_rounded;
    } else if (_loggedStatus && _webseriesDetail!.resumeEpisodeId != null && _webseriesDetail!.resumeEpisodeId!.isNotEmpty) {
      playButtonTitle = targetEp != null && targetEp.title.isNotEmpty
          ? "Resume (${targetEp.title})"
          : "Resume Watching";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Title
          Text(
            _stripHtml(_webseriesDetail!.title),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Metadata Badges Row (Year, Certificate, Seasons count, HD)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              if (yearText.isNotEmpty)
                Text(
                  yearText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (_webseriesDetail!.certificate.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _webseriesDetail!.certificate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (_webseriesDetail!.seasons.isNotEmpty)
                Text(
                  "${_webseriesDetail!.seasons.length} Season${_webseriesDetail!.seasons.length > 1 ? 's' : ''}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.7,
                  ),
                ),
                child: const Text(
                  "HD",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_webseriesDetail!.tagText.isNotEmpty)
                Text(
                  _stripHtml(_webseriesDetail!.tagText),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Subscription VIP Banner
          if (_isAuthLoaded && !hasSubscription)
            _buildSubscriptionBanner(),

          // Primary Play / Resume Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: !hasSubscription
                  ? const LinearGradient(
                      colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
                    )
                  : null,
              color: hasSubscription ? Colors.white : null,
              boxShadow: [
                BoxShadow(
                  color: (!hasSubscription ? const Color(0xFFFF8A00) : Colors.white).withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!_isAuthLoaded) return;
                  if (!_loggedStatus || _token.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ).then((_) => _loadInitialData());
                  } else if (!hasSubscription) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlanDetailsPage()),
                    ).then((_) => _loadInitialData());
                  } else {
                    if (targetEp != null) {
                      List<WebseriesEpisodeModel> currentSeasonEps = _webseriesDetail!.seasons.isNotEmpty ? _webseriesDetail!.seasons.first.episodes : [targetEp];
                      _playEpisode(targetEp, currentSeasonEps);
                    } else if (_webseriesDetail!.seasons.isNotEmpty && _webseriesDetail!.seasons.first.episodes.isNotEmpty) {
                      _playEpisode(_webseriesDetail!.seasons.first.episodes.first, _webseriesDetail!.seasons.first.episodes);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        playButtonIcon,
                        color: Colors.black,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        playButtonTitle,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cast & Crew Button
          _buildCastInlineSection(),

          // Synopsis / Content Text with Read More
          if (cleanContent.isNotEmpty) ...[
            Text(
              cleanContent,
              maxLines: _isSynopsisExpanded ? null : 3,
              overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 13.5,
                height: 1.5,
                letterSpacing: 0.15,
              ),
            ),
            if (cleanContent.length > 130)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _isSynopsisExpanded = !_isSynopsisExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isSynopsisExpanded ? "Show less" : "Read more",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        _isSynopsisExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),

          // Video Action Buttons (My List, Like, Dislike, Share)
          VideoActionButtons(
            isRated: _isRated,
            isLike: _isLike,
            isDisLike: _isDisLike,
            onRate: () {
              if (!_loggedStatus || _token.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((_) => _loadInitialData());
              } else {
                setState(() {
                  _isRated = !_isRated;
                });
              }
            },
            onLike: () {
              if (!_loggedStatus || _token.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((_) => _loadInitialData());
              } else {
                setState(() {
                  _isDisLike = false;
                  _isLike = !_isLike;
                });
              }
            },
            onDislike: () {
              if (!_loggedStatus || _token.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((_) => _loadInitialData());
              } else {
                setState(() {
                  _isLike = false;
                  _isDisLike = !_isDisLike;
                });
              }
            },
            onShare: () {
              final encodedTitle = Uri.encodeComponent(_webseriesDetail!.title);
              Share.share('Watch ${_webseriesDetail!.title} on Bestcast OTT, \n\nCheck it out here: ${AppConfig.BaseUrl}/search?search=$encodedTitle');
            },
          ),

          if (_loggedStatus) ...[
            const SizedBox(height: 12),
            Divider(
              color: Colors.white.withValues(alpha: 0.1),
              height: 1,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppDefaultColors.thikRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Episodes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonTabs() {
    if (_webseriesDetail!.seasons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _webseriesDetail!.seasons.length,
          itemBuilder: (context, index) {
            bool isSelected = index == _selectedSeasonIndex;
            var season = _webseriesDetail!.seasons[index];
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedSeasonIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppDefaultColors.primaryRed : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppDefaultColors.primaryRed
                        : Colors.white.withValues(alpha: 0.1),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    season.title.isNotEmpty ? season.title : "Season ${season.seasonNumber}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEpisodeList() {
    if (_webseriesDetail!.seasons.isEmpty || _selectedSeasonIndex >= _webseriesDetail!.seasons.length) {
      return const SizedBox.shrink();
    }

    var currentSeason = _webseriesDetail!.seasons[_selectedSeasonIndex];
    var episodes = currentSeason.episodes;

    if (episodes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            "No episodes available for this season",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        var ep = episodes[index];
        String epThumb = _buildImageUrl(ep.thumbnail.isNotEmpty ? ep.thumbnail : ep.image);
        double watchedPercent = ep.episodeUser?.watchedPercent ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.8,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                HapticFeedback.lightImpact();
                _playEpisode(ep, episodes);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    // Thumbnail Stack with Progress Bar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 110,
                            height: 68,
                            child: AppShimmerImage(
                              imageUrl: epThumb,
                              fit: BoxFit.cover,
                              borderRadius: 8,
                              errorAsset: 'images/default_portrate_large.jpg',
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                        ),
                        // Progress Bar
                        if (watchedPercent > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                              child: LinearProgressIndicator(
                                value: (watchedPercent / 100).clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppDefaultColors.primaryRed),
                                minHeight: 3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Episode Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ep.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          if (ep.durationText.isNotEmpty || ep.duration.isNotEmpty)
                            Text(
                              ep.durationText.isNotEmpty ? ep.durationText : "${ep.duration} min",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (ep.contentPlain.isNotEmpty || ep.content.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              _stripHtml(ep.contentPlain.isNotEmpty ? ep.contentPlain : ep.content),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
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

  Widget _buildCastInlineSection() {
    final validCasts = _webseriesDetail?.casts.where((cast) => cast.name.trim().isNotEmpty).toList() ?? [];

    if (validCasts.isEmpty) return const SizedBox.shrink();

    List<String> directorsArray = [];
    List<String> producersArray = [];
    List<String> starringArray = [];

    for (var cast in validCasts) {
      final castName = cast.name.trim();
      final grp = cast.groupName.trim().toLowerCase();
      if (castName.isEmpty) continue;

      if ((grp.contains("director") || grp.contains("creator")) && !grp.contains("music") && !grp.contains("art")) {
        if (!directorsArray.contains(castName)) {
          directorsArray.add(castName);
        }
      } else if (grp.contains("producer") || grp.contains("production")) {
        if (!producersArray.contains(castName)) {
          producersArray.add(castName);
        }
      } else if (grp.contains("actor") || grp.contains("actress") || grp.contains("cast") || grp.contains("starring") || grp.contains("lead")) {
        if (!starringArray.contains(castName)) {
          starringArray.add(castName);
        }
      } else {
        if (!grp.contains("music") && !grp.contains("crew")) {
          if (!starringArray.contains(castName)) {
            starringArray.add(castName);
          }
        }
      }
    }

    final String starringText = starringArray.isNotEmpty ? starringArray.join(', ') : validCasts.map((c) => c.name.trim()).where((n) => !directorsArray.contains(n) && !producersArray.contains(n)).toSet().join(', ');

    final String directorLabel = directorsArray.length > 1 ? "Directors" : "Director";
    final String directorText = directorsArray.join(', ');

    final String producerLabel = producersArray.length > 1 ? "Producers" : "Producer";
    final String producerText = producersArray.join(', ');

    final String preview = starringText.isNotEmpty
        ? starringText
        : (directorText.isNotEmpty
            ? '$directorLabel: $directorText'
            : (producerText.isNotEmpty ? '$producerLabel: $producerText' : 'View full cast and technical crew'));

    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          onTap: () {
            HapticFeedback.lightImpact();
            _showCastAndCrewBottomSheet(validCasts);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Cast & Crew",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCastAndCrewBottomSheet(List<WebseriesCastModel> castList) {
    // 1. Deduplicate members by name and combine roles if different
    final Map<String, WebseriesCastModel> uniqueMap = {};
    for (var item in castList) {
      final name = item.name.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (uniqueMap.containsKey(key)) {
        final existing = uniqueMap[key]!;
        final newRole = item.groupName.trim();
        if (newRole.isNotEmpty && !existing.groupName.toLowerCase().contains(newRole.toLowerCase())) {
          uniqueMap[key] = WebseriesCastModel(
            name: existing.name,
            group: existing.group,
            groupName: "${existing.groupName}, $newRole",
            photo: existing.photo.isNotEmpty ? existing.photo : item.photo,
          );
        }
      } else {
        uniqueMap[key] = item;
      }
    }

    final uniqueList = uniqueMap.values.toList();

    // 2. Organize into categorized sections
    String getCategory(String rawRole) {
      final r = rawRole.toLowerCase().trim();
      if ((r.contains('director') || r.contains('creator')) && !r.contains('music') && !r.contains('art')) {
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

    final Map<String, List<WebseriesCastModel>> grouped = {
      'Director': [],
      'Cast & Starring': [],
      'Producers': [],
      'Music & Audio': [],
      'Crew & Technical': [],
    };

    for (var item in uniqueList) {
      final cat = getCategory(item.groupName);
      grouped[cat]!.add(item);
    }

    final List<MapEntry<String, List<WebseriesCastModel>>> activeSections = [];
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
                  Color(0xFF282828),
                  Color(0xFF181818),
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
              color: const Color(0xFF202020),
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
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
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
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
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
                        "Cast & Crew",
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
                                      final personName = castItem.name;
                                      final role = castItem.groupName;
                                      final photoUrl = _buildImageUrl(castItem.photo);

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
}
