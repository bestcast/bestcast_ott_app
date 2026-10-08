import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/Dashboard/Models/Movie.dart';
import 'package:bestcaststudios/Webseries/Models/webseries_models.dart';
import 'package:bestcaststudios/Webseries/webseries_detail_screen.dart';
import 'package:bestcaststudios/app_config/app_preferences.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/api_services.dart';
import 'package:bestcaststudios/common_files/app_default_colors.dart';
import 'package:bestcaststudios/streamingpalyer/video_player.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  List<Movies> _allMovies = [];
  List<Movies> _searchResults = [];
  List<Movies> _popularMovies = [];

  bool _isSearching = false;
  bool _isSearchLoading = false;
  bool _isLoadingCatalog = false;

  String _token = "";
  String _profileId = "";
  String _selectedGenreFilter = "All";

  List<String> _quickFilters = [
    "All",
    "Action",
    "Comedy",
    "Drama",
    "Thriller",
    "Crime",
    "Family",
    "Romance",
    "Tamil",
    "Webseries",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialValue() async {
    final pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';
      _profileId = pref.getString(AppPreferences.profileID) ?? '';
    });

    _fetchCatalogAndPopular();
    _fetchGenres();
  }

  void _fetchGenres() async {
    final String genresApi = _token.isNotEmpty ? AppConfig.genrelistUser : AppConfig.genrelist;
    try {
      final response = await ApiServices().getRequestData(genresApi, _token);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body.toString());
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final List<String> fetchedGenres = ["All"];
          for (var item in jsonResponse['data']) {
            final String title = item['title']?.toString().trim() ?? "";
            if (title.isNotEmpty && !fetchedGenres.contains(title)) {
              fetchedGenres.add(title);
            }
          }
          if (mounted && fetchedGenres.length > 1) {
            setState(() {
              _quickFilters = fetchedGenres;
            });
          }
        }
      }
    } catch (_) {}
  }

  void _fetchCatalogAndPopular() async {
    setState(() {
      _isLoadingCatalog = true;
    });

    final String blocksApi = _token.isNotEmpty
        ? AppConfig.movieblockslistUser
        : AppConfig.movieblockslist;

    try {
      // Query page 1 of blocks
      final response = await ApiServices().getRequestData("${blocksApi}1&page=1", _token);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Movies> catalog = [];

        if (responseData["data"] != null && responseData["data"] is List) {
          for (var item in responseData["data"]) {
            if (item["movies"] != null && item["movies"] is List) {
              for (var movieData in item["movies"]) {
                _parseAndAddMovie(movieData, catalog);
              }
            } else {
              _parseAndAddMovie(item, catalog);
            }
          }
        }

        // Also fetch popular blocks
        try {
          final popularResponse = await ApiServices().getRequestData("${blocksApi}4&page=1", _token);
          if (popularResponse.statusCode == 200) {
            final popularData = json.decode(popularResponse.body);
            if (popularData["data"] != null && popularData["data"] is List) {
              for (var item in popularData["data"]) {
                if (item["movies"] != null && item["movies"] is List) {
                  for (var movieData in item["movies"]) {
                    _parseAndAddMovie(movieData, catalog);
                  }
                } else {
                  _parseAndAddMovie(item, catalog);
                }
              }
            }
          }
        } catch (_) {}

        setState(() {
          _allMovies = catalog;
          _popularMovies = List.from(catalog);
          _isLoadingCatalog = false;
        });

        // If a filter was already active, refresh results
        if (_selectedGenreFilter != "All" || _searchController.text.isNotEmpty) {
          _filterContent();
        }
      } else {
        setState(() {
          _isLoadingCatalog = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCatalog = false;
        });
      }
    }
  }

  void _parseAndAddMovie(dynamic movieData, List<Movies> list) {
    if (movieData == null) return;
    final String id = movieData["id"]?.toString() ?? "";
    if (id.isEmpty || list.any((m) => m.id == id)) return;

    final String thumbnail = movieData["thumbnail"]?.toString() ?? "";
    final String portraitsmall = movieData["portraitsmall"]?.toString() ?? "";
    final String portrait = movieData["portrait"]?.toString() ?? "";

    final String imgFallback = portraitsmall.isNotEmpty
        ? portraitsmall
        : (portrait.isNotEmpty ? portrait : thumbnail);
    final String imgFallbackUrl = imgFallback.isNotEmpty
        ? (imgFallback.startsWith("http") ? imgFallback : "${AppConfig.BaseUrl}/$imgFallback")
        : "";

    final String thumbnailUrl = thumbnail.isNotEmpty
        ? (thumbnail.startsWith("http") ? thumbnail : "${AppConfig.BaseUrl}/$thumbnail")
        : imgFallbackUrl;
    final String portraitsmallUrl = portraitsmall.isNotEmpty
        ? (portraitsmall.startsWith("http") ? portraitsmall : "${AppConfig.BaseUrl}/$portraitsmall")
        : imgFallbackUrl;
    final String portraitUrl = portrait.isNotEmpty
        ? (portrait.startsWith("http") ? portrait : "${AppConfig.BaseUrl}/$portrait")
        : imgFallbackUrl;

    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    final String rawTag = movieData["tag_text"]?.toString() ?? "";
    final String resultTagText = rawTag.replaceAll(exp, '  ').trim();

    list.add(Movies(
      id: id,
      title: movieData["title"]?.toString() ?? "",
      movie_access: movieData["movie_access"]?.toString() ?? "",
      topten: movieData["topten"]?.toString() ?? "",
      trailer: movieData["trailer"]?.toString() ?? "",
      certificate: movieData["certificate"]?.toString() ?? "",
      duration: movieData["duration"]?.toString() ?? "",
      tagText: resultTagText,
      publishedDate: movieData["published_date"]?.toString() ?? "",
      userlist: movieData["userlist"]?.toString() ?? "",
      userlike: movieData["userlike"]?.toString() ?? "",
      thumbnail: thumbnailUrl,
      portraitsmall: portraitsmallUrl,
      portrait: portraitUrl,
      usermovies: null,
    ));
  }

  bool _matchesGenre(Movies movie, String genre) {
    if (genre == "All" || genre.isEmpty) return true;
    final String g = genre.toLowerCase();
    final String tags = (movie.tagText ?? '').toLowerCase();
    final String title = (movie.title ?? '').toLowerCase();

    // Exact or substring match in tags or title
    if (tags.contains(g) || title.contains(g)) return true;

    // Stem matching for common genre variations
    if (g.startsWith("roman") && tags.contains("roman")) return true;
    if (g.startsWith("drama") && tags.contains("drama")) return true;
    if (g.startsWith("comed") && tags.contains("comed")) return true;
    if (g.startsWith("action") && tags.contains("action")) return true;
    if (g.startsWith("thrill") && tags.contains("thrill")) return true;
    if (g.startsWith("suspens") && (tags.contains("suspens") || tags.contains("thrill"))) return true;
    if (g.startsWith("horror") && tags.contains("horror")) return true;
    if (g.startsWith("crime") && tags.contains("crime")) return true;
    if (g.startsWith("famil") && tags.contains("famil")) return true;
    if (g.startsWith("webseries") && (tags.contains("webseries") || title.contains("webseries"))) return true;

    return false;
  }

  void _filterContent() {
    final String query = _searchController.text.trim().toLowerCase();
    final bool isFilterActive = _selectedGenreFilter != "All";

    if (query.isEmpty && !isFilterActive) {
      setState(() {
        _isSearching = false;
        _isSearchLoading = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allMovies.where((movie) {
        final String title = (movie.title ?? '').toLowerCase();
        final String tags = (movie.tagText ?? '').toLowerCase();

        final bool matchesGenre = _matchesGenre(movie, _selectedGenreFilter);
        final bool matchesQuery = query.isEmpty || title.contains(query) || tags.contains(query);

        return matchesGenre && matchesQuery;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _filterContent();

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      setState(() {
        _isSearchLoading = true;
      });
      _debounceTimer = Timer(const Duration(milliseconds: 380), () {
        _performRemoteSearch(trimmed);
      });
    } else {
      setState(() {
        _isSearchLoading = false;
      });
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedGenreFilter = filter;
    });
    _filterContent();
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    setState(() {
      _isSearchLoading = false;
    });
    _filterContent();
    _searchFocusNode.unfocus();
  }

  void _performRemoteSearch(String searchText) async {
    final String searchApi = _token.isNotEmpty
        ? AppConfig.searchMovieslistUser
        : AppConfig.searchMovieslist;

    try {
      final response = await ApiServices().getRequestData(
        "$searchApi$searchText&profile_id=$_profileId",
        _token,
      );

      if (!mounted) return;

      // Discard stale out-of-order response if search query changed or was cleared
      if (_searchController.text.trim().toLowerCase() != searchText.toLowerCase()) {
        return;
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData["data"] != null && responseData["data"] is List) {
          for (var movieData in responseData["data"]) {
            _parseAndAddMovie(movieData, _allMovies);
          }
        }

        // Re-filter with freshly merged catalog
        _filterContent();
      }

      if (mounted) {
        setState(() {
          _isSearchLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearchLoading = false;
        });
      }
    }
  }

  void _navigateToMovie(Movies movie) {
    final bool isWebseries = movie.isWebseries == true ||
        (movie.title ?? '').toLowerCase().contains('webseries') ||
        (movie.tagText ?? '').toLowerCase().contains('webseries');

    if (isWebseries) {
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

  String _getPosterImage(Movies movie) {
    if (movie.portraitsmall != null && movie.portraitsmall!.isNotEmpty) {
      return movie.portraitsmall!;
    }
    if (movie.portrait != null && movie.portrait!.isNotEmpty) {
      return movie.portrait!;
    }
    if (movie.thumbnail != null && movie.thumbnail!.isNotEmpty) {
      return movie.thumbnail!;
    }
    return '';
  }

  String _getLandscapeImage(Movies movie) {
    if (movie.thumbnail != null && movie.thumbnail!.isNotEmpty) {
      return movie.thumbnail!;
    }
    if (movie.portraitsmall != null && movie.portraitsmall!.isNotEmpty) {
      return movie.portraitsmall!;
    }
    if (movie.portrait != null && movie.portrait!.isNotEmpty) {
      return movie.portrait!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: AppDefaultColors.appColor,
        elevation: 0,
        title: const Text(
          "Search",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _searchFocusNode.hasFocus
                        ? AppDefaultColors.primaryRed.withValues(alpha: 0.6)
                        : Colors.white12,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Icon(Icons.search_rounded, color: Colors.white60, size: 22),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 15.0),
                        cursorColor: AppDefaultColors.primaryRed,
                        decoration: const InputDecoration(
                          hintText: "Search movies, genres, webseries...",
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14.5),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (_isSearchLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppDefaultColors.primaryRed),
                        ),
                      )
                    else if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: Colors.white54, size: 20),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),

            // Quick Category / Genre Filter Chips
            SizedBox(
              height: 42,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _quickFilters.length,
                itemBuilder: (context, index) {
                  final filter = _quickFilters[index];
                  final bool isSelected = _selectedGenreFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppDefaultColors.primaryRed,
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppDefaultColors.primaryRed : Colors.white12,
                          width: 0.8,
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (_) => _onFilterSelected(filter),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Main Body: Search/Genre Results OR Popular Searches
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildPopularSearches(),
            ),
          ],
        ),
      ),
    );
  }

  // Active Search & Genre Results Grid
  Widget _buildSearchResults() {
    if (_isSearchLoading && _searchResults.isEmpty && _allMovies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppDefaultColors.primaryRed, strokeWidth: 3),
      );
    }

    if (_searchResults.isEmpty) {
      final String filterText = _searchController.text.trim().isNotEmpty
          ? _searchController.text.trim()
          : _selectedGenreFilter;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 68, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                "No results for '$filterText'",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Try selecting another genre or searching for another title.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _onFilterSelected("All");
                  _clearSearch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDefaultColors.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("View All Titles"),
              ),
            ],
          ),
        ),
      );
    }

    final String headerTitle = _selectedGenreFilter != "All"
        ? "$_selectedGenreFilter (${_searchResults.length})"
        : "Results (${_searchResults.length})";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            headerTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 4, bottom: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _searchResults.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final movie = _searchResults[index];
              final String poster = _getPosterImage(movie);

              return GestureDetector(
                onTap: () => _navigateToMovie(movie),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
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
                              poster.isNotEmpty
                                  ? Image.network(
                                      poster,
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
                    const SizedBox(height: 5),
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
        ),
      ],
    );
  }

  // Idle State: Popular Movies List
  Widget _buildPopularSearches() {
    if (_isLoadingCatalog && _popularMovies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppDefaultColors.primaryRed, strokeWidth: 3),
      );
    }

    if (_popularMovies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.movie_outlined, size: 64, color: Colors.white24),
              SizedBox(height: 14),
              Text(
                "Search for your favorite movies and webseries",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14.5),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _popularMovies.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.white10,
              height: 16,
              indent: 140,
            ),
            itemBuilder: (context, index) {
              final movie = _popularMovies[index];
              final String landscapeUrl = _getLandscapeImage(movie);

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _navigateToMovie(movie),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                  child: Row(
                    children: [
                      // Landscape Thumbnail
                      Container(
                        width: 124,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.2),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              landscapeUrl.isNotEmpty
                                  ? Image.network(
                                      landscapeUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                        'images/default_landscape.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'images/default_landscape.jpg',
                                      fit: BoxFit.cover,
                                    ),
                              if (movie.movie_access == "1")
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: SizedBox(
                                    height: 20,
                                    child: const Image(image: AssetImage("images/free_tag_img.png")),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Movie Title & Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (movie.tagText != null && movie.tagText!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                movie.tagText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Play Action Icon
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF222222),
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
