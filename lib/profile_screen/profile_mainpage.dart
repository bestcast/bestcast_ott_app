import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/Dashboard/Models/Usermovies.dart';
import 'package:bestcaststudios/common_files/movie_bottom_card_background.dart';
import 'package:bestcaststudios/common_files/movie_top_card_background.dart';
import 'package:bestcaststudios/download_files/dowloadmoviefiles.dart';
import 'package:bestcaststudios/register/who_watching_page.dart';
import 'package:bestcaststudios/webview_pages/bestcast_webviewpages.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Dashboard/Models/Movie.dart';

import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../app_settings/appsettingspage.dart';
import '../authendication/login_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../common_files/movie_categories_card_wishlist.dart';
import '../common_files/movie_vertical_card_background.dart';
import '../main_screen.dart';
import '../streamingpalyer/video_player.dart';

class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({super.key});

  @override
  State<ProfileMainPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  final AppUtils appUtils = AppUtils();

  List<Movies> moviesMyListModel = [];
  List<Movies> moviesWatchingModel = [];
  List<Movies> moviesRecentlyModel = [];

  bool isLoading = false;
  bool loggedStatus = false;
  bool permissionGranted = false;
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  String version = "0.0";
  String buildNumber = "0";

  @override
  void initState() {
    super.initState();

    getInitalValue();
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

    getTokenValid(_token);
    getUserMoviesLitMyList(_token, profileID, "1");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppDefaultColors.appColor,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () async {
                  var result = await BarcodeScanner.scan();
                  if (result.type.toString() == "Barcode") {
                    setState(() {
                      var barCode = result.rawContent.toString();
                      setqrcode(_token, barCode);
                    });
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.qr_code_scanner_sharp, color: Colors.white),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  getBottomWidget();
                },
                child: Row(
                  children: const [
                    Icon(Icons.menu, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: isLoading == false
            ? LoaderOverlay(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100.0,
                          height: 100.0,
                          // color: Colors.green,
                          child: GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: AppDefaultColors.boxDarkGray,
                              // foregroundColor: Colors.green,
                              backgroundImage: NetworkImage(profilePicture),
                            ),
                          ),
                        ),
                        SizedBox(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(profileName, style: TextStyle(color: Colors.white, fontSize: 17)),
                            ),
                          ),
                        ),

                        Visibility(
                          visible: true,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DownloadMovieFiles()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.all(20),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppDefaultColors.helpBlue,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Image(
                                      image: AssetImage("images/download.png"),
                                      height: 30,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                    child: Text(
                                      "Downloads",
                                      style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.arrow_forward_ios_sharp, size: 30, color: AppDefaultColors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        // isLoading == false?
                        //MyList
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0, bottom: 2.0, left: 8.0, right: 8.0),
                            child: Text(
                              "My Lists",
                              style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: moviesMyListModel.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoApp(
                                                    getMovieID: moviesMyListModel[index].id.toString(),
                                                  )));
                                    },
                                    child: getMovieMyListWidget(moviesMyListModel[index]),
                                  );
                                }),
                          ),
                        ),

                        //Watching Movies
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0, bottom: 5.0, left: 8.0, right: 8.0),
                            child: Text(
                              "Continue Watching",
                              style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 230,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: moviesWatchingModel.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoApp(
                                                    getMovieID: moviesWatchingModel[index].id.toString(),
                                                  )));
                                    },
                                    child: getMovieContinueWatchingWidget(moviesWatchingModel[index]),
                                  );
                                }),
                          ),
                        ),

                        //Watched Movies
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0, bottom: 5.0, left: 8.0, right: 8.0),
                            child: Text(
                              "Recently Watched",
                              style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 230,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: moviesRecentlyModel.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoApp(
                                                    getMovieID: moviesRecentlyModel[index].id.toString(),
                                                  )));
                                    },
                                    child: getMovieWishListCategoryWidget(moviesRecentlyModel[index]),
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : LoadingWidget(),
      ),
    );
  }

  Future<void> viewDownloadMovies() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DownloadMovieFiles()));
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      _showPermissionRequestMessage();
    }
  }

  void _showPermissionRequestMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          'This app needs access to storage to function properly. Please grant the necessary permissions in the settings.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// If need use this
  ///Mylist,  WatchedMovie and Continueous watching
  ///all in same lits

  Widget getMovieMyListWidget(Movies moviesModel) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: <Widget>[
            MovieVerticalCardBackgroundView(
              Container(
                child: SizedBox(
                  height: 170,
                  width: 130,
                  child: FadeInImage(
                    placeholder: AssetImage("images/default_portrate_small.jpg"),
                    image: NetworkImage(moviesModel.portraitsmall.toString()),
                    imageErrorBuilder: (context, error, stackTrace) {
                      // Return the error image widget
                      return Image.asset('images/default_portrate_small.jpg', width: 130, fit: BoxFit.cover);
                    },
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  //   width: double.infinity,
                  //   height: double.infinity,
                  //   // 'images/sample_home_screen.jpg',
                  //   fit: BoxFit.cover,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget getMovieContinueWatchingWidget(Movies moviesModel) {
    print("CHeckWatchedPercent${moviesModel.usermovies!.watchedPercent}" == "null" ? "0" : moviesModel.usermovies!.watchedPercent.toString());
    return SizedBox(
      height: 210,
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Stack(children: <Widget>[
              MovieTopCardBackgroundView(
                Container(
                  child: SizedBox(
                      height: 150,
                      width: 140,
                      child: FadeInImage(
                        placeholder: AssetImage("images/default_portrate_small.jpg"),
                        image: NetworkImage(moviesModel.portraitsmall.toString()),
                        imageErrorBuilder: (context, error, stackTrace) {
                          // Return the error image widget
                          return Image.asset('images/default_portrate_small.jpg', width: 140, fit: BoxFit.cover);
                        },
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              Container(
                height: 100,
                margin: EdgeInsets.zero,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppDefaultColors.darkGray.withOpacity(0.5),
                        // color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(width: 2, color: Colors.white)),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.play_arrow, size: 30, color: AppDefaultColors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(
            // color: AppDefaultColors.thikRed,
            width: 130,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: LinearProgressIndicator(
                value: double.parse("0.${moviesModel.usermovies!.watchedPercent}"),
                // value: 0.5,
                color: AppDefaultColors.thikRed,
                backgroundColor: AppDefaultColors.textLightGray,
              ),
            ),
          ),
          MovieBottomCardBackgroundView(Container(
            color: AppDefaultColors.darkGray,
            width: 130,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      height: 100,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoApp(
                                          getMovieID: moviesModel.id.toString(),
                                        )));
                          },
                          child: Icon(Icons.info_outline, color: Colors.white)),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        getMovieDetailsBottomWidget(moviesModel, 1);
                      },
                      child: Icon(Icons.more_vert_sharp, color: Colors.white)),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget getMovieCategoryWidget(Movies moviesModel, String ctype) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: <Widget>[
            // moviesModel.catogoryID == "1"
            ctype == "3"
                ? MovieCardWishListBackgroundView(
                    Container(
                      child: SizedBox(
                          height: 170,
                          width: 230,
                          child: FadeInImage(
                            placeholder: AssetImage("images/default_portrate_small.jpg"),
                            image: NetworkImage(moviesModel.thumbnail.toString()),
                            imageErrorBuilder: (context, error, stackTrace) {
                              // Return the error image widget
                              return Image.asset('images/default_portrate_small.jpg');
                            },
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                          //   width: double.infinity,
                          //   height: double.infinity,
                          //   // 'images/sample_home_screen.jpg',
                          //   fit: BoxFit.cover,
                          ),
                    ),
                  )
                : MovieVerticalCardBackgroundView(
                    Container(
                      child: SizedBox(
                        height: 170,
                        width: 130,
                        child: FadeInImage(
                          placeholder: AssetImage("images/default_portrate_small.jpg"),
                          image: NetworkImage(moviesModel.thumbnail.toString()),
                          imageErrorBuilder: (context, error, stackTrace) {
                            // Return the error image widget
                            return Image.asset('images/default_portrate_small.jpg', width: 130, fit: BoxFit.cover);
                          },
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        //   width: double.infinity,
                        //   height: double.infinity,
                        //   // 'images/sample_home_screen.jpg',
                        //   fit: BoxFit.cover,
                      ),
                    ),
                  ),
            if (ctype == "2")
              Positioned(
                bottom: 4,
                child: SizedBox(
                  width: 234,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                      child: LinearProgressIndicator(
                        value: double.parse("40"),
                        color: AppDefaultColors.thikRed,
                        backgroundColor: AppDefaultColors.textLightGray,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 100,
              child: Align(
                alignment: Alignment.bottomCenter,
                // child: moviesModel.catogoryID == "2"
                child: ctype == "2"
                    ? Container(
                        width: 45,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(50.0), border: Border.all(color: Colors.white)),
                        child: Positioned.fill(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.play_arrow, size: 30, color: AppDefaultColors.white),
                            onPressed: () {},
                          ),
                        ),
                      )
                    : null,
              ),
            )
          ]),
        ],
      ),
    );
  }

  Widget getMovieWishListCategoryWidget(Movies moviesModel) {
    return Container(
      width: 240,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              MovieTopCardBackgroundView(
                Container(
                  child: SizedBox(
                      height: 130,
                      width: 230,
                      child: FadeInImage(
                        placeholder: AssetImage("images/default_landscape.jpg"),
                        image: NetworkImage(moviesModel.thumbnail.toString()),
                        imageErrorBuilder: (context, error, stackTrace) {
                          // Return the error image widget
                          return Image.asset('images/default_landscape.jpg', height: 130, fit: BoxFit.cover);
                        },
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )

                      //   width: double.infinity,
                      //   height: double.infinity,
                      //   // 'images/sample_home_screen.jpg',
                      //   fit: BoxFit.cover,
                      ),
                ),
              ),
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        height: 100,
                        child: GestureDetector(
                            onTap: () {
                              final encodedTitle = Uri.encodeComponent(moviesModel.title.toString());
                              Share.share('Watch ${moviesModel.title} on Bestcast OTT, \n\nCheck it out here: ${AppConfig.BaseUrl}/search?search=$encodedTitle');
                            },
                            child: Icon(Icons.share, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                            onTap: () {
                              getMovieDetailsBottomWidget(moviesModel, 2);
                            },
                            child: Icon(Icons.more_vert_sharp, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          MovieBottomCardBackgroundView(
            Container(
              color: AppDefaultColors.darkGray,
              width: 232,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 11),
                child: Center(
                  child: Text(
                    moviesModel.title.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBMPWebsite() async {
    final Uri url = Uri.parse('https://partners.bestcast.co/');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void getBottomWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDefaultColors.darkGray,
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
            Navigator.pop(context); // Close the bottom sheet after the animation completes
          },

          child: SingleChildScrollView(
            child: SizedBox(
              // height: 500,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Profile",
                              style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500),
                            ),
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
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // BMP Patner Start --------------------------------------------------
                    Visibility(
                      visible: loggedStatus,
                      child: InkWell(
                        onTap: _openBMPWebsite,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.handshake,
                                color: AppDefaultColors.white,
                                size: 25,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "BMP Refferal",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_sharp,
                                size: 18,
                                color: AppDefaultColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // BMP Patner End --------------------------------------------------
                    Visibility(
                      visible: loggedStatus ? true : false,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WhosWatchingPage(
                                        activityType: "Manage",
                                      )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.mode_edit_outline_outlined,
                                color: AppDefaultColors.white,
                                size: 25.0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                child: Text(
                                  "Manage Profile",
                                  style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.arrow_forward_ios_sharp, size: 20, color: AppDefaultColors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AppSettingsPage()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.settings,
                              color: AppDefaultColors.white,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                              child: Text(
                                "App Settings",
                                style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.arrow_forward_ios_sharp, size: 20, color: AppDefaultColors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: loggedStatus ? true : false,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BestcastWebView(url: "account")));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.person_outline_sharp,
                                color: AppDefaultColors.white,
                                size: 25.0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                child: Text(
                                  "Account",
                                  style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.arrow_forward_ios_sharp, size: 20, color: AppDefaultColors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BestcastWebView(url: "help")));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.question_mark_outlined,
                              color: AppDefaultColors.white,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                              child: Text(
                                "Help",
                                style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.arrow_forward_ios_sharp, size: 20, color: AppDefaultColors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: loggedStatus ? true : false,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return showSignOutAlertDialog();
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.output,
                                color: AppDefaultColors.white,
                                size: 25.0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                child: Text(
                                  "Sign Out",
                                  style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.arrow_forward_ios_sharp, size: 20, color: AppDefaultColors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                      child: Text(
                        "Version: $version build $buildNumber",
                        style: const TextStyle(color: AppDefaultColors.textLightGray, fontSize: 10.0, fontWeight: FontWeight.bold),
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

  void getMovieDetailsBottomWidget(Movies moviesModel, int type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDefaultColors.darkGray,
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
            Navigator.pop(context); // Close the bottom sheet after the animation completes
          },

          child: SingleChildScrollView(
            child: SizedBox(
              // height: 500,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              moviesModel.title.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500),
                            ),
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
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoApp(
                                      getMovieID: moviesModel.id.toString(),
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.info_outline,
                              color: AppDefaultColors.white,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                              child: Text(
                                "Details and More",
                                style: const TextStyle(color: Colors.white, fontSize: 17.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final encodedTitle = Uri.encodeComponent(moviesModel.title.toString());
                        Share.share('Watch ${moviesModel.title} on Bestcast OTT, \n\nCheck it out here: ${AppConfig.BaseUrl}/search?search=$encodedTitle');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.share_outlined,
                              color: AppDefaultColors.white,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                              child: Text(
                                "Share",
                                style: const TextStyle(color: Colors.white, fontSize: 17.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Map<String, int> postValues = {};
                        if (type == 1) {
                          postValues = {
                            'watching': 0,
                            'watch_time': 0,
                            'watched_percent': 0,
                          };
                        } else {
                          postValues = {
                            'watched': 0,
                          };
                        }

                        setUserMovies(_token, profileID, moviesModel.id.toString(), postValues, type);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color: AppDefaultColors.white,
                                size: 25.0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                child: Text(
                                  "Remove from row",
                                  style: const TextStyle(color: Colors.white, fontSize: 17.0),
                                ),
                              ),
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
        );
      },
    );
  }

  Widget showSignOutAlertDialog() {
    return AlertDialog(
      backgroundColor: AppDefaultColors.darkGray,
      title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 17)),
      content: Text("Singing out of the this app means you'll also sign out of all other Bestcast apps on this device.", style: TextStyle(color: Colors.white, fontSize: 15)),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () async {
            Navigator.pop(context);
            if (await CommonWidget().isInternetConnectivity()) {
              Fluttertoast.showToast(msg: "Loading...");
              getLogout(_token);
            } else {
              CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
            }
          },
        ),
      ],
    );
  }

  void setqrcode(String token, String qrcode) async {
    setState(() {
      context.loaderOverlay.show();
      isLoading = true;
    });
    final postValues = {'qrcode': qrcode};
    ApiServices().postRequestToken(AppConfig.setqrcode, postValues, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("setqrcode_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
            context.loaderOverlay.hide();
          });
          print('setQrCodeException:$e');
        }
      } else {
        setState(() {
          isLoading = false;
          context.loaderOverlay.hide();
        });
        print("setQrCodeError: $response");
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }
    });
    setState(() {
      isLoading = false;
      context.loaderOverlay.hide();
    });
  }

  void getUserMoviesLitMyList(String token, String profileId, String searchType) async {
    isLoading = true;
    moviesMyListModel.clear();
    ApiServices().getRequestData("${AppConfig.usermovieslist}$profileId&mylist=$searchType", token).then((response) async {
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
                movieId: movieData["usermovies"]["movieId"].toString(),
                mylist: movieData["usermovies"]["mylist"].toString(),
                likes: movieData["usermovies"]["likes"].toString(),
                watchTime: movieData["usermovies"]["watchTime"].toString(),
                watching: movieData["usermovies"]["watching"].toString(),
                watched: movieData["usermovies"]["watched"].toString(),
                watchedPercent: movieData["usermovies"]["watchedPercent"].toString(),
                viewed: movieData["usermovies"]["viewed"].toString(),
              );
            }

            String thumbnailUrl = "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
            String portraitsmallUrl = "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
            String portraitUrl = "${AppConfig.BaseUrl}/${movieData["portrait"]}";

            print("moviesMyListModel $thumbnailUrl");
            moviesMyListModel.add(Movies(
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

          setState(() {
            isLoading = false;
          });

          if (moviesMyListModel.isEmpty) {
            getUserMoviesLitMyList(_token, profileID, "");
          } else {
            getUserMoviesLitWatching(_token, profileID, "1");
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('MylistsMovieException:$e');
        }
      } else {
        print("MyListError: $response");
        isLoading = false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void getUserMoviesLitWatching(String token, String profileId, String searchType) async {
    isLoading = true;
    moviesWatchingModel.clear();
    ApiServices().getRequestData("${AppConfig.usermovieslist}$profileId&watching=$searchType", token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("MovieWatching_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObjectWch:$data");
          printWrapped(data.toString());

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
                watchTime: movieData["usermovies"]["watch_time"].toString(),
                watching: movieData["usermovies"]["watching"].toString(),
                watched: movieData["usermovies"]["watched"].toString(),
                watchedPercent: movieData["usermovies"]["watched_percent"].toString(),
                viewed: movieData["usermovies"]["viewed"].toString(),
              );
              print("usermoviesValues: ${movieData["usermovies"]["watched_percent"]}");
              print("Userwatch_time: ${movieData["usermovies"]["watch_time"]}");
            } else {
              usermovies = Usermovies(
                id: "0",
                movieId: "0",
                mylist: "0",
                likes: "0",
                watchTime: "0",
                watching: "0",
                watched: "0",
                watchedPercent: "0",
                viewed: "0",
              );
            }

            String thumbnailUrl = "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
            String portraitsmallUrl = "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
            String portraitUrl = "${AppConfig.BaseUrl}/${movieData["portrait"]}";

            print("moviesWatchingModel$thumbnailUrl");
            moviesWatchingModel.add(Movies(
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

          if (moviesWatchingModel.isEmpty) {
            getUserMoviesLitWatching(_token, profileID, "");
          } else {
            getUserMoviesLitRWatched(_token, profileID, "1");
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('CreateUserProfileException:$e');
        }
      } else {
        print("Error: $response");
        isLoading = false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void getUserMoviesLitRWatched(String token, String profileId, String searchType) async {
    isLoading = true;
    moviesRecentlyModel.clear();
    ApiServices().getRequestData("${AppConfig.usermovieslist}$profileId&watched=$searchType", token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("MovieWatched_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObject:$data");

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
                watchedPercent: movieData["usermovies"]["watchedPercent"].toString(),
                viewed: movieData["usermovies"]["viewed"].toString(),
              );
            }

            String thumbnailUrl = "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
            String portraitsmallUrl = "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
            String portraitUrl = "${AppConfig.BaseUrl}/${movieData["portrait"]}";

            print("moviesRecentlyModel$thumbnailUrl");

            moviesRecentlyModel.add(Movies(
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

          if (moviesRecentlyModel.isEmpty) {
            getUserMoviesLitRWatched(_token, profileID, "");
          }

          setState(() {
            isLoading = true;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('CreateUserProfileException:$e');
        }
      } else {
        print("Error: $response");
        isLoading = false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void setUserMovies(String token, String profileID, String movieID, Map<String, int> postValues, int type) async {
    appUtils.showLoaderDialog(context);
    ApiServices().postRequestToken("${AppConfig.setUserMovie}$movieID?profile_id=$profileID", postValues, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("setuserMovie_type: $type");
      print("setuserMovie_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          if (type == 1) {
            getUserMoviesLitWatching(_token, profileID, "1");
          } else {
            getUserMoviesLitRWatched(_token, profileID, "1");
          }
          appUtils.hideLoaderDialog(context);
          print('set user movie added');
        } catch (e) {
          appUtils.hideLoaderDialog(context);
          print('UserMovieResponseException:$e');
        }
      } else {
        appUtils.hideLoaderDialog(context);
        print("UserMovieResponseError: $response");
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
      print("getTokenExist_Token: $token");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "error") {
            final pref = await SharedPreferences.getInstance();
            pref.clear();

            setState(() {
              loggedStatus = false;
            });

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ).then((result) {
              // Check if the result is not null
              if (result != null) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
              }
            });
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

  void getLogout(String token) async {
    appUtils.showLoaderDialog(context);

    ApiServices().postRequestTokenWithoutBody(AppConfig.logoutUrl, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("logout_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            final pref = await SharedPreferences.getInstance();
            await pref.clear();

            await Future.delayed(Duration(seconds: 1));

            Navigator.of(context).pushNamedAndRemoveUntil(
              'mainscreen',
              (route) => false, // Removes all routes from the stack
            );
          }
        } catch (e) {
          appUtils.hideLoaderDialog(context);
          print('logoutException:$e');
        }
      } else {
        setState(() {
          appUtils.hideLoaderDialog(context);
        });
        print("logoutError: $response");
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }
    });
    appUtils.hideLoaderDialog(context);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches("LongWatchingPrint: $text").forEach((match) => print(match.group(0)));
  }
}
