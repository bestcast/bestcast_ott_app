import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bestcaststudios/app_config/app_preferences.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:bestcaststudios/common_files/loading_widget.dart';
import 'Models/webseries_models.dart';
import 'webseries_api_service.dart';
import 'webseries_video_player.dart';

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
  String _token = "";
  String _profileId = "";

  WebseriesItemModel? _webseriesDetail;
  int _selectedSeasonIndex = 0;
  bool _isCastExpanded = false;

  @override
  void initState() {
    super.initState();
    _webseriesDetail = widget.initialItem;
    _isLoading = _webseriesDetail == null || _webseriesDetail!.seasons.isEmpty;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final pref = await SharedPreferences.getInstance();
    _token = pref.getString(AppPreferences.token) ?? '';
    _profileId = pref.getString(AppPreferences.profileID) ?? '';

    await _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_webseriesDetail == null || _webseriesDetail!.seasons.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
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

      final watchDetail = results[0] as WebseriesItemModel?;
      final fullDetail = results[1] as WebseriesItemModel?;
      final bannerDetail = results[2] as WebseriesBannerModel?;

      if (mounted) {
        setState(() {
          WebseriesItemModel? base = watchDetail ?? fullDetail ?? widget.initialItem;
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
            } else if (widget.initialItem?.thumbnail.isNotEmpty == true && widget.initialItem!.thumbnail != 'null') {
              thumbnail = widget.initialItem!.thumbnail;
            }

            String medium = base.medium.isNotEmpty && base.medium != 'null'
                ? base.medium
                : (fullDetail?.medium ?? widget.initialItem?.medium ?? '');
            String portrait = base.portrait.isNotEmpty && base.portrait != 'null'
                ? base.portrait
                : (fullDetail?.portrait ?? widget.initialItem?.portrait ?? '');
            String portraitsmall = base.portraitsmall.isNotEmpty && base.portraitsmall != 'null'
                ? base.portraitsmall
                : (fullDetail?.portraitsmall ?? widget.initialItem?.portraitsmall ?? '');
            String content = base.content.isNotEmpty
                ? base.content
                : (fullDetail?.content ?? widget.initialItem?.content ?? '');

            List<WebseriesCastModel> casts = fullDetail != null && fullDetail.casts.isNotEmpty
                ? fullDetail.casts
                : base.casts;

            List<WebseriesSeasonModel> seasons = base.seasons.isNotEmpty
                ? base.seasons
                : (fullDetail?.seasons ?? widget.initialItem?.seasons ?? []);

            _webseriesDetail = WebseriesItemModel(
              id: base.id,
              title: base.title.isNotEmpty ? base.title : (fullDetail?.title ?? widget.initialItem?.title ?? ''),
              content: content,
              publishedDate: base.publishedDate.isNotEmpty ? base.publishedDate : (fullDetail?.publishedDate ?? ''),
              certificate: base.certificate.isNotEmpty ? base.certificate : (fullDetail?.certificate ?? ''),
              tagText: base.tagText.isNotEmpty ? base.tagText : (fullDetail?.tagText ?? ''),
              thumbnail: thumbnail,
              image: image,
              medium: medium,
              portrait: portrait,
              portraitsmall: portraitsmall,
              movieAccess: base.movieAccess,
              trailer: base.trailer.isNotEmpty ? base.trailer : (fullDetail?.trailer ?? ''),
              topten: base.topten,
              resumeEpisodeId: base.resumeEpisodeId,
              resumeDate: base.resumeDate,
              firstEpisodeId: base.firstEpisodeId,
              seasons: seasons,
              casts: casts,
            );
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
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  WebseriesEpisodeModel? _findResumeOrFirstEpisode() {
    if (_webseriesDetail == null || _webseriesDetail!.seasons.isEmpty) {
      return null;
    }

    if (_webseriesDetail!.resumeEpisodeId != null &&
        _webseriesDetail!.resumeEpisodeId!.isNotEmpty) {
      for (var season in _webseriesDetail!.seasons) {
        for (var ep in season.episodes) {
          if (ep.id == _webseriesDetail!.resumeEpisodeId) {
            return ep;
          }
        }
      }
    }

    // Fallback to first episode of first season
    if (_webseriesDetail!.seasons.first.episodes.isNotEmpty) {
      return _webseriesDetail!.seasons.first.episodes.first;
    }
    return null;
  }

  void _playEpisode(WebseriesEpisodeModel episode, List<WebseriesEpisodeModel> currentSeasonEpisodes) {
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
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _webseriesDetail?.title ?? 'Webseries',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _webseriesDetail == null
              ? const Center(
                  child: Text(
                    "Webseries details not found",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderBanner(),
                      _buildInfoSection(),
                      _buildSeasonTabs(),
                      _buildEpisodeList(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderBanner() {
    String bgUrl = _getHeaderBannerUrl();

    WebseriesEpisodeModel? targetEp = _findResumeOrFirstEpisode();

    return Stack(
      children: [
        SizedBox(
          height: 230,
          width: double.infinity,
          child: bgUrl.isNotEmpty
              ? Image.network(
                  bgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('images/default_portrate_large.jpg', fit: BoxFit.cover),
                )
              : Image.asset('images/default_portrate_large.jpg', fit: BoxFit.cover),
        ),
        Container(
          height: 230,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _webseriesDetail!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (targetEp != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    _webseriesDetail!.resumeEpisodeId != null &&
                            _webseriesDetail!.resumeEpisodeId!.isNotEmpty
                        ? "Resume Watching"
                        : "Play S1:E1",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    List<WebseriesEpisodeModel> currentSeasonEps =
                        _webseriesDetail!.seasons.isNotEmpty
                            ? _webseriesDetail!.seasons.first.episodes
                            : [targetEp];
                    _playEpisode(targetEp, currentSeasonEps);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    String cleanContent = _stripHtml(_webseriesDetail!.content);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_webseriesDetail!.publishedDate.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _webseriesDetail!.publishedDate,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              if (_webseriesDetail!.certificate.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _webseriesDetail!.certificate,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              if (_webseriesDetail!.seasons.isNotEmpty)
                Text(
                  "${_webseriesDetail!.seasons.length} Season${_webseriesDetail!.seasons.length > 1 ? 's' : ''}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
            ],
          ),
          if (cleanContent.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              cleanContent,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          _buildCastInlineSection(),
        ],
      ),
    );
  }

  Widget _buildSeasonTabs() {
    if (_webseriesDetail!.seasons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _webseriesDetail!.seasons.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedSeasonIndex;
          var season = _webseriesDetail!.seasons[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSeasonIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  season.title.isNotEmpty ? season.title : "Season ${season.seasonNumber}",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodeList() {
    if (_webseriesDetail!.seasons.isEmpty ||
        _selectedSeasonIndex >= _webseriesDetail!.seasons.length) {
      return const SizedBox.shrink();
    }

    var currentSeason = _webseriesDetail!.seasons[_selectedSeasonIndex];
    var episodes = currentSeason.episodes;

    if (episodes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            "No episodes available for this season",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        var ep = episodes[index];
        String epThumb = _buildImageUrl(ep.thumbnail.isNotEmpty ? ep.thumbnail : ep.image);
        double watchedPercent = ep.episodeUser?.watchedPercent ?? 0.0;

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: () => _playEpisode(ep, episodes),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  // Thumbnail Stack with Progress Bar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 110,
                          height: 70,
                          child: epThumb.isNotEmpty
                              ? Image.network(
                                  epThumb,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('images/default_portrate_large.jpg', fit: BoxFit.cover),
                                )
                              : Image.asset('images/default_portrate_large.jpg', fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                      ),
                      // Progress Bar
                      if (watchedPercent > 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            value: (watchedPercent / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                            minHeight: 3,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (ep.durationText.isNotEmpty || ep.duration.isNotEmpty)
                          Text(
                            ep.durationText.isNotEmpty ? ep.durationText : "${ep.duration} min",
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        if (ep.contentPlain.isNotEmpty || ep.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _stripHtml(ep.contentPlain.isNotEmpty ? ep.contentPlain : ep.content),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
        );
      },
    );
  }

  Widget _buildCastInlineSection() {
    final validCasts = _webseriesDetail?.casts
            .where((cast) => cast.name.trim().isNotEmpty)
            .toList() ??
        [];

    if (validCasts.isEmpty) return const SizedBox.shrink();

    // Group casts by role/groupName
    final Map<String, List<String>> grouped = {};
    for (var cast in validCasts) {
      String group = cast.groupName.trim();
      if (group.isEmpty) {
        group = 'Cast';
      }
      grouped.putIfAbsent(group, () => []).add(cast.name.trim());
    }

    final previewList = validCasts.take(3).map((c) => c.name).toList();
    final previewText = previewList.join(', ');
    final bool hasMore = validCasts.length > 3 || grouped.length > 1;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 250),
        crossFadeState: _isCastExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: GestureDetector(
          onTap: () {
            setState(() {
              _isCastExpanded = true;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Cast: ",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: previewText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      if (hasMore)
                        const TextSpan(
                          text: " ...more",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        secondChild: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cast & Crew",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCastExpanded = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: const Row(
                        children: [
                          Text(
                            "less",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_up, color: Colors.redAccent, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...grouped.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.value.map((name) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
