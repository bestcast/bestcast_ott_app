import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/authendication/plan_expired_creen.dart';
import 'package:bestcaststudios/register/add_userpage.dart';
import 'package:bestcaststudios/register/who_watching_model.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/device_signout_alert_screen.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';

// ignore: must_be_immutable
class WhosWatchingPage extends StatefulWidget {
  String activityType = "";

  WhosWatchingPage({super.key, required this.activityType});

  @override
  State<WhosWatchingPage> createState() => _WhosWatchingPageState();
}

class _WhosWatchingPageState extends State<WhosWatchingPage> {
  List<WhoWatchingModel> whoWatchingModel = [];
  late bool editMode;

  bool profilMode = false;
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;
  bool isLoaderDialog = false;

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

  String _email = "";
  String _token = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getInitalValue();

    if (widget.activityType == "New") {
      editMode = false;
    } else {
      editMode = true;
    }

    print("EditModeStatus: $editMode");
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _email = pref.getString(AppPreferences.email) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';
    });

    if (await CommonWidget().isInternetConnectivity()) {
      print("whowa_token: $_token");
      getUserProfiles(_token);
    } else {
      CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
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
      whoWatchingModel.add(WhoWatchingModel(
        profileID: i.toString(),
        profileName: myUser[i],
        profilePictureID: myImageAndCaption[i],
        profilePictureTitle: myImageAndCaption[i],
        profilePicture: myImageAndCaption[i],
        lastLogin: "",
        language: 0,
        isChild: 0,
        isHavePin: 0,
        editable: false,
        enableAddUser: enableAddUser,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        title: Text(widget.activityType == "New" ? "Who's Watching" : "Manage Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: AppDefaultColors.appColor,
        leading: widget.activityType != "New" ? const BackButton(color: Colors.white) : null,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (editMode) {
                    for (int v = 0; v < whoWatchingModel.length; v++) {
                      whoWatchingModel[v].editable = false;
                    }
                    editMode = false;
                  } else {
                    for (int v = 0; v < whoWatchingModel.length; v++) {
                      whoWatchingModel[v].editable = true;
                    }
                    editMode = true;
                  }
                });
              },
              child: Row(
                children: [
                  Icon(editMode ? Icons.close : Icons.mode_edit_outline_outlined, color: Colors.white),
                  SizedBox(
                    // sized box with width 10
                    width: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: isLoading == false
          ? LoaderOverlay(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  itemCount: whoWatchingModel.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 0, // Spacing between columns
                    mainAxisSpacing: 0, // Spacing between rows
                  ),
                  itemBuilder: (context, index) {
                    return MyGridItem(
                      whoWatchingModel: whoWatchingModel[index],
                      onTap: () async {
                        if (widget.activityType == "New") {
                          _awaitProfile(context, whoWatchingModel[index]);
                        } else {
                          if (whoWatchingModel[index].editable == true && whoWatchingModel[index].enableAddUser == false) {
                            _awaitEditProfile(context, whoWatchingModel[index]);
                          } else {
                            _awaitProfile(context, whoWatchingModel[index]);
                          }
                        }
                      },
                    );
                  },
                ),

                //   shrinkWrap: true,
                //   mainAxisSpacing: 5,
                //   crossAxisSpacing: 1,
                //   crossAxisCount: 2,
                //   childAspectRatio: 2/2,
                //         mainAxisSize: MainAxisSize.min,
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //             width: 100.0,
                //             height: 100.0,
                //             // color: Colors.green,
                //               backgroundColor: AppDefaultColors.boxDarkGray,
                //               // foregroundColor: Colors.green,
                //               fit: BoxFit.fitWidth,
                //                 child: Text(i.last,
              ),
            )
          : LoadingWidget(),
    );
  }

  void getUserProfiles(String token) async {
    isLoading = true;
    context.loaderOverlay.show();
    whoWatchingModel.clear();
    ApiServices().getRequestData(AppConfig.userProfileList, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("getUserprofile_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("ProfileDataObject:$data");

          var responseData = json.decode(response.body);

          for (var profileUser in responseData["data"]) {
            print("ProfileID:${profileUser["id"]}");

            String profilePicUrl = "${AppConfig.BaseUrl}/${profileUser["profileicon"]["thumbnail"]}";

            bool? editModeStatus;
            if (editMode) {
              editModeStatus = true;
            } else {
              editModeStatus = false;
            }
            whoWatchingModel.add(WhoWatchingModel(
              profileID: profileUser["id"].toString(),
              profileName: profileUser["name"].toString(),
              profilePictureID: profileUser["profileicon"]["id"].toString(),
              profilePictureTitle: profileUser["profileicon"]["title"].toString(),
              profilePicture: profilePicUrl,
              lastLogin: profileUser["last_login"].toString(),
              language: profileUser["language"].toInt(),
              isChild: profileUser["is_child"].toInt(),
              isHavePin: profileUser["is_have_pin"].toInt(),
              editable: editModeStatus,
              enableAddUser: false,
            ));
          }

          setState(() {
            if (data.length < 5) {
              whoWatchingModel.add(WhoWatchingModel(
                profileID: "",
                profileName: "Add User",
                profilePictureID: "",
                profilePictureTitle: "",
                profilePicture: "images/icon_add.png",
                lastLogin: "",
                language: 0,
                isChild: 0,
                isHavePin: 0,
                editable: false,
                enableAddUser: true,
              ));
            }
          });

          isLoading = false;
          context.loaderOverlay.hide();
        } catch (e) {
          print('CreateUserProfileException:$e');

          final pref = await SharedPreferences.getInstance();
          await pref.clear();

          await Future.delayed(Duration(seconds: 3));
          isLoading = false;
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }
      isLoading = false;
      context.loaderOverlay.hide();
    });

    context.loaderOverlay.hide();
  }

  void getUserDetails(String token, WhoWatchingModel whoWatchingModel) async {
    setState(() {
      isLoading = true;
    });
    ApiServices().postRequestTokenWithoutBody(AppConfig.getUserDetails, token).then((response) async {
      String jsonsDataString = response.body.toString();
      print("getUserDetails_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            String? planStatus = jsonReponse['results']['user']['plan_status'].toString();
            String? planDeviceStatus = jsonReponse['results']['user']['plan_device_status'].toString();

            if (planStatus == "0") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlanExpiredScreen()));
            } else if (planDeviceStatus == "0") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeviceSignOutAlertScreen(
                            email: _email,
                          )));
            } else {
              _awaitProfile(context, whoWatchingModel);
            }

            //TOD0 hide
          }
          isLoading = false;
        } catch (e) {
          isLoading = false;
          print('getUserDetailsException:$e');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("geUserError: $response");
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }

      isLoading = false;
    });
    isLoading = false;
  }

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
    context.loaderOverlay.hide();
  }

  Future<void> _awaitProfile(BuildContext context, whoWatchingModel) async {
    if (whoWatchingModel.enableAddUser == true) {
      final value = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserPage(pageType: 'New', userData: whoWatchingModel)));
      print("Profilestatus$value");
      if (value != null) {
        getUserProfiles(_token);
      }
    } else if (whoWatchingModel.editable == true) {
      final value = Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserPage(pageType: 'Edit', userData: whoWatchingModel)));

      print("ProfileEditStatus$value");
      getUserProfiles(_token);
    } else {
      print("ProfileStatus: true");
      var userProfileData = whoWatchingModel;
      print("userProfileID: " + userProfileData.profileID!);

      final pref = await SharedPreferences.getInstance();
      await pref.setString(AppPreferences.profileID, userProfileData.profileID!);
      await pref.setString(AppPreferences.profileName, userProfileData.profileName!);
      await pref.setString(AppPreferences.profilePictureID, userProfileData.profilePictureID!);
      await pref.setString(AppPreferences.profilePictureTitle, userProfileData.profilePictureTitle!);
      await pref.setString(AppPreferences.profilePicture, userProfileData.profilePicture!);
      await pref.setString(AppPreferences.isChild, userProfileData.isChild!.toString());
      Navigator.of(context).pushNamedAndRemoveUntil(
        'mainscreen',
        (route) => false, // Removes all routes from the stack
      );
    }
  }

  Future<void> _awaitEditProfile(BuildContext context, whoWatchingModel) async {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => AddUserPage(pageType: 'Edit', userData: whoWatchingModel)),
        )
        .then((val) => val == "success" ? getUserProfiles(_token) : null);
  }
}

class MyGridItem extends StatelessWidget {
  final WhoWatchingModel whoWatchingModel;
  final VoidCallback onTap;

  const MyGridItem({super.key, required this.whoWatchingModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
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
                child: whoWatchingModel.enableAddUser == false
                    ? CircleAvatar(
                        backgroundColor: AppDefaultColors.boxDarkGray,
                        // foregroundColor: Colors.green,
                        backgroundImage: AssetImage('images/default_profile.jpg'),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(whoWatchingModel.profilePicture.toString()),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: AppDefaultColors.boxDarkGray,
                        // foregroundColor: Colors.green,
                        backgroundImage: AssetImage("images/icon_add.png"),
                      ),
              ),
            ),
            if ((whoWatchingModel.editable == true) && (whoWatchingModel.enableAddUser == false) && whoWatchingModel.profileName != "Add New")
              SizedBox(
                height: 100,
                width: 100,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppDefaultColors.darkGray.withOpacity(0.6)),
                    foregroundColor: WidgetStateProperty.all(Colors.transparent),
                    padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
                    textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100), // BorderRadius
                      ),
                    ),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.mode_edit_outline_outlined,
                        color: AppDefaultColors.white,
                        size: 40.0,
                      ),
                    ],
                  ),
                ),
              ),
          ]),
          SizedBox(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(whoWatchingModel.profileName.toString(), style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
