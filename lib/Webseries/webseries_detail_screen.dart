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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final pref = await SharedPreferences.getInstance();
    _token = pref.getString(AppPreferences.token) ?? '';
    _profileId = pref.getString(AppPreferences.profileID) ?? '';

    await _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
    });

    final watchDetail = await _apiService.getWebseriesWatchDetail(
      token: _token,
      webseriesId: widget.webseriesId,
      profileId: _profileId,
    );

    WebseriesItemModel? fullDetail;
    if (watchDetail != null) {
      fullDetail = await _apiService.getWebseriesDetail(
        token: _token,
        webseriesId: widget.webseriesId,
        profileId: _profileId,
      );
    }

    if (mounted) {
      setState(() {
        _webseriesDetail = watchDetail ?? widget.initialItem ?? fullDetail;
        if (fullDetail != null && _webseriesDetail != null) {
          // Merge casts if available
          if (fullDetail.casts.isNotEmpty) {
            _webseriesDetail = WebseriesItemModel(
              id: _webseriesDetail!.id,
              title: _webseriesDetail!.title,
              content: _webseriesDetail!.content.isNotEmpty
                  ? _webseriesDetail!.content
                  : fullDetail.content,
              publishedDate: _webseriesDetail!.publishedDate,
              certificate: _webseriesDetail!.certificate,
              tagText: _webseriesDetail!.tagText,
              thumbnail: _webseriesDetail!.thumbnail,
              image: _webseriesDetail!.image,
              medium: _webseriesDetail!.medium,
              portrait: _webseriesDetail!.portrait,
              portraitsmall: _webseriesDetail!.portraitsmall,
              movieAccess: _webseriesDetail!.movieAccess,
              trailer: _webseriesDetail!.trailer,
              topten: _webseriesDetail!.topten,
              resumeEpisodeId: _webseriesDetail!.resumeEpisodeId,
              resumeDate: _webseriesDetail!.resumeDate,
              firstEpisodeId: _webseriesDetail!.firstEpisodeId,
              seasons: _webseriesDetail!.seasons,
              casts: fullDetail.casts,
            );
          }
        }
        _isLoading = false;
      });
    }
  }

  String _buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppConfig.BaseUrl}/$path';
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
                      if (_webseriesDetail!.casts.isNotEmpty) _buildCastSection(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderBanner() {
    String bgUrl = _buildImageUrl(
        _webseriesDetail!.image.isNotEmpty ? _webseriesDetail!.image : _webseriesDetail!.thumbnail);

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

  Widget _buildCastSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cast & Crew",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _webseriesDetail!.casts.map((cast) {
              return Chip(
                backgroundColor: Colors.white10,
                label: Text(
                  "${cast.name}${cast.groupName.isNotEmpty ? ' (${cast.groupName})' : ''}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
