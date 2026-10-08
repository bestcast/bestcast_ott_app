import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bestcaststudios/Dashboard/Models/Movie.dart';
import 'package:bestcaststudios/Webseries/Models/webseries_models.dart';
import 'package:bestcaststudios/Webseries/webseries_detail_screen.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:bestcaststudios/streamingpalyer/video_player.dart';

class BlockMoviesScreen extends StatefulWidget {
  final String blockTitle;
  final String blockId;
  final List<Movies> movies;
  final bool isWebseries;

  const BlockMoviesScreen({
    super.key,
    required this.blockTitle,
    required this.blockId,
    required this.movies,
    this.isWebseries = false,
  });

  @override
  State<BlockMoviesScreen> createState() => _BlockMoviesScreenState();
}

class _BlockMoviesScreenState extends State<BlockMoviesScreen> {
  late List<Movies> _displayMovies;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _displayMovies = List.from(widget.movies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _displayMovies = List.from(widget.movies);
      } else {
        final q = query.toLowerCase();
        _displayMovies = widget.movies.where((m) {
          final title = (m.title ?? '').toLowerCase();
          final tag = (m.tagText ?? '').toLowerCase();
          return title.contains(q) || tag.contains(q);
        }).toList();
      }
    });
  }

  void _navigateToContent(Movies movie) {
    if (widget.isWebseries) {
      WebseriesItemModel item = movie.webseriesItem ??
          WebseriesItemModel(
            id: movie.id.toString(),
            title: movie.title ?? '',
            content: movie.content ?? '',
            trailer: movie.trailer ?? '',
            certificate: movie.certificate ?? '',
            publishedDate: movie.publishedDate ?? '',
            duration: movie.duration ?? '',
            thumbnail: movie.thumbnail ?? '',
            image: (movie.thumbnail != null && movie.thumbnail!.isNotEmpty)
                ? movie.thumbnail!
                : (movie.portrait ?? ''),
            portrait: movie.portrait ?? '',
            portraitsmall: movie.portraitsmall ?? '',
            movieAccess: int.tryParse(movie.movie_access ?? '0') ?? 0,
            seasons: movie.seasons ?? [],
          );
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => WebseriesDetailScreen(
            webseriesId: movie.id.toString(),
            initialItem: item,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => VideoApp(getMovieID: movie.id.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: AppDefaultColors.primaryRed,
                decoration: const InputDecoration(
                  hintText: 'Search in this block...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 15),
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.blockTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    "${widget.movies.length} ${widget.isWebseries ? 'Series' : 'Movies'}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white70,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _displayMovies = List.from(widget.movies);
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _displayMovies.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isWebseries ? Icons.tv_off_rounded : Icons.movie_outlined,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSearching ? "No matching titles found" : "No titles available",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_isSearching) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _displayMovies = List.from(widget.movies);
                          });
                        },
                        child: const Text("Clear Search", style: TextStyle(color: AppDefaultColors.primaryRed)),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _displayMovies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.58,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final movie = _displayMovies[index];
                final String imageUrl = (movie.portraitsmall != null && movie.portraitsmall!.isNotEmpty)
                    ? movie.portraitsmall!
                    : ((movie.portrait != null && movie.portrait!.isNotEmpty)
                        ? movie.portrait!
                        : (movie.thumbnail ?? ''));

                final String fullImageUrl = imageUrl.isNotEmpty
                    ? (imageUrl.startsWith('http') ? imageUrl : "${AppConfig.BaseUrl}/$imageUrl")
                    : '';

                return GestureDetector(
                  onTap: () => _navigateToContent(movie),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7.2),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                fullImageUrl.isNotEmpty
                                    ? Image.network(
                                        fullImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Image.asset(
                                          'images/default_portrate_small.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            color: AppDefaultColors.hardDarkGray,
                                            child: const Center(
                                              child: SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white24,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'images/default_portrate_small.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                if (movie.movie_access == "1")
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: SizedBox(
                                      height: 22,
                                      child: const Image(image: AssetImage("images/free_tag_img.png")),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          movie.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
