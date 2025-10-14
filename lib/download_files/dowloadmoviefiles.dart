// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/download_files/download_movie_model.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/loading_widget.dart';
import '../common_files/movie_categories_card_wishlist.dart';
import '../database_helper/DatabaseHelper.dart';
import '../main_screen.dart';
import '../streamingpalyer/video_view_player.dart';

class DownloadMovieFiles extends StatefulWidget {
  const DownloadMovieFiles({super.key});

  @override
  State<DownloadMovieFiles> createState() => _DownloadMovieFilesState();
}

class _DownloadMovieFilesState extends State<DownloadMovieFiles> {
  bool isLoading = false;
  List<DownloadedMovieModel> downloadedMovieModel = [];
  final dbHelper = DatabaseHelper();
  final AppUtils appUtils = AppUtils();

  final String _downloadUrl = "";
  final String _loadTrailerUrl = "";
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

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

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
      // movieID = pref.getString(AppPreferences.profilePictureID) ?? '';
    });

    getDownloadMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
          backgroundColor: AppDefaultColors.appColor,
          appBar: AppBar(
            title: Text(
              "Download Movies",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppDefaultColors.appColor,
            leading: const BackButton(color: Colors.white),
          ),
          body: isLoading == false
              ? downloadedMovieModel.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            height: 200,
                            width: 220,
                            'images/default_download.png',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.only(top: 30.0, right: 5.0),
                            child: Center(
                              child: const Text(
                                'We will download movies just for you,\nso you will always have something to watch',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppDefaultColors.textLightGray,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 20, left: 10, right: 10, bottom: 30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size.fromHeight(50),
                                foregroundColor: AppDefaultColors.appRed,
                                backgroundColor: AppDefaultColors.appRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  // borders: Border.all(width: 1, color: Colors.grey),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen()));
                              },
                              child: Text(
                                'Find More to Download',
                                style: TextStyle(
                                    color: AppDefaultColors.textLightGray,
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: downloadedMovieModel.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  String movieLocalPath =
                                      downloadedMovieModel[index]
                                          .movieName
                                          .toString();

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MovieVideoViewer(
                                                getMainMovieUrl: movieLocalPath,
                                                getMainMovieID: '',
                                                getWatchTime: '0',
                                                playType: 2,
                                                movieTitle:
                                                    downloadedMovieModel[index]
                                                        .movieName
                                                        .toString(),
                                                thumbnail:
                                                    downloadedMovieModel[index]
                                                        .thumnail
                                                        .toString(),
                                              )));
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             ChewieVideoScreen(
                                  //               // getMainMovie
                                  //               //
                                  //               // Url: moviesDownloadedModel!.moviePath.toString(),
                                  //               getMainMovieUrl: movieLocalPath,
                                  //               getMainMovieID: '',
                                  //               getWatchTime:'0',
                                  //               playType: 2,
                                  //             )));
                                },
                                child: getDownloadedWidget(
                                    downloadedMovieModel[index]),
                              );
                            }),
                      ],
                    ))
              : LoadingWidget()),
    );
  }

  Widget getDownloadedWidget(DownloadedMovieModel moviesDownloadedModel) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              MovieCardWishListBackgroundView(
                Container(
                  child: SizedBox(
                      height: 100,
                      width: 140,
                      child: FadeInImage(
                        placeholder: AssetImage("images/default_landscape.jpg"),
                        image: NetworkImage(
                            moviesDownloadedModel.thumnail.toString()),
                        imageErrorBuilder: (context, error, stackTrace) {
                          // Return the error image widget
                          return Image.asset('images/default_landscape.jpg');
                        },
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                      // Image.network(
                      //   width: double.infinity,
                      //   height: double.infinity,
                      //   moviesDownloadedModel.thumnail.toString(),
                      //   fit: BoxFit.cover,
                      // ),
                      ),
                ),
              ),
              Container(
                width: 45,
                height: 45,
                margin: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(color: Colors.white)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.play_arrow,
                      size: 30, color: AppDefaultColors.white),
                  onPressed: () async {
                    String movieLocalPath =
                        moviesDownloadedModel.movieName.toString();

                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             ChewieVideoScreen(
                    //               // getMainMovieUrl: moviesDownloadedModel!.moviePath.toString(),
                    //               getMainMovieUrl: movieLocalPath,
                    //               getMainMovieID: '',
                    //               getWatchTime:'0',
                    //               playType: 2,
                    //             )));

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MovieVideoViewer(
                                  getMainMovieUrl: movieLocalPath,
                                  getMainMovieID: '',
                                  getWatchTime: '0',
                                  playType: 2,
                                  movieTitle: moviesDownloadedModel.movieName
                                      .toString(),
                                  thumbnail:
                                      moviesDownloadedModel.thumnail.toString(),
                                )));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 5.0),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
              child: Text(
                moviesDownloadedModel.movieName.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            width: 45,
            height: 45,
            margin: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: _isDeleting
                ? LoadingWidget()
                : IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.delete_forever,
                        size: 30, color: AppDefaultColors.white),
                    onPressed: () async {
                      String movieID = moviesDownloadedModel.movieID.toString();

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return showDeleteMovieAlertDialog(movieID);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> getDownloadMovieDetails() async {
    downloadedMovieModel.clear();
    setState(() {
      isLoading == true;
    });
    var dbData = await dbHelper.getData();
    print('dbMovieData: $dbData');

    final data = await dbHelper.getItems();
    print('dataMovieDb: ${data[0].movieTitle}');

    for (var element in data) {
      downloadedMovieModel.add(DownloadedMovieModel(
        movieID: element.movieID.toString(),
        title: element.movieTitle.toString(),
        description: "",
        movieName: element.movieTitle.toString(),
        thumnail: element.movieThumnail.toString(),
        moviePath: element.movieUrl.toString(),
      ));

      // Access the elements and perform operations
      int? id = element.id?.toInt();
      String name = element.movieTitle.toString();
      print('ID: $id, Name: $name');
    }

    setState(() {
      isLoading == false;
    });
  }

  Widget showDeleteMovieAlertDialog(String movieID) {
    return AlertDialog(
      backgroundColor: AppDefaultColors.darkGray,
      title: const Text('Delete movie',
          style: TextStyle(color: Colors.white, fontSize: 17)),
      content: Text("Are you sure want to delete movie?",
          style: TextStyle(color: Colors.white, fontSize: 15)),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Delete',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () async {
            Navigator.pop(context);
            var movieName = await dbHelper.getMovieTitle(movieID);
            deleteFile(movieName, movieID);
          },
        ),
      ],
    );
  }

  Future<void> deleteFile(String movieName, String movieID) async {
    setState(() {
      _isDeleting = true;
    });
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String videoPath = '${appDocDir.path}/$movieName.mp4';

      if (await File(videoPath).exists()) {
        //Delete file from directory
        print('path $videoPath');
        File videoFile = File(videoPath);
        await videoFile.delete();
        print('File deleted');
      } else {
        // File does not exist
        print('File not found');
      }

      //Delete file from db
      var movieId = int.parse(movieID);
      print("Delete_movieId : {$movieId}");
      var dbData = await dbHelper.deleteData(movieId);
      print('dbMovieData: $dbData');

      getDownloadMovieDetails();

      setState(() {
        _isDeleting = false;
      });
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
