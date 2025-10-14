// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/register/profile_icon_model.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';

class ProfileImageGrid extends StatefulWidget {
  const ProfileImageGrid({super.key});

  @override
  State<ProfileImageGrid> createState() => _ProfileImageGridState();
}

class _ProfileImageGridState extends State<ProfileImageGrid> {
  List<ProfileIconModel> profileIconModel = [];
  late bool editMode;
  bool profilMode = false;
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;

  final myUser = [
    "User 1",
    "User 2",
    "User 3",
    "User 4",
    "Add New",
  ];

  final myImageAndCaption = [
    "images/icon_user1.jpg",
    "images/icon_user2.jpg",
    "images/icon_user3.jpg",
    "images/icon_user4.jpg",
    "images/icon_add.png",
  ];

  String _id = "";
  String _token = "";

  @override
  void initState() {
    super.initState();

    getInitalValue();
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _id = pref.getString(AppPreferences.id) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';
    });

    if (await CommonWidget().isInternetConnectivity()) {
      context.loaderOverlay.show();
      getUserProfiles(_token);
    } else {
      CommonWidget().showSnackBar(
          context, ContentType.warning, "Check your internet connection.", "");
    }
  }

  void getUserProfileListsTemp() {
    for (int i = 0; i < myImageAndCaption.length; i++) {
      var enableAddUser = false;
      if (i == 4) {
        enableAddUser = true;
      } else {
        enableAddUser = false;
      }
      profileIconModel.add(ProfileIconModel(
        profilePictureID: myImageAndCaption[i],
        profilePictureTitle: myImageAndCaption[i],
        profilePicture: myImageAndCaption[i],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        title: Text("Update profile image",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
        backgroundColor: AppDefaultColors.appColor,
        leading: const BackButton(color: Colors.white),
      ),
      body: isLoading == false
          ? Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  itemCount: profileIconModel.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 0, // Spacing between columns
                    mainAxisSpacing: 0, // Spacing between rows
                  ),
                  itemBuilder: (context, index) {
                    return MyGridItem(
                      profileIconModel: profileIconModel[index],
                      onTap: () {
                        var selectedPic =
                            profileIconModel[index].profilePicture.toString();
                        var selectedPicID =
                            profileIconModel[index].profilePictureID.toString();

                        Navigator.pop(context, profileIconModel[index]);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
                      },
                    );
                  },
                ),
              ),
            )
          : LoadingWidget(),
    );
  }

  void getUserProfiles(String token) async {
    isLoading = true;
    context.loaderOverlay.show();
    ApiServices()
        .getRequestData(AppConfig.profileIconList, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("profileIcon_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("DataObject:$data");

          var responseData = json.decode(response.body);

          for (var profileUser in responseData["data"]) {
            String profilePicUrl =
                "${AppConfig.BaseUrl}/${profileUser["thumbnail"]}";

            profileIconModel.add(ProfileIconModel(
              profilePictureID: profileUser["id"].toString(),
              profilePictureTitle: profileUser["title"].toString(),
              profilePicture: profilePicUrl,
            ));
          }

          setState(() {
            if (data.length < 5) {
              profileIconModel.add(ProfileIconModel(
                profilePictureID: "",
                profilePictureTitle: "",
                profilePicture: "images/icon_add.png",
              ));
            }
          });

          isLoading = false;
          context.loaderOverlay.hide();
        } catch (e) {
          print('ProfileIconException:$e');
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      isLoading = false;
      context.loaderOverlay.hide();
    });
  }

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
    // context.loaderOverlay.hide();
  }
}

class MyGridItem extends StatelessWidget {
  final ProfileIconModel profileIconModel;
  final VoidCallback onTap;

  const MyGridItem(
      {super.key, required this.profileIconModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(children: <Widget>[
          SizedBox(
            width: 100.0,
            height: 100.0,
            // color: Colors.green,
            child: GestureDetector(
              onTap: onTap,
              child: CircleAvatar(
                backgroundColor: AppDefaultColors.boxDarkGray,
                // foregroundColor: Colors.green,
                // backgroundImage: AssetImage('images/loading.gif'),
                backgroundImage: AssetImage('images/default_profile.jpg'),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      NetworkImage(profileIconModel.profilePicture.toString()),
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }
}
