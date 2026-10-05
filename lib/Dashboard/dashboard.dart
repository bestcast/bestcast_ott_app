import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/Dashboard/Models/Genres.dart';
import 'package:bestcaststudios/Dashboard/Models/Movie.dart';
import 'package:bestcaststudios/Dashboard/Models/MoviesMainCategoryModel.dart';
import 'package:bestcaststudios/Dashboard/Models/Usermovies.dart';
import 'package:bestcaststudios/Dashboard/MovieCategories.dart';
import 'package:bestcaststudios/Dashboard/MoviesModels.dart';
import 'package:bestcaststudios/common_files/main_card_background.dart';
import 'package:bestcaststudios/common_files/movie_categories_card_wishlist.dart';
import 'package:bestcaststudios/common_files/round_border_background.dart';
import 'package:bestcaststudios/common_files/submit_transparent_button.dart';
import 'package:bestcaststudios/streamingpalyer/video_player.dart';
import 'package:bestcaststudios/streamingpalyer/models/subtitle_models.dart';
import '../app_config/app_preferences.dart';
import '../Webseries/Models/webseries_models.dart';
import '../Webseries/webseries_api_service.dart';
import '../Webseries/webseries_detail_screen.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/login_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../common_files/main_card_transparent_background.dart';
import '../common_files/movie_categories_card_background.dart';
import '../common_files/round_border_background_wiht_icon.dart';
import '../common_files/submit_white_button.dart';
import '../streamingpalyer/models/main_movie_details_models.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;
  bool loggedStatus = false;

  String _mainMovieId = "";
  String _mainMoviePicture = "";
  String _mainMovieCategory = "";

  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  late MovieData? movieData;
  bool scrolleEnabled = false;
  bool hasMoreScroll = true;
  var _page = 1;

  String _selectedCategoryId = "";
  String _selectedCategoryTitle = "";

  List<MoviesCategoryModel> moviesCategoryModel = [];
  List<MoviesMainCategoryModel> moviesMainCategoryModelList = [];
  List<WebseriesBlockModel> webseriesBlockModelList = [];

  List<dynamic> moviesMainCategoryModel1List = [];

  var scrollController = ScrollController();
  bool _isAppBarVisible = true;
  double _appBarOpacity = 1.0;
  final Duration _duration = Duration(milliseconds: 500);

  bool _isAddedMyList = false;

  List<Genres> allCategoryItems = [];

  void getMoviesListsTemp() {
    for (int i = 0; i < 5; i++) {
      List<MoviesModel> moviesModel = [];
      var j = 0;
      var catID = i + 1;
      for (int K = 0; K < 11; K++) {
        if (K == 6) {
          j = 0;
        }

        if (i == 0) {
          moviesModel.add(MoviesModel(catogoryID: catID.toString(), movieID: "1", descriptions: "Action"));
        } else {
          moviesModel.add(MoviesModel(catogoryID: catID.toString(), movieID: "1", descriptions: "Action"));
        }

        if (j < 6) {
          j++;
        }
      }
      moviesCategoryModel.add(MoviesCategoryModel(catogoryID: catID.toString(), moviesModel: moviesModel));
    }
  }

  @override
  void initState() {
    getInitalValue();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    scrollController.addListener(() async {
      if (scrollController.hasClients &&
          scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (hasMoreScroll && !isLoading && !scrolleEnabled) {
          if (await CommonWidget().isInternetConnectivity()) {
            scrolleEnabled = true;
            getBlockMoviesLits(_token, profileID, _selectedCategoryId, _page);
          }
        }
      }

      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isAppBarVisible) {
          setState(() {
            _isAppBarVisible = false;
            _appBarOpacity = 0.0;
          });
        }
      } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isAppBarVisible) {
          setState(() {
            _isAppBarVisible = true;
            _appBarOpacity = 1.0;
          });
        }
      }
    });
    super.initState();
  }

  void _selectAllMovies() async {
    if (_selectedCategoryId.isEmpty && moviesMainCategoryModelList.isNotEmpty) {
      if (scrollController.hasClients) {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
      return;
    }
    if (await CommonWidget().isInternetConnectivity()) {
      setState(() {
        _selectedCategoryId = "";
        _selectedCategoryTitle = "";
        _page = 1;
        hasMoreScroll = true;
        scrolleEnabled = false;
        isLoading = true;
      });
      getBannerMoviesDetails(_token, profileID, "", "1");
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    } else {
      CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
    }
  }

  void _selectCategory(String catId, String catTitle) async {
    if (await CommonWidget().isInternetConnectivity()) {
      setState(() {
        _selectedCategoryId = catId;
        _selectedCategoryTitle = catTitle;
        _page = 1;
        hasMoreScroll = true;
        scrolleEnabled = false;
        isLoading = true;
      });
      getBannerMoviesDetails(_token, profileID, catId, "2");
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    } else {
      CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
    }
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';
      loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';
    });

    print("_tokenVerify$_token");
    print("DashboardProfileID$profileID");

    getBannerMoviesDetails(_token, profileID, "", "1");
    getUserDetails(_token);
    getWebseriesBlocks();
  }

  void getWebseriesBlocks() async {
    final blocks = await WebseriesApiService().getWebseriesBlocksList(
      token: _token,
      profileId: profileID,
    );
    if (mounted) {
      setState(() {
        webseriesBlockModelList = blocks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );

    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        child: Stack(children: <Widget>[
          isLoading == false
              ? SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    margin: const EdgeInsets.only(top: 160, left: 15, right: 15, bottom: 10),
                    child: Column(
                      children: [
                        MainCardBackgroundView(
                          Container(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height - 320,
                              child: Stack(
                                children: <Widget>[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    width: double.infinity,
                                    child: _mainMoviePicture.isNotEmpty &&
                                            (_mainMoviePicture.startsWith("http://") ||
                                                _mainMoviePicture.startsWith("https://"))
                                        ? Image.network(
                                            _mainMoviePicture,
                                            height: MediaQuery.of(context).size.height,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Image.asset(
                                              'images/default_portrate_large.jpg',
                                              height: MediaQuery.of(context).size.height,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            'images/default_portrate_large.jpg',
                                            height: MediaQuery.of(context).size.height,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: MainTransaparentCardBackgroundView(
                                      Container(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.height,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: MediaQuery.of(context).size.height,
                                      padding: const EdgeInsets.only(bottom: 15),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 20.0),
                                            child: Text(
                                              _mainMovieCategory,
                                              style: const TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.normal),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, right: 10, left: 10),
                                                  child: Container(
                                                    padding: const EdgeInsets.only(right: 5.0),
                                                    child: SubmitWhiteButton(
                                                      "Play",
                                                      Icons.play_arrow,
                                                      onTap: () async {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoApp(getMovieID: _mainMovieId)));
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                  child: Container(
                                                    padding: const EdgeInsets.only(right: 5.0),
                                                    child: SubmitTransparentButton(
                                                      "My List",
                                                      _isAddedMyList ? Icons.check : Icons.add,
                                                      onTap: () async {
                                                        if (loggedStatus) {
                                                          setState(() {
                                                            var isMyList = 0;
                                                            if (_isAddedMyList) {
                                                              _isAddedMyList = false;
                                                              isMyList = 0;
                                                            } else {
                                                              _isAddedMyList = true;
                                                              isMyList = 1;
                                                            }

                                                            final postValues = {
                                                              'mylist': isMyList,
                                                            };
                                                            setUserMovies(_token, profileID, _mainMovieId, postValues);
                                                          });
                                                        } else {
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
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
                        ),
                        if (moviesMainCategoryModelList.isEmpty && !isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                            child: Column(
                              children: [
                                const Icon(Icons.movie_outlined, color: Colors.white38, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedCategoryTitle.isNotEmpty
                                      ? "No movies found in $_selectedCategoryTitle"
                                      : "No movies found",
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                                if (_selectedCategoryId.isNotEmpty)
                                  ElevatedButton(
                                    onPressed: _selectAllMovies,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("View All Movies"),
                                  ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: moviesMainCategoryModelList.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index < moviesMainCategoryModelList.length) {
                                  if (moviesMainCategoryModelList[index].movies == null ||
                                      moviesMainCategoryModelList[index].movies!.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  final bool isWebseries = moviesMainCategoryModelList[index]
                                      .title
                                      .toString()
                                      .toLowerCase()
                                      .contains("webseries");
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0, top: 12.0, bottom: 8.0),
                                        child: Text(
                                          moviesMainCategoryModelList[index].title.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 205,
                                        child: ListView.builder(
                                          physics: const BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: moviesMainCategoryModelList[index].movies?.length ?? 0,
                                          itemBuilder: (BuildContext context, int index2) {
                                            return getMovieCategoryWidget(
                                              moviesMainCategoryModelList[index].movies![index2],
                                              isWebseries: isWebseries,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return hasMoreScroll
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20.0),
                                          child: Center(
                                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.red),
                                          ),
                                        )
                                      : const SizedBox(height: 20);
                                }
                              }),
                      ],
                    ),
                  ),
                )
              : LoadingWidget(),

          // TOP bar
          AnimatedOpacity(
            duration: _duration,
            opacity: _appBarOpacity,
            child: _isAppBarVisible
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          width: 120,
                                          'images/logo_bestcast.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: false,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                    },
                                    child: const Text("LOGIN", style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // TOP bar Filters (All Movies & Categories)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _selectAllMovies,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                foregroundColor: _selectedCategoryId.isEmpty ? Colors.black : Colors.white,
                                backgroundColor: _selectedCategoryId.isEmpty ? Colors.white : Colors.transparent,
                                elevation: _selectedCategoryId.isEmpty ? 2 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide(
                                    color: _selectedCategoryId.isEmpty ? Colors.white : Colors.white54,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                "All Movies",
                                style: TextStyle(
                                  color: _selectedCategoryId.isEmpty ? Colors.black : Colors.white,
                                  fontSize: 14,
                                  fontWeight: _selectedCategoryId.isEmpty ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: getBottomWidget,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _selectedCategoryId.isNotEmpty ? Colors.black : Colors.white,
                                size: 20.0,
                              ),
                              label: Text(
                                _selectedCategoryTitle.isNotEmpty ? _selectedCategoryTitle : "Categories",
                                style: TextStyle(
                                  color: _selectedCategoryId.isNotEmpty ? Colors.black : Colors.white,
                                  fontSize: 14,
                                  fontWeight: _selectedCategoryId.isNotEmpty ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                foregroundColor: _selectedCategoryId.isNotEmpty ? Colors.black : Colors.white,
                                backgroundColor: _selectedCategoryId.isNotEmpty ? Colors.white : Colors.transparent,
                                elevation: _selectedCategoryId.isNotEmpty ? 2 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide(
                                    color: _selectedCategoryId.isNotEmpty ? Colors.white : Colors.white54,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }

  Widget getWebseriesCategoryWidget(WebseriesItemModel item) {
    String thumb = item.thumbnail.isNotEmpty ? item.thumbnail : item.image;
    if (thumb.isNotEmpty && !thumb.startsWith('http://') && !thumb.startsWith('https://')) {
      thumb = '${AppConfig.BaseUrl}/$thumb';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebseriesDetailScreen(
              webseriesId: item.id,
              initialItem: item,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 160,
                width: 120,
                child: thumb.isNotEmpty
                    ? Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset('images/default_portrate_large.jpg', fit: BoxFit.cover),
                      )
                    : Image.asset('images/default_portrate_large.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget getMovieCategoryWidget(Movies moviesModel, {bool isWebseries = false}) {
    String pSmall = moviesModel.portraitsmall ?? '';
    String pPort = moviesModel.portrait ?? '';
    String pThumb = moviesModel.thumbnail ?? '';

    String imageUrl = pSmall.isNotEmpty
        ? pSmall
        : (pPort.isNotEmpty ? pPort : pThumb);

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      imageUrl = imageUrl.startsWith('/') ? '${AppConfig.BaseUrl}$imageUrl' : '${AppConfig.BaseUrl}/$imageUrl';
    }

    return Container(
      width: 124,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (isWebseries) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebseriesDetailScreen(
                    webseriesId: moviesModel.id.toString(),
                    initialItem: WebseriesItemModel(
                      id: moviesModel.id.toString(),
                      title: moviesModel.title ?? '',
                      thumbnail: moviesModel.thumbnail ?? '',
                      image: (moviesModel.thumbnail != null && moviesModel.thumbnail!.isNotEmpty)
                          ? moviesModel.thumbnail!
                          : (moviesModel.portrait ?? ''),
                      portrait: moviesModel.portrait ?? '',
                      portraitsmall: moviesModel.portraitsmall ?? '',
                      seasons: [],
                    ),
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => VideoApp(getMovieID: moviesModel.id.toString()),
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 165,
                width: 124,
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
                      imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))
                          ? Image.network(
                              imageUrl,
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
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              'images/default_portrate_small.jpg',
                              fit: BoxFit.cover,
                            ),
                      if (moviesModel.movie_access == "1")
                        Positioned(
                          top: 4,
                          right: 4,
                          child: SizedBox(
                            height: 24,
                            child: const Image(image: AssetImage("images/free_tag_img.png")),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  moviesModel.title.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMovieWishListCategoryWidget(MoviesModel moviesModel) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              child: Stack(children: <Widget>[
            MovieCardWishListBackgroundView(
              Container(
                child: SizedBox(
                  height: 130,
                  width: 230,
                  child: Image.asset(
                    width: double.infinity,
                    height: double.infinity,
                    moviesModel.thumbnailPicture.toString(),
                    // 'images/sample_home_screen.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              child: SizedBox(
                width: 234,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                    child: LinearProgressIndicator(
                      value: double.parse(moviesModel.lastPlayedTime.toString()),
                      color: AppDefaultColors.thikRed,
                      backgroundColor: AppDefaultColors.textLightGray,
                    ),
                  ),
                ),
              ),
            ),
          ])),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: Text(
              moviesModel.title.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void getBottomWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Categories",
                      style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, thickness: 1),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.65),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCategoryItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final bool isSelected = _selectedCategoryId.isEmpty;
                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.redAccent : Colors.white38,
                          size: 22,
                        ),
                        title: Text(
                          "All Movies",
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppDefaultColors.textLightGray,
                            fontSize: 16.0,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _selectAllMovies();
                        },
                      );
                    }
                    final category = allCategoryItems[index - 1];
                    final bool isSelected = _selectedCategoryId == category.id.toString();
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.redAccent : Colors.white38,
                        size: 22,
                      ),
                      title: Text(
                        category.title.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppDefaultColors.textLightGray,
                          fontSize: 16.0,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _selectCategory(category.id.toString(), category.title.toString());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void getBlockMoviesLits(String token, String profileId, String categoryId, int pageId) async {
    if (!scrolleEnabled) {
      isLoading = true;
      moviesMainCategoryModelList.clear();
    }

    String blocksApi = (loggedStatus && token.isNotEmpty) ? AppConfig.movieblockslistUser : AppConfig.movieblockslist;

    ApiServices().getRequestData("${blocksApi}1&page=$pageId&profile_id=$profileId&genre_id=$categoryId", token).then((response) async {
      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);

          for (var mainData in responseData["data"]) {
            List<Movies> userMainCategoryModelList = [];
            if (mainData["movies"] != null && mainData["movies"] is List) {
              for (var movieData in mainData["movies"]) {
                Usermovies? usermovies;

                if (movieData['usermovies'] != null && movieData['usermovies'] is Map && (movieData['usermovies'] as Map).isNotEmpty) {
                  var um = movieData['usermovies'];
                  usermovies = Usermovies(
                    id: um["id"]?.toString() ?? "",
                    movieId: (um["movie_id"] ?? um["movieId"])?.toString() ?? "",
                    mylist: um["mylist"]?.toString() ?? "",
                    likes: um["likes"]?.toString() ?? "",
                    watchTime: (um["watch_time"] ?? um["watchTime"])?.toString() ?? "",
                    watching: um["watching"]?.toString() ?? "",
                    watched: um["watched"]?.toString() ?? "",
                    watchedPercent: (um["watched_percent"] ?? um["watchedPercent"])?.toString() ?? "",
                    viewed: um["viewed"]?.toString() ?? "",
                  );
                }

                String movieAccess = movieData["movie_access"]?.toString() ?? "";

                String thumbnail = movieData["thumbnail"]?.toString() ?? "";
                String portraitsmall = movieData["portraitsmall"]?.toString() ?? "";
                String portrait = movieData["portrait"]?.toString() ?? "";

                String imgFallback = portraitsmall.isNotEmpty ? portraitsmall : (portrait.isNotEmpty ? portrait : thumbnail);
                String imgFallbackUrl = imgFallback.isNotEmpty ? (imgFallback.startsWith("http") ? imgFallback : "${AppConfig.BaseUrl}/$imgFallback") : "";

                String thumbnailUrl = thumbnail.isNotEmpty ? (thumbnail.startsWith("http") ? thumbnail : "${AppConfig.BaseUrl}/$thumbnail") : imgFallbackUrl;
                String portraitsmallUrl = portraitsmall.isNotEmpty ? (portraitsmall.startsWith("http") ? portraitsmall : "${AppConfig.BaseUrl}/$portraitsmall") : imgFallbackUrl;
                String portraitUrl = portrait.isNotEmpty ? (portrait.startsWith("http") ? portrait : "${AppConfig.BaseUrl}/$portrait") : imgFallbackUrl;

                userMainCategoryModelList.add(Movies(
                  id: movieData["id"]?.toString() ?? "",
                  title: movieData["title"]?.toString() ?? "",
                  movie_access: movieAccess,
                  topten: movieData["topten"]?.toString() ?? "",
                  trailer: movieData["trailer"]?.toString() ?? "",
                  certificate: movieData["certificate"]?.toString() ?? "",
                  duration: movieData["duration"]?.toString() ?? "",
                  tagText: movieData["tag_text"]?.toString() ?? "",
                  publishedDate: movieData["published_date"]?.toString() ?? "",
                  userlist: movieData["userlist"]?.toString() ?? "",
                  userlike: movieData["userlike"]?.toString() ?? "",
                  thumbnail: thumbnailUrl,
                  portraitsmall: portraitsmallUrl,
                  portrait: portraitUrl,
                  usermovies: usermovies,
                ));
              }
            }

            if (userMainCategoryModelList.isNotEmpty) {
              moviesMainCategoryModelList.add(MoviesMainCategoryModel(
                id: mainData["id"]?.toString() ?? "",
                title: mainData["title"]?.toString() ?? "",
                movies: userMainCategoryModelList,
              ));
            }
          }

          bool hasNextPage = false;
          if (responseData["links"] != null && responseData["links"]["next"] != null) {
            hasNextPage = true;
          } else if (responseData["meta"] != null) {
            int currentPage = int.tryParse(responseData["meta"]["current_page"]?.toString() ?? "") ?? 1;
            int lastPage = int.tryParse(responseData["meta"]["last_page"]?.toString() ?? "") ?? 1;
            hasNextPage = currentPage < lastPage;
          }

          setState(() {
            hasMoreScroll = hasNextPage;
            scrolleEnabled = false;
            isLoading = false;
          });

          if (_page == 1 && allCategoryItems.isEmpty) {
            getCastegoryDetails(token);
          }

          if (hasNextPage) {
            _page++;
          }
        } catch (e) {
          setState(() {
            isLoading = false;
            hasMoreScroll = false;
            scrolleEnabled = false;
          });
          print('DashboardMovieListException:$e');
        }
      } else {
        setState(() {
          isLoading = false;
          hasMoreScroll = false;
          scrolleEnabled = false;
        });
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void getBannerMoviesDetails(String token, String profileId, String categoryID, String pageId) async {
    setState(() {
      isLoading = true;
    });

    final String bannerApi = (loggedStatus && token.isNotEmpty) ? AppConfig.bannerlistUser : AppConfig.bannerlist;

    final bannerRequest = (loggedStatus && token.isNotEmpty)
        ? ApiServices().getRequestData("$bannerApi$pageId&genre_id=$categoryID", token)
        : ApiServices().getRequestWithoutToken("$bannerApi$pageId&genre_id=$categoryID");

    bannerRequest.then((response) async {
      String jsonsDataString = response.body.toString();
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          String id = data["movies"]["id"].toString();
          String urlkey = data["movies"]["urlkey"].toString();
          String title = data["movies"]["title"].toString();
          String movieAccess = data["movies"]["movie_access"].toString();
          String content = data["movies"]["content"].toString();
          String publishedDate = data["movies"]["published_date"].toString();
          String releaseDate = data["movies"]["release_date"].toString();

          String image = "${AppConfig.BaseUrl}/${data["movies"]["image"]}";
          String medium = "${AppConfig.BaseUrl}/${data["movies"]["medium"]}";
          String thumbnail = "${AppConfig.BaseUrl}/${data["movies"]["thumbnail"]}";
          String portraitsmall = "${AppConfig.BaseUrl}/${data["movies"]["portraitsmall"]}";
          String portrait = "${AppConfig.BaseUrl}/${data["movies"]["portrait"]}";

          String duration = data["movies"]["duration"].toString();
          String durationText = data["movies"]["duration_text"].toString();
          String certificate = data["movies"]["certificate"].toString();
          String certificateText = data["movies"]["certificate_text"].toString();
          String tagText = data["movies"]["tag_text"].toString();
          String topten = data["movies"]["topten"].toString();
          String trailer = data["movies"]["trailer"].toString();
          String trailer480p = data["movies"]["trailer_480p"].toString();
          String videoUrl = data["movies"]["video_url"].toString();
          String moviesource = data["movies"]["moviesource"].toString();
          String subtitleStatus = data["movies"]["subtitle_status"].toString();

          var jsonReponse1 = jsonEncode(data["movies"]['usermovies']);
          var jsonData = jsonDecode(jsonReponse1.toString());

          if (jsonData.isNotEmpty) {
            var myList = data["movies"]["usermovies"]["mylist"].toInt();
            _isAddedMyList = (myList != 0);
          }

          RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
          String resultTagText = tagText.replaceAll(exp, '  ');

          setState(() {
            _mainMoviePicture = portrait;
            _mainMovieId = id.toString();
            _mainMovieCategory = resultTagText;
          });

          List<SubTitleModel>? subtitleList;
          if (data["movies"]["subtitle"] != null && data["movies"]["subtitle"] is List) {
            subtitleList = List<SubTitleModel>.from(data["movies"]["subtitle"].map((x) => SubTitleModel.fromJson(x)));
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

          _page = 1;
          scrolleEnabled = false;
          getBlockMoviesLits(_token, profileID, categoryID, 1);
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('BannerException:$e');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches("LongPrint: $text").forEach((match) => print(match.group(0)));
  }

  void getCastegoryDetails(String token) async {
    allCategoryItems.clear();
    setState(() {
      isLoading = true;
    });
    final String genresApi = (loggedStatus && token.isNotEmpty) ? AppConfig.genrelistUser : AppConfig.genrelist;
    ApiServices().getRequestData(genresApi, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("gener_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);

          for (var data in jsonReponse['data']) {
            print("GeneriesId${data["id"]}");

            String bannerId = data["id"].toString();
            String bannerTitle = data["title"].toString();

            Genres genreslists = Genres(
              id: bannerId,
              title: bannerTitle,
            );

            allCategoryItems.add(genreslists);
          }

          setState(() {
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('GenrelistException:$e');
        }
      } else {
        print("Error: $response");
        setState(() {
          isLoading = false;
        });
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void setUserMovies(String token, String profileID, String movieID, Map<String, int> postValues) async {
    //   'mylist': _mylist,

    ApiServices().postRequestToken("${AppConfig.setUserMovie}$movieID?profile_id=$profileID", postValues, token).then((response) async {
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

  void getUserDetails(String token) async {
    ApiServices().postRequestTokenWithoutBody(AppConfig.getUserDetails, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("getUserDetails_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            String? planExpiry = jsonReponse['results']['user']['plan_expiry'].toString();
            String? planStatus = jsonReponse['results']['user']['plan_status'].toString();
            String? planDeviceStatus = jsonReponse['results']['user']['plan_device_status'].toString();

            final pref = await SharedPreferences.getInstance();
            await pref.setString(AppPreferences.plan_expiry, planExpiry);
            await pref.setString(AppPreferences.plan_device_status, planDeviceStatus);
            await pref.setString(AppPreferences.plan_status, planStatus);
          } else {
            if (status == "error") {
              getTokenValid(token);
            }
          }
        } catch (e) {
          print('getUserDetailsException:$e');
        }
      } else {
        print("geUserError: $response");
      }
    });
  }

  void getTokenValid(String token) async {
    setState(() {
      isLoading = true;
    });
    ApiServices().postRequestTokenWithoutBody(AppConfig.tokenexist, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("getTokenExist_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "error") {
            final pref = await SharedPreferences.getInstance();
            pref.clear();
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
}
