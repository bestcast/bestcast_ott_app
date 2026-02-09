import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/common_files/loading_widget.dart';
import 'package:bestcaststudios/notification_activity/notificaiton_main_model.dart';
import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/movie_categories_card_wishlist.dart';
import '../streamingpalyer/video_player.dart';
import 'notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notificationModel = [];

  List<NoficationMainModel> moviesMainCategoryModelList = [];

  bool isLoading = true;
  bool loggedStatus = false;
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";


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

    getNotificationMoviesLits(_token, profileID);
  }

  var thumnailWishPic = [
    "images/sample_wish_list1.jpg",
    "images/sample_wish_list2.jpg",
    "images/sample_wish_list3.jpg",
    "images/sample_wish_list4.jpg",
    "images/sample_wish_list5.jpg",
    "images/sample_wish_list6.jpg"
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

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
          backgroundColor: AppDefaultColors.appColor,
          appBar: AppBar(
            title: const Text(
              "Notification",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppDefaultColors.appColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                  },
                  child: Row(
                    children: const [
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: isLoading == false
              ? notificationModel.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            height: 100,
                            width: 100,
                            'images/notification_icon.png',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.only(top: 10.0, right: 5.0),
                            child: Center(
                              child: const Text(
                                'Notification is empty',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppDefaultColors.textLightGray,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: notificationModel.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    //     context,

                                    String movieID = notificationModel[index]
                                        .movieID
                                        .toString();
                                    print("NotificationMovieID$movieID");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VideoApp(getMovieID: movieID)));
                                  },
                                  child:
                                      getUsersWidget(notificationModel[index]),
                                );
                              }),
                        ],
                      ),
                    )
              : LoadingWidget()),
    );
  }

  Widget getUsersWidget(NotificationModel notificationModel) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieCardWishListBackgroundView(
                  Container(
                    child: SizedBox(
                      height: 100,
                      width: 140,
                      child: FadeInImage(
                        placeholder: AssetImage("images/default_landscape.jpg"),
                        image:
                            NetworkImage(notificationModel.thumnail.toString()),
                        imageErrorBuilder: (context, error, stackTrace) {
                          // Return the error image widget
                          return Image.asset('images/default_landscape.jpg',
                              height: 100, fit: BoxFit.cover);
                        },
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      //   width: double.infinity,
                      //   height: double.infinity,
                      //   fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10),
                                    child: Text(
                                      notificationModel.title.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 15.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 10),
                                    child: Text(
                                      notificationModel.movieName.toString(),
                                      style: const TextStyle(
                                          color: AppDefaultColors.textLightGray,
                                          fontSize: 14.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 10),
                                    child: Text(
                                      notificationModel.notificationDate
                                          .toString(),
                                      style: const TextStyle(
                                          color: AppDefaultColors.textLightGray,
                                          fontSize: 14.0),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getNotificationMoviesLits(String token, String profileId) async {
    isLoading = true;
    var url = "";
    if (loggedStatus) {
      url = "${AppConfig.appnotifylistuser}/$profileId";
    } else {
      url = "${AppConfig.appnotifylist}/0";
    }

    ApiServices().getRequestData(url, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("Notification_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObject:$data");

          var responseData = json.decode(response.body);

          for (var mainData in responseData["data"]) {
            print("ProfileID:${mainData["id"]}");
            print("MovieTitle${mainData['title']}");

            String nthumbnailUrl =
                "${AppConfig.BaseUrl}/${mainData["movie"]["thumbnail"]}";
            print("nthumbnailUrl$nthumbnailUrl");

            //   movie: movieList,

            notificationModel.add(NotificationModel(
              notificationID: mainData["id"].toString(),
              movieID: mainData["movie"]["id"].toString(),
              title: mainData["title"].toString(),
              description: "Notification Description",
              movieName: mainData["movie"]["title"].toString(),
              thumnail: nthumbnailUrl,
              notificationDate: mainData["created_at"].toString(),
            ));

            print("checkStatus: mainMovie${mainData["movie"]["ids"]}");
          }

          await Future.delayed(Duration(seconds: 1));
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          isLoading = false;
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
}
