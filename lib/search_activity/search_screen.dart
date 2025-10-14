// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/common_files/loading_widget.dart';
import '../Dashboard/Models/Movie.dart';
import '../Dashboard/Models/Usermovies.dart';
import '../Dashboard/MoviesModels.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/movie_categories_card_background.dart';
import '../common_files/movie_categories_card_wishlist.dart';
import '../notification_activity/notification_model.dart';
import '../streamingpalyer/video_player.dart';

// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<NotificationModel> notificationModel = [];
  List<Movies> moviesListModel = [];
  List<Movies> popularMoviesListModel = [];

  bool isLoading = false;
  bool isSearchLoading = false;
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

  // SpeechToText _speech = SpeechToText();
  // late stt.SpeechToText _speech;
  final bool _isListening = false;
  String _searchText = '';
  String _recommendedMoviesTitle = '';

  @override
  void initState() {
    super.initState();

    // _speech = stt.SpeechToText();
    _initSpeech();

    // getRecommendedVideosTemp();
    // getNotificationTemp();
    getInitalValue();
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

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';
    });

    getPopularMoviesLits(_token, profileID);
    // getUserMoviesList(_token, profileID, "");
  }

  List<MoviesModel> moviesModel = [];

  //------------------Temperery values-------/
  var thumnailWishPic = [
    "images/sample_wish_list1.jpg",
    "images/sample_wish_list2.jpg",
    "images/sample_wish_list3.jpg",
    "images/sample_wish_list4.jpg",
    "images/sample_wish_list5.jpg",
    "images/sample_wish_list6.jpg"
  ];

  var thumnailPic = [
    "images/sample_home_screen.jpg",
    "images/sample_movie_2.jpg",
    "images/sample_movie_3.jpg",
    "images/sample_movie_4.jpg",
    "images/sample_movie_5.jpg",
    "images/sample_movie_1.jpg"
  ];
  var title = [
    "Aquaman",
    "Hanuman",
    "JOKER",
    "The Marvel Wonder Women",
    "Leo",
    "Captain Miller"
  ];

  void getNotificationTemp() {
    for (int i = 0; i < 6; i++) {
      notificationModel.add(NotificationModel(
        notificationID: i.toString(),
        movieID: i.toString(),
        title: "Notification Title",
        description: "Notification Description",
        movieName: "Movie Name",
        thumnail: thumnailWishPic[i],
        notificationDate: "2024-01-01",
      ));
    }
  }

  void getRecommendedVideosTemp() {
    for (int i = 0; i < 6; i++) {
      moviesModel.add(MoviesModel(
          catogoryID: i.toString(),
          movieID: "1",
          thumbnailPicture: thumnailPic[i],
          lastPlayedTime: "00:00",
          title: title[i],
          descriptions: "Action"));
    }
  }

  //------------------Temprary values-------/

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
          backgroundColor: AppDefaultColors.appColor,
          appBar: AppBar(
            title: const Text(
              "Search",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppDefaultColors.appColor,
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed:(){
          //     // var status = await Permission.speech.request();
          //   // If not yet listening for speech start, otherwise stop
          //   _speech.isNotListening ? _startListening : _stopListening;
          //   },
          //   tooltip: 'Listen',
          //   child: Icon(_speech.isNotListening ? Icons.mic_off : Icons.mic),
          // ),
          body: isLoading == false
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppDefaultColors.boxDarkGray,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5),
                                child: TextFormField(
                                  cursorColor: AppDefaultColors.white,
                                  style: TextStyle(color: Colors.white),
                                  // controller: userNameController,
                                  validator: (txt) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      setState(() {
                                        if (txt?.length != 0) {
                                          // _isEmailPhoneValid = true;
                                        } else {
                                          // print("SearchTextOnChangedtxt: "+txt.toString());
                                          // getUserMoviesList(_token, profileID, "");
                                          // _isEmailPhoneValid = false;
                                        }
                                      });
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Search for title..',
                                      prefixIcon: IconButton(
                                        icon: Icon(Icons.search,
                                            size: 30,
                                            color:
                                                AppDefaultColors.textLightGray),
                                        onPressed: () {},
                                      ),
                                      // suffixIcon: IconButton(
                                      //   icon: Icon(Icons.mic_none_outlined, size: 30, color: AppDefaultColors.textLightGray),
                                      //   onPressed: _isListening ? null : _toggleListening,
                                      // ),
                                      suffix: isSearchLoading
                                          ? SizedBox(
                                              height: 30.0,
                                              width: 30.0,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Colors.red)),
                                            )
                                          : null),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchText = value;
                                      isSearchLoading = true;
                                      print(
                                          "SearchTextOnChanged: $_searchText");

                                      if (_searchText == "") {
                                        getUserMoviesList(
                                            _token, profileID, "");
                                      } else {
                                        getUserSearchMoviesList(
                                            _token, profileID, _searchText);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Text(
                          //   _speech.isListening
                          //       ? '$_searchText'
                          //   // If listening isn't active but could be tell the user
                          //   // how to start it, otherwise indicate that speech
                          //   // recognition is not yet ready or not supported on
                          //   // the target device
                          //       : _isListening
                          //       ? 'Tap the microphone to start listening...'
                          //       : 'Speech not available',
                          //
                          //   // 'Search Text: $_searchText',
                          //   style: TextStyle(fontSize: 20, color: Colors.white),
                          // ),
                        ],
                      ),
                      moviesListModel.isNotEmpty
                          ? SizedBox(
                              height: 280,
                              child: ListView.builder(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: moviesListModel.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {},
                                      child:
                                          getMovieRecommendedHorizontalWidget(
                                              moviesListModel[index]),
                                    );
                                  }),
                            )
                          : Text(""),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          _recommendedMoviesTitle,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: popularMoviesListModel.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => ViewUserProfile(
                                //               notificationModel: notificationModel[index],
                                //             )));
                              },
                              child:
                                  getUsersWidget(popularMoviesListModel[index]),
                            );
                          }),
                    ],
                  ),
                )
              : LoadingWidget()),
    );
  }

  Widget getUsersWidget(Movies popularMovies) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MovieCardWishListBackgroundView(
              Container(
                child: SizedBox(
                  height: 90,
                  width: 130,
                  child: Stack(children: <Widget>[
                    Container(
                        height: 100,
                        width: 140,
                        alignment: Alignment.center,
                        child: FadeInImage(
                          placeholder:
                              AssetImage("images/default_landscape.jpg"),
                          image:
                              NetworkImage(popularMovies.thumbnail.toString()),
                          imageErrorBuilder: (context, error, stackTrace) {
                            // Return the error image widget
                            return Image.asset('images/default_landscape.jpg',
                                height: 100, fit: BoxFit.cover);
                          },
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                        // Image.network(
                        //   width: double.infinity,
                        //   height: double.infinity,
                        //   notificationModel.thumnail.toString(),
                        //   fit: BoxFit.cover,
                        // ),
                        ),
                    if (popularMovies.movie_access == "1")
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          height: 30,
                          child: const Image(
                              image: AssetImage("images/free_tag_img.png")),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: Text(
                  popularMovies.title.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(color: Colors.white)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.play_arrow,
                      size: 30, color: AppDefaultColors.white),
                  onPressed: () {
                    print("notificationModelMovieID: ${popularMovies.id}");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoApp(
                                  getMovieID: popularMovies.id.toString(),
                                )));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget getMovieRecommendedHorizontalWidget(MoviesModel moviesModel) {
  Widget getMovieRecommendedHorizontalWidget(Movies moviesModel) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoApp(
                            getMovieID: moviesModel.id.toString(),
                          )));
            },
            child: MovieCardBackgroundView(
              Container(
                child: SizedBox(
                  height: 150,
                  width: 130,
                  child: Stack(children: <Widget>[
                    SizedBox(
                        height: 150,
                        width: 130,
                        child: FadeInImage(
                          placeholder:
                              AssetImage("images/default_landscape.jpg"),
                          image: NetworkImage(
                              moviesModel.portraitsmall.toString()),
                          imageErrorBuilder: (context, error, stackTrace) {
                            // Return the error image widget
                            return Image.asset('images/default_landscape.jpg');
                          },
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                        // Image.asset(
                        //   width: double.infinity,
                        //   height: double.infinity,
                        //   moviesModel.portraitsmall.toString(),
                        //   // 'images/sample_home_screen.jpg',
                        //   fit: BoxFit.cover,
                        // ),
                        ),
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
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: Text(
              moviesModel.title.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 10),
            child: Text(
              moviesModel.tagText.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  void _initSpeech() async {
    // _isListening = await _speech.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    // await _speech.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    // await _speech.stop();
    setState(() {});
  }

  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     _searchText = result.recognizedWords;
  //   });
  // }

  // void _toggleListening() async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onError: (error) => print('Error: $error'),
  //     );
  //     if (available) {
  //       setState(() => _isListening = true);
  //       _speech.listen(
  //         onResult: (result) {
  //           setState(() {
  //             _searchText = result.recognizedWords;
  //           });
  //         },
  //       );
  //     }
  //   } else {
  //     setState(() => _isListening = false);
  //     _speech.stop();
  //   }
  // }

  void getPopularMoviesLits(String token, String profileId) async {
    setState(() {
      isLoading = true;
    });
    // ApiServices().getRequestData(AppConfig.appnotifylist + "/" + profileId, token).then((response) async {
    ApiServices()
        .getRequestData("${AppConfig.movieblockslist}4&page=1", token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("Popular_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("PopularDataObject:$data");

          var responseData = json.decode(response.body);

          for (var mainData in responseData["data"]) {
            for (var movieData in mainData["movies"]) {
              print("_movieID:${movieData["id"]}");
              print("_MovieTitle${movieData['title']}");
              String nthumbnailUrl =
                  "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";

              String thumbnailUrl =
                  "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
              String portraitsmallUrl =
                  "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
              String portraitUrl =
                  "${AppConfig.BaseUrl}/${movieData["portrait"]}";

              RegExp exp =
                  RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
              String resultTagText =
                  movieData["tag_text"].replaceAll(exp, '  ');

              popularMoviesListModel.add(Movies(
                id: movieData["id"].toString(),
                title: movieData["title"].toString(),
                movie_access: movieData["movie_access"].toString(),
                topten: movieData["topten"].toString(),
                trailer: movieData["trailer"].toString(),
                certificate: movieData["certificate"].toString(),
                duration: movieData["duration"].toString(),
                tagText: resultTagText,
                publishedDate: movieData["published_date"].toString(),
                userlist: movieData["userlist"].toString(),
                userlike: movieData["userlike"].toString(),
                thumbnail: thumbnailUrl,
                portraitsmall: portraitsmallUrl,
                portrait: portraitUrl,
                usermovies: null,
              ));
              // notificationModel.add(NotificationModel(
              //   notificationID: movieData["id"].toString(),
              //   movieID: movieData["id"].toString(),
              //   title: movieData["title"].toString(),
              //   description: "Notification Description",
              //   movieName: movieData["title"].toString(),
              //   thumnail: nthumbnailUrl,
              //   notificationDate: movieData["published_date"].toString(),
              // ));
            }
          }

          if (popularMoviesListModel.isNotEmpty) {
            _recommendedMoviesTitle = "Popular Movies";
          } else {
            _recommendedMoviesTitle = "";
          }

          setState(() {
            isLoading = false;
            // context.loaderOverlay.hide();
          });
        } catch (e) {
          setState(() {
            isLoading = false;
            // context.loaderOverlay.hide();
          });
          print('PopularMoviesException:$e');
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

  void getUserMoviesList(
      String token, String profileId, String searchType) async {
    isLoading = true;
    moviesListModel.clear();
    // context.loaderOverlay.show();
    // ApiServices().getRequestData(AppConfig.usermovieslist + profileId + "&mylist=" + searchType, token).then((response) async {
    ApiServices()
        .getRequestData(AppConfig.popularMovieblockslist, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("Movie_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObjectM:$data");

          var responseData = json.decode(response.body);

          for (var movieData in responseData["data"]) {
            print("MovieTitle${movieData['title']}");

            Usermovies? usermovies;

            if (movieData['usermovies'] != "") {
              usermovies = Usermovies(
                id: movieData["usermovies"]["id"].toString(),
                movieId: movieData["usermovies"]["movie_id"].toString(),
                mylist: movieData["usermovies"]["mylist"].toString(),
                likes: movieData["usermovies"]["likes"].toString(),
                watchTime: movieData["usermovies"]["watchTime"].toString(),
                watching: movieData["usermovies"]["watching"].toString(),
                watched: movieData["usermovies"]["watched"].toString(),
                watchedPercent:
                    movieData["usermovies"]["watched_percent"].toString(),
                viewed: movieData["usermovies"]["viewed"].toString(),
              );
            }

            String thumbnailUrl =
                "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
            String portraitsmallUrl =
                "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
            String portraitUrl =
                "${AppConfig.BaseUrl}/${movieData["portrait"]}";

            RegExp exp =
                RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
            String resultTagText = movieData["tag_text"].replaceAll(exp, '  ');

            print("moviesListModel $thumbnailUrl");
            moviesListModel.add(Movies(
              id: movieData["id"].toString(),
              title: movieData["title"].toString(),
              movie_access: movieData["movie_access"].toString(),
              topten: movieData["topten"].toString(),
              trailer: movieData["trailer"].toString(),
              certificate: movieData["certificate"].toString(),
              duration: movieData["duration"].toString(),
              tagText: resultTagText,
              publishedDate: movieData["published_date"].toString(),
              userlist: movieData["userlist"].toString(),
              userlike: movieData["userlike"].toString(),
              thumbnail: thumbnailUrl,
              portraitsmall: portraitsmallUrl,
              portrait: portraitUrl,
              usermovies: usermovies,
            ));
          }

          // getUserMoviesLikes(_token, profileID, "1");
          // getPopularMoviesLits(_token, profileID);

          // setState(() {
          //   isLoading = false;
          // });
        } catch (e) {
          setState(() {
            isLoading = false;
            // context.loaderOverlay.hide();
          });
          print('MylistsMovieException:$e');
        }
      } else {
        print("MyListError: $response");
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

  void getUserMoviesLikes(
      String token, String profileId, String searchType) async {
    isLoading = true;
    notificationModel.clear();
    // context.loaderOverlay.show();
    ApiServices()
        .getRequestData(
            "${AppConfig.usermovieslist}$profileId&likes=$searchType", token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("MovieLike_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObjectML:$data");

          var responseData = json.decode(response.body);

          for (var movieData in responseData["data"]) {
            print("MovieLTitle${movieData['title']}");

            String thumbnailUrl =
                "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
            String portraitsmallUrl =
                "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
            String portraitUrl =
                "${AppConfig.BaseUrl}/${movieData["portrait"]}";

            notificationModel.add(NotificationModel(
              notificationID: movieData["id"].toString(),
              movieID: movieData["id"].toString(),
              title: movieData["title"].toString(),
              description: "Notification Description",
              movieName: movieData["title"].toString(),
              thumnail: thumbnailUrl,
              notificationDate: movieData["published_date"].toString(),
            ));
          }

          if (notificationModel.isEmpty) {
            getPopularMoviesLits(_token, profileID);
          } else {
            // _recommendedMoviesTitle = "Recommended Movies";
            _recommendedMoviesTitle = "";
          }

          // setState(() {
          //   isLoading = false;
          // });
        } catch (e) {
          setState(() {
            isLoading = false;
            // context.loaderOverlay.hide();
          });
          print('LikesMovieException:$e');
        }
      } else {
        print("LikesError: $response");
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

  void getUserSearchMoviesList(
      String token, String profileId, String searchText) async {
    isSearchLoading = true;
    moviesListModel.clear();
    ApiServices()
        .getRequestData(
            "${AppConfig.searchMovieslist}$searchText&profile_id=$profileId",
            token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("SearchMovie_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("SearchDataObjectM:$data");

          var responseData = json.decode(response.body);

          for (var movieData in responseData["data"]) {
            print("MovieTitle${movieData['title']}");

            Usermovies? usermovies;
            if (movieData['usermovies'] != "") {
              usermovies = Usermovies(
                id: movieData["usermovies"]["id"].toString(),
                movieId: movieData["usermovies"]["movieId"].toString(),
                mylist: movieData["usermovies"]["mylist"].toString(),
                likes: movieData["usermovies"]["likes"].toString(),
                watchTime: movieData["usermovies"]["watchTime"].toString(),
                watching: movieData["usermovies"]["watching"].toString(),
                watched: movieData["usermovies"]["watched"].toString(),
                watchedPercent:
                    movieData["usermovies"]["watchedPercent"].toString(),
                viewed: movieData["usermovies"]["viewed"].toString(),
              );
            }

            String thumbnailUrl =
                "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
            String portraitsmallUrl =
                "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
            String portraitUrl =
                "${AppConfig.BaseUrl}/${movieData["portrait"]}";

            RegExp exp =
                RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
            String resultTagText = movieData["tag_text"].replaceAll(exp, '  ');

            print("moviesListModel $thumbnailUrl");
            moviesListModel.add(Movies(
              id: movieData["id"].toString(),
              title: movieData["title"].toString(),
              movie_access: movieData["movie_access"].toString(),
              topten: movieData["topten"].toString(),
              trailer: movieData["trailer"].toString(),
              certificate: movieData["certificate"].toString(),
              duration: movieData["duration"].toString(),
              tagText: resultTagText,
              publishedDate: movieData["published_date"].toString(),
              userlist: movieData["userlist"].toString(),
              userlike: movieData["userlike"].toString(),
              thumbnail: thumbnailUrl,
              portraitsmall: portraitsmallUrl,
              portrait: portraitUrl,
              usermovies: usermovies,
            ));
          }

          setState(() {
            isSearchLoading = false;
          });
        } catch (e) {
          setState(() {
            isSearchLoading = false;
            // context.loaderOverlay.hide();
          });
          print('UserMovieException:$e');
        }
      } else {
        print("MyListError: $response");
        // context.loaderOverlay.hide();
        isSearchLoading = false;
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isSearchLoading = false;
        // context.loaderOverlay.hide();
      });
    });
  }
}
