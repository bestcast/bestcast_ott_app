// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
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
import '../app_config/app_preferences.dart';
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

  String _mainMovieUrl = "";
  String _mainMovieId = "";
  String _mainMoviePicture = "";
  String _mainMovieCategory = "";

  final String _loadUrl = "";
  String _id = "";
  String _email = "";
  String _phone = "";
  String _name = "";
  String _firstname = "";
  String _lastname = "";
  String _dob = "";
  String _gender = "";
  String _plan = "";
  String _plan_expiry = "";
  String _photo = "";
  String _otp = "";
  String _tvcode = "";
  String _referal_code = "";
  String _credits_used = "";
  String _refferer = "";
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  late MovieData? movieData;
  bool scrolleEnabled = false;
  bool hasMoreScroll = true;
  var _page = 1;

  List<MoviesCategoryModel> moviesCategoryModel = [];
  List<MoviesMainCategoryModel> moviesMainCategoryModelList = [];

  // List<Movies> userMainCategoryModelList = [];
  List<dynamic> moviesMainCategoryModel1List = [];

  var scrollController = ScrollController();
  bool _isAppBarVisible = true;
  double _appBarOpacity = 1.0;
  final Duration _duration = Duration(milliseconds: 500);

  bool _isAddedMyList = false;

  var thumnailPic = [
    "images/sample_home_screen.jpg",
    "images/sample_movie_2.jpg",
    "images/sample_movie_3.jpg",
    "images/sample_movie_4.jpg",
    "images/sample_movie_5.jpg",
    "images/sample_movie_1.jpg"
  ];

  var thumnailWishPic = [
    "images/sample_wish_list1.jpg",
    "images/sample_wish_list2.jpg",
    "images/sample_wish_list3.jpg",
    "images/sample_wish_list4.jpg",
    "images/sample_wish_list5.jpg",
    "images/sample_wish_list6.jpg"
  ];

  var lastPlayedTimeItems = ["0.5", "0.2", "0.7", "0.4", "0.8", "0.3"];

  var title = [
    "Aquaman",
    "Hanuman",
    "JOKER",
    "The Marvel Wonder Women",
    "Leo",
    "Captain Miller"
  ];
  var categoryItems = [
    "My Wish List",
    "Tamil Movies",
    "Telungu Movies",
    "English Movies",
    "Hindi Movies"
  ];

  // var allCategoryItems = ["Wish List", "Tamil", "Telungu", "English", "Hindi", "Comedies", "Action", "Adventures"];
  List<Genres> allCategoryItems = [];

  // "Wish List", "Tamil", "Telungu", "English", "Hindi", "Comedies", "Action", "Adventures"];

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
          moviesModel.add(MoviesModel(
              catogoryID: catID.toString(),
              movieID: "1",
              thumbnailPicture: thumnailWishPic[j],
              lastPlayedTime: lastPlayedTimeItems[j],
              title: title[j],
              descriptions: "Action"));
        } else {
          moviesModel.add(MoviesModel(
              catogoryID: catID.toString(),
              movieID: "1",
              thumbnailPicture: thumnailPic[j],
              lastPlayedTime: lastPlayedTimeItems[j],
              title: title[j],
              descriptions: "Action"));
        }

        if (j < 6) {
          j++;
        }

        // moviesModel.add(MoviesModel(
        //     catogoryID: "1",
        //     movieID: "1",
        //     thumbnailPicture: "images/sample_home_screen.jpg",
        //     title: "Aquaman",
        //     descriptions: "Action"));
        // moviesModel.add(MoviesModel(
        //     catogoryID: "1",
        //     movieID: "2",
        //     thumbnailPicture: "images/sample_movie_2.jpg",
        //     title: "Hanuman",
        //     descriptions: "Action"));
        // moviesModel.add(MoviesModel(
        //     catogoryID: "1", movieID: "3", thumbnailPicture: "images/sample_movie_3.jpg", title: "JOKER", descriptions: "Action"));
        // moviesModel.add(MoviesModel(
        //     catogoryID: "4",
        //     movieID: "4",
        //     thumbnailPicture: "images/sample_movie_4.jpg",
        //     title: "The Marvel Wonder Women",
        //     descriptions: "Action"));
        // moviesModel.add(MoviesModel(
        //     catogoryID: "5", movieID: "5", thumbnailPicture: "images/sample_movie_5.jpg", title: "Leo", descriptions: "Action"));
        // moviesModel.add(MoviesModel(
        //     catogoryID: "6",
        //     movieID: "6",
        //     thumbnailPicture: "images/sample_movie_1.jpg",
        //     title: "Captain Miller",
        //     descriptions: "Action"));
      }
      moviesCategoryModel.add(MoviesCategoryModel(
          catogoryID: catID.toString(),
          catogoryName: categoryItems[i],
          moviesModel: moviesModel));
    }

    // moviesCategoryModel.add(MoviesCategoryModel(catogoryID: "2", catogoryName: "Tamil Movies", moviesModel: moviesModel));
    // moviesCategoryModel.add(MoviesCategoryModel(catogoryID: "3", catogoryName: "Telungu Movies", moviesModel: moviesModel));
    // moviesCategoryModel.add(MoviesCategoryModel(catogoryID: "4", catogoryName: "English Movies", moviesModel: moviesModel));
    // moviesCategoryModel.add(MoviesCategoryModel(catogoryID: "5", catogoryName: "Hindi Movies", moviesModel: moviesModel));
  }

  @override
  void initState() {
    getInitalValue();
    // getMoviesListsTemp();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (await CommonWidget().isInternetConnectivity()) {
          if (hasMoreScroll) {
            print("RefreshEnabled: $_page");
            scrolleEnabled = true;
            getBlockMoviesLits(_token, profileID, "", _page);
          }
        } else {
          appUtils.showToast("Check your internet connection.");
        }
      }

      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isAppBarVisible) {
          setState(() {
            _isAppBarVisible = false;
            _appBarOpacity = 0.0;
          });
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
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

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _id = pref.getString(AppPreferences.id) ?? '';
      _email = pref.getString(AppPreferences.email) ?? '';
      _phone = pref.getString(AppPreferences.phone) ?? '';
      _name = pref.getString(AppPreferences.name) ?? '';
      _firstname = pref.getString(AppPreferences.firstname) ?? '';
      _lastname = pref.getString(AppPreferences.lastname) ?? '';
      _dob = pref.getString(AppPreferences.dob) ?? '';
      _gender = pref.getString(AppPreferences.gender) ?? '';
      _plan = pref.getString(AppPreferences.plan) ?? '';
      _plan_expiry = pref.getString(AppPreferences.plan_expiry) ?? '';
      _photo = pref.getString(AppPreferences.photo) ?? '';
      _otp = pref.getString(AppPreferences.otp) ?? '';
      _tvcode = pref.getString(AppPreferences.tvcode) ?? '';
      _referal_code = pref.getString(AppPreferences.referal_code) ?? '';
      _credits_used = pref.getString(AppPreferences.credits_used) ?? '';
      _refferer = pref.getString(AppPreferences.refferer) ?? '';
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
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // statusBarColor: Colors.red, // You can use this as well
        statusBarIconBrightness:
            Brightness.light, // OR Vice Versa for ThemeMode.dark
        statusBarBrightness:
            Brightness.light, // OR Vice Versa for ThemeMode.dark
        systemNavigationBarColor:
            Colors.black, // OR Vice Versa for ThemeMode.dark
      ),
    );

    late DateTime currentBackPressTime;
    Future<bool> onWillPop() {
      DateTime now = DateTime.now();
      if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        appUtils.showToast("Tap back button again to exit");
        return Future.value(false);
      }
      return Future.value(true);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue, // Set your app's primary color here
      ),
      home: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          child: Stack(children: <Widget>[
            // ColorFiltered(
            //   colorFilter: ColorFilter.mode(Colors.black12, BlendMode.dstOut), // Set the color filter
            //   child: Image.asset(
            //     width: double.infinity,
            //     height: double.infinity,
            //     'images/sample_home_screen.jpg',
            //     fit: BoxFit.cover,
            //     opacity: const AlwaysStoppedAnimation(0.2),
            //   ),
            // ),
            isLoading == false
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: 160, left: 15, right: 15, bottom: 10),
                      child: Column(
                        children: [
                          MainCardBackgroundView(
                            Container(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 320,
                                child: Stack(
                                  children: <Widget>[
                                    SizedBox(
                                        // height: 500,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width: double.infinity,
                                        // margin: EdgeInsets.only(left: 20,right: 20),
                                        // child: Image.asset(
                                        //   width: double.infinity,
                                        //   height: double.infinity,
                                        //   'images/sample_home_screen.jpg',
                                        //   fit: BoxFit.cover,
                                        // ),

                                        // CachedNetworkImage(
                                        //   imageUrl: _mainMoviePicture,
                                        //   placeholder: (context, url) => CircularProgressIndicator(),
                                        //   errorWidget: (context, url, error) => Icon(Icons.error),
                                        // ),
                                        // child: Image.network(
                                        //   width: double.infinity,
                                        //   height: double.infinity,
                                        //   _mainMoviePicture,
                                        //   fit: BoxFit.cover,
                                        // ),

                                        child: FadeInImage(
                                          placeholder: AssetImage(
                                              "images/default_portrate_large.jpg"),
                                          image:
                                              NetworkImage(_mainMoviePicture),
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            // Return the error image widget
                                            return Image.asset(
                                                'images/default_portrate_large.jpg');
                                          },
                                          // height: 500,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          fit: BoxFit.cover,
                                        )),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: MainTransaparentCardBackgroundView(
                                        Container(
                                          child: SizedBox(
                                            width: double.infinity,
                                            // height: 500,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        // height: 500,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        padding: EdgeInsets.only(bottom: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20.0),
                                              child: Text(
                                                _mainMovieCategory,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0,
                                                            right: 10,
                                                            left: 10),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5.0),
                                                      child: SubmitWhiteButton(
                                                        "Play",
                                                        Icons.play_arrow,
                                                        onTap: () async {
                                                          // final value =
                                                          // Navigator.push(context, MaterialPageRoute(builder: (context) => PlanDetailsPage()));

                                                          //TODO enable must
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      VideoApp(
                                                                          getMovieID:
                                                                              _mainMovieId)));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0,
                                                            right: 10),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5.0),
                                                      child:
                                                          SubmitTransparentButton(
                                                        "My List",
                                                        _isAddedMyList
                                                            ? Icons.check
                                                            : Icons.add,
                                                        onTap: () async {
                                                          if (loggedStatus) {
                                                            setState(() {
                                                              var isMyList = 0;
                                                              if (_isAddedMyList) {
                                                                _isAddedMyList =
                                                                    false;
                                                                isMyList = 0;
                                                              } else {
                                                                _isAddedMyList =
                                                                    true;
                                                                isMyList = 1;
                                                              }

                                                              final postValues =
                                                                  {
                                                                'mylist':
                                                                    isMyList,
                                                              };
                                                              setUserMovies(
                                                                  _token,
                                                                  profileID,
                                                                  _mainMovieId,
                                                                  postValues);
                                                            });
                                                          } else {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            LoginPage()));
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding: const EdgeInsets.all(10.0),
                                                //   child: Container(
                                                //     padding: const EdgeInsets.only(right: 5.0),
                                                //     child: RoundIconBackgroundView(
                                                //       "Categories",
                                                //       Icons.keyboard_arrow_down_sharp,
                                                //       onTap: () async {},
                                                //     ),
                                                //   ),
                                                // ),
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
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              // controller: scrollController,
                              itemCount: moviesMainCategoryModelList.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index <
                                    moviesMainCategoryModelList.length) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, top: 5.0, bottom: 2.0),
                                        child: Text(
                                          moviesMainCategoryModelList[index]
                                              .title
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      // ListTile(
                                      //   title: Row(
                                      //     children: [
                                      //       Expanded(
                                      //         child: Text(
                                      //           moviesMainCategoryModelList[index].title.toString(),
                                      //           style: const TextStyle(
                                      //               color: Colors.white, fontSize: 15.0,
                                      //               fontWeight: FontWeight.w600),
                                      //         ),
                                      //       ),
                                      //       // Text(
                                      //       //   "View All >>",
                                      //       //   style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w700),
                                      //       // ),
                                      //     ],
                                      //   ),
                                      // ),
                                      SizedBox(
                                        // height: moviesCategoryModel[index].catogoryID == "1" ? 200 : 280,
                                        // height: index == "1" ? 200 : 215,
                                        height: 190,

                                        child: ListView.builder(
                                            // physics: const NeverScrollableScrollPhysics(),
                                            physics: ClampingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            // itemCount: moviesCategoryModel[index].moviesModel?.length,
                                            itemCount:
                                                moviesMainCategoryModelList[
                                                        index]
                                                    .movies
                                                    ?.length,
                                            itemBuilder: (BuildContext context,
                                                int index2) {
                                              return GestureDetector(
                                                onTap: () {
                                                  // var _movieID = moviesMainCategoryModelList[index].movies![index2]!.id.toString();

                                                  // Navigator.push(context,
                                                  //     MaterialPageRoute(builder: (context) => VideoApp(getMovieID: _movieID)));
                                                },
                                                // child: moviesCategoryModel[index].catogoryID == "1"
                                                //     ? getMovieWishListCategoryWidget(
                                                //         moviesCategoryModel[index].moviesModel![index2]!)
                                                //     : getMovieCategoryWidget(moviesCategoryModel[index].moviesModel![index2]!),
                                                child: getMovieCategoryWidget(
                                                    moviesMainCategoryModelList[
                                                            index]
                                                        .movies![index2]),
                                              );
                                            }),
                                      ),
                                    ],
                                  );
                                } else {
                                  return hasMoreScroll
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 5,
                                                color: Colors.red),
                                          ),
                                        )
                                      : Text("");
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
                          margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                          child: Padding(
                            // padding: const EdgeInsets.only(top: 50.0, left: 20),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage()));
                                      },
                                      child: Text("LOGIN",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //TOP bar
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: RoundBackgroundView(
                                      "All Movies",
                                      onTap: () async {
                                        if (await CommonWidget()
                                            .isInternetConnectivity()) {
                                          getBannerMoviesDetails(
                                              _token, profileID, "", "1");
                                        } else {
                                          CommonWidget().showSnackBar(
                                              context,
                                              ContentType.warning,
                                              "Check your internet connection.",
                                              "");
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: RoundIconBackgroundView(
                                      "Categories",
                                      Icons.keyboard_arrow_down_sharp,
                                      onTap: () async {
                                        getBottomWidget();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ]),
        ),
      ),
    );
  }

  // Widget getMovieCategoryWidget(MoviesModel moviesModel) {
  Widget getMovieCategoryWidget(Movies moviesModel) {
    print("checkTitle: ${moviesModel.title}");
    print("checkImage: ${moviesModel.portrait}");
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // moviesModel.usermovies != null ? moviesModel.usermovies?.mylist == "1"
          //     ? MovieCardWishListBackgroundView(
          //   Container(
          //     height: 170,
          //     width: 230,
          //     child: Image.network(
          //       width: double.infinity,
          //       height: double.infinity,
          //       // moviesModel.thumbnailPicture.toString(),
          //       moviesModel.thumbnail.toString(),
          //       // 'images/sample_home_screen.jpg',
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // )
          //     :
          MovieCardBackgroundView(
            Container(
              child: SizedBox(
                height: 150,
                width: 110,
                // child: CachedNetworkImage(
                //   imageUrl: moviesModel.portraitsmall.toString(),
                //   imageBuilder: (context, imageProvider) => Container(
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //           image: imageProvider,
                //           fit: BoxFit.cover,
                //           colorFilter:
                //           ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
                //     ),
                //   ),
                //   placeholder: (context, url) => CircularProgressIndicator(),
                //   errorWidget: (context, url, error) => Icon(Icons.error),
                // ),

                child: Stack(children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => VideoApp(
                                  getMovieID: moviesModel.id.toString())));
                    },
                    child: FadeInImage(
                      // placeholder: AssetImage("images/sample_movie_1.jpg"),
                      placeholder:
                          AssetImage("images/default_portrate_small.jpg"),
                      image: NetworkImage(moviesModel.portraitsmall.toString()),
                      imageErrorBuilder: (context, error, stackTrace) {
                        // Return the error image widget
                        return Image.asset('images/default_portrate_small.jpg',
                            width: 130, fit: BoxFit.cover);
                      },
                      width: 130,
                      height: 170,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // moviesModel
                  if (moviesModel.movie_access == "1")
                    Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        height: 30,
                        child: const Image(
                            image: AssetImage("images/free_tag_img.png")),
                      ),
                    ),
                ]),
                //   child: moviesModel.portraitsmall.toString() != null
                //       ? Image.network(
                //           width: double.infinity,
                //           height: double.infinity,
                //           // moviesModel.thumbnailPicture.toString(),
                //           moviesModel.portraitsmall.toString(),
                //           // 'images/sample_home_screen.jpg',
                //           fit: BoxFit.cover,
                //         )
                //       : Image.asset(
                //           width: double.infinity,
                //           height: double.infinity,
                //           // moviesModel.thumbnailPicture.toString(),
                //           "images/sample_movie_2.jpg",
                //           // 'images/sample_home_screen.jpg',
                //           fit: BoxFit.cover,
                //         ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
            child: Text(
              moviesModel.title.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                height: 1,
                fontSize: 10.0,
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          //   child: Text(
          //     // moviesModel.descriptions.toString(),
          //     moviesModel.certificate.toString(),
          //     style: const TextStyle(color: Colors.white, fontSize: 14.0),
          //   ),
          // ),
        ],
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
                    // borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5)),

                    child: LinearProgressIndicator(
                      value:
                          double.parse(moviesModel.lastPlayedTime.toString()),
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
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w900),
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
      backgroundColor: AppDefaultColors.appColor.withOpacity(0.7),
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
                      "All categories",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w700),
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8),
                      child: ListView.builder(
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: allCategoryItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Align(
                              alignment: Alignment.center,
                              child: Text(
                                allCategoryItems[index].title.toString(),
                                style: const TextStyle(
                                    color: AppDefaultColors.textLightGray,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            onTap: () async {
                              // Add your onTap logic here
                              if (await CommonWidget()
                                  .isInternetConnectivity()) {
                                getBannerMoviesDetails(_token, profileID,
                                    allCategoryItems[index].id.toString(), "2");
                                // getBannerMoviesDetails(_token, profileID, "2", "2");
                              } else {
                                CommonWidget().showSnackBar(
                                    context,
                                    ContentType.warning,
                                    "Check your internet connection.",
                                    "");
                              }
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

  void getBlockMoviesLits(
      String token, String profileId, String categoryId, int pageId) async {
    isLoading = true;
    var limit = 0;
    if (scrolleEnabled == false) {
      moviesMainCategoryModelList.clear();
    }

    // var loadUrl="";
    // if(loadType==1){
    //   loadUrl=AppConfig.movieblockslist + pageId + "&profile_id=" + profileId;
    // }else{
    //   loadUrl=AppConfig.movieblockslist + pageId + "&profile_id=" + profileId+"&genre_id="+categoryId;
    // }

    print("PageCount: $_page");
    print("PageCategoryIdCount: $categoryId");

    ApiServices()
        .getRequestData(
            "${AppConfig.movieblockslist}1&page=$pageId&profile_id=$profileId&genre_id=$categoryId",
            token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("Movie_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObject:$data");

          // var responseData = json.decode(response.body);
          // var responseMoviesData = jsonDecode(data);

          // moviesMainCategoryModelList = jsonDecode(data);
          // moviesMainCategoryModelList.map((e) => MoviesMainCategoryModel.fromJson(data)).toList();
          // moviesMainCategoryModelList= MoviesMainCategoryModel.fromJson(data);

          var responseData = json.decode(response.body);

          for (var mainData in responseData["data"]) {
            limit++;

            print("movieID:${mainData["id"]}");
            print("MovieTitle${mainData['title']}");

            List<Movies> userMainCategoryModelList = [];
            for (var movieData in mainData["movies"]) {
              // print("MovieTitleIDs" + movieData['usermovies']["id"].toString());

              Usermovies? usermovies;

              if (movieData['usermovies'] != "") {
                usermovies = Usermovies(
                  id: movieData["usermovies"]["id"].toString(),
                  movieId: movieData["usermovies"]["movie_id"].toString(),
                  mylist: movieData["usermovies"]["mylist"].toString(),
                  likes: movieData["usermovies"]["likes"].toString(),
                  watchTime: movieData["usermovies"]["watch_time"].toString(),
                  watching: movieData["usermovies"]["watching"].toString(),
                  watched: movieData["usermovies"]["watched"].toString(),
                  watchedPercent:
                      movieData["usermovies"]["watched_percent"].toString(),
                  viewed: movieData["usermovies"]["viewed"].toString(),
                );
              }

              String movieAccess = movieData["movie_access"].toString();
              print("_movie_access$movieAccess");

              String thumbnailUrl =
                  "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
              String portraitsmallUrl =
                  "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
              String portraitUrl =
                  "${AppConfig.BaseUrl}/${movieData["portrait"]}";

              print("usermoviesStatus${movieData["usermovies"]}");
              print("portraitImageUrl: {$portraitUrl}}");

              // int chek = 0;
              // if (chek == 0) {
              //   setState(() {
              //     _mainMoviePicture = portraitUrl;
              //     _mainMovieId = movieData["id"].toString();
              //     _mainMovieUrl = movieData["trailer"].toString();
              //     _mainMovieCategory = movieData["tag_text"].toString();
              //   });
              // }
              //
              // chek++;

              userMainCategoryModelList.add(Movies(
                id: movieData["id"].toString(),
                title: movieData["title"].toString(),
                movie_access: movieData["movie_access"].toString(),
                topten: movieData["topten"].toString(),
                trailer: movieData["trailer"].toString(),
                certificate: movieData["certificate"].toString(),
                duration: movieData["duration"].toString(),
                tagText: movieData["tag_text"].toString(),
                publishedDate: movieData["published_date"].toString(),
                userlist: movieData["userlist"].toString(),
                userlike: movieData["userlike"].toString(),
                thumbnail: thumbnailUrl,
                portraitsmall: portraitsmallUrl,
                portrait: portraitUrl,
                usermovies: usermovies,
              ));
            }
            // var moviesDataJson = json.decode(mainData["movies"]);
            // print("MovieTitle" + moviesDataJson['usermovies']["id"].toString());
            // var moviesData = moviesDataJson["movies"];

            print("checkStatus: catogeryMovie");
            moviesMainCategoryModelList.add(MoviesMainCategoryModel(
              id: mainData["id"].toString(),
              title: mainData["title"].toString(),
              movies: userMainCategoryModelList,
            ));

            print("checkStatus: mainMovie");
          }

          if (limit < 5) {
            setState(() {
              hasMoreScroll = false;
              scrolleEnabled = false;
            });
          }

          if (_page == 1) {
            getCastegoryDetails(token);
          }

          if (hasMoreScroll) {
            setState(() {
              _page++;
            });
          }

          // setState(() {
          //   isLoading = false;
          //   // context.loaderOverlay.hide();
          // });
        } catch (e) {
          setState(() {
            isLoading = false;
            // context.loaderOverlay.hide();
          });
          print('DashboardMovieListException:$e');
        }
      } else {
        print("Error: $response");
        // context.loaderOverlay.hide();
        isLoading = false;
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        if (_page != 1) {
          isLoading = false;
        }

        // context.loaderOverlay.hide();
      });
    });
  }

  void getBannerMoviesDetails(
      String token, String profileId, String categoryID, String pageId) async {
    setState(() {
      isLoading = true;
    });

    print("categoryID: $categoryID");
    // ApiServices().getRequestData(AppConfig.bannerlist +"1&profile_id=2", token).then((response) async {
    // ApiServices().getRequestData(AppConfig.bannerlist + pageId + "&profile_id=" + profileId, token).then((response) async {
    ApiServices()
        .getRequestWithoutToken(
            "${AppConfig.bannerlist}$pageId&genre_id=$categoryID")
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("Banner_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);

          var data = jsonReponse['data'];

          print("DataObject:$data");
          print("----------------");
          printWrapped(data.toString());
          print("---------------");
          var responseData = json.decode(response.body);

          String bannerId = data["id"].toString();
          String bannerTitle = data["title"].toString();
          String bannerImage = "${AppConfig.BaseUrl}/${data["image"]}";
          String bannerThumbnail = "${AppConfig.BaseUrl}/${data["thumbnail"]}";
          String bannerLogo = "${AppConfig.BaseUrl}/${data["logo"]}";

          String id = data["movies"]["id"].toString();
          String urlkey = data["movies"]["urlkey"].toString();
          String title = data["movies"]["title"].toString();
          String movieAccess = data["movies"]["movie_access"].toString();
          String content = data["movies"]["content"].toString();
          String publishedDate = data["movies"]["published_date"].toString();
          String releaseDate = data["movies"]["release_date"].toString();

          String image = "${AppConfig.BaseUrl}/${data["movies"]["image"]}";
          String medium = "${AppConfig.BaseUrl}/${data["movies"]["medium"]}";
          String thumbnail =
              "${AppConfig.BaseUrl}/${data["movies"]["thumbnail"]}";
          String portraitsmall =
              "${AppConfig.BaseUrl}/${data["movies"]["portraitsmall"]}";
          String portrait =
              "${AppConfig.BaseUrl}/${data["movies"]["portrait"]}";

          String duration = data["movies"]["duration"].toString();
          String durationText = data["movies"]["duration_text"].toString();
          String certificate = data["movies"]["certificate"].toString();
          String certificateText =
              data["movies"]["certificate_text"].toString();
          String tagText = data["movies"]["tag_text"].toString();
          String topten = data["movies"]["topten"].toString();
          String trailer = data["movies"]["trailer"].toString();
          String trailer480p = data["movies"]["trailer_480p"].toString();
          String videoUrl = data["movies"]["video_url"].toString();
          String moviesource = data["movies"]["moviesource"].toString();
          String subtitleStatus = data["movies"]["subtitle_status"].toString();

          print("MainMoiveDetails:$title");
          print("DataMoiveDetails:${data["movies"]['usermovies']}");

          Usermovies usermovies1;
          var jsonReponse1 = jsonEncode(data["movies"]['usermovies']);
          var jsonData = jsonDecode(jsonReponse1.toString());

          // Map<String, dynamic> jsonObject = json.decode(data["movies"]['usermovies'].toString());
          // if (data["movies"]['usermovies'] != "" && data["movies"]['usermovies'] != null) {
          if (jsonData.isNotEmpty) {
            print("MainMoiveDetailsTitle:$title");
            usermovies1 = Usermovies(
              id: data["movies"]["usermovies"]["id"].toString(),
              movieId: data["movies"]["usermovies"]["movie_id"].toString(),
              mylist: data["movies"]["usermovies"]["mylist"].toString(),
              likes: data["movies"]["usermovies"]["likes"].toString(),
              watchTime: data["movies"]["usermovies"]["watch_time"].toString(),
              watching: data["movies"]["usermovies"]["watching"].toString(),
              watched: data["movies"]["usermovies"]["watched"].toString(),
              watchedPercent:
                  data["movies"]["usermovies"]["watched_percent"].toString(),
              viewed: data["movies"]["usermovies"]["viewed"].toString(),
            );

            print("myListUserMovies:${data["movies"]["usermovies"]}");
            var myList = data["movies"]["usermovies"]["mylist"].toInt();
            print("myListDetails:$myList");
            if (myList == 0) {
              _isAddedMyList = false;
            } else {
              _isAddedMyList = true;
            }
          }

          RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
          String resultTagText = tagText.replaceAll(exp, '  ');
          String resultTagText1 = certificateText.replaceAll(',', ' ');

          setState(() {
            _mainMoviePicture = portrait;
            // _mainMoviePicture = _bannerLogo;
            _mainMovieId = id.toString();
            _mainMovieUrl = videoUrl.toString();
            _mainMovieCategory = resultTagText;
          });

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

          getBlockMoviesLits(_token, profileID, categoryID, _page);

          // setState(() {
          //   isLoading = false;
          //   // context.loaderOverlay.hide();
          // });
        } catch (e) {
          setState(() {
            isLoading = false;
            // context.loaderOverlay.hide();
          });
          print('BannerException:$e');
        }
      } else {
        print("Error: $response");
        // context.loaderOverlay.hide();
        isLoading = false;
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isLoading = false;
        // context.loaderOverlay.hide();
      });
    });
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches("LongPrint: $text")
        .forEach((match) => print(match.group(0)));
  }

  void getCastegoryDetails(String token) async {
    allCategoryItems.clear();
    setState(() {
      isLoading = true;
    });
    ApiServices()
        .getRequestData(AppConfig.genrelist, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("gener_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);

          // var data = jsonReponse['data'];
          // print("DataObject:" + data.toString());

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
            // context.loaderOverlay.hide();
          });
          print('GenrelistException:$e');
        }
      } else {
        print("Error: $response");
        // context.loaderOverlay.hide();
        setState(() {
          isLoading = false;
        });
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isLoading = false;
        // context.loaderOverlay.hide();
      });
    });
  }

  void setUserMovies(String token, String profileID, String movieID,
      Map<String, int> postValues) async {
    // final postValues = {
    //   'mylist': _mylist,
    // };

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

  void getUserDetails(String token) async {
    // setState(() {
    //   isLoading = true;
    // });
    ApiServices()
        .postRequestTokenWithoutBody(AppConfig.getUserDetails, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("getUserDetails_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            String? planExpiry =
                jsonReponse['results']['user']['plan_expiry'].toString();
            String? planStatus =
                jsonReponse['results']['user']['plan_status'].toString();
            String? planDeviceStatus =
                jsonReponse['results']['user']['plan_device_status'].toString();

            final pref = await SharedPreferences.getInstance();
            await pref.setString(AppPreferences.plan_expiry, planExpiry);
            await pref.setString(
                AppPreferences.plan_device_status, planDeviceStatus);
            await pref.setString(AppPreferences.plan_status, planStatus);
          } else {
            if (status == "error") {
              getTokenValid(token);
            }
          }
          // isLoading = false;
        } catch (e) {
          // isLoading = false;
          print('getUserDetailsException:$e');
        }
      } else {
        // setState(() {
        //   isLoading = false;
        // });
        print("geUserError: $response");
      }

      // isLoading = false;
    });
    // isLoading = false;
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
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "error") {
            final pref = await SharedPreferences.getInstance();
            pref.clear();
          }
          // isLoading = false;
        } catch (e) {
          // isLoading = false;
          print('getTokenExistException:$e');
        }
      } else {
        // setState(() {
        //   isLoading = false;
        // });
        print("geTokenResError: $response");
      }

      // isLoading = false;
    });
    // isLoading = false;
    setState(() {
      isLoading = false;
    });
  }
}
