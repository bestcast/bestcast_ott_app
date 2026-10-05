import 'package:flutter/material.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/register/profile_icon_model.dart';
import 'package:bestcaststudios/register/who_watching_model.dart';
import '../Dashboard/MovieCategories.dart';
import '../Dashboard/MoviesModels.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/submitButton.dart';

// ignore: must_be_immutable
class AddUserPage extends StatefulWidget {
  String pageType = "";
  WhoWatchingModel userData;
  List<WhoWatchingModel> whoWatchingModel = [];

  AddUserPage({super.key, required this.pageType, required this.userData});

  @override
  State<AddUserPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<AddUserPage> {
  List<MoviesCategoryModel> moviesCategoryModel = [];
  final AppUtils appUtils = AppUtils();

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
  var categoryItems = ["My List", "Continue Watching", "Recently Watched"];
  var allCategoryItems = [
    "Wish List",
    "Tamil",
    "Telungu",
    "English",
    "Hindi",
    "Comedies",
    "Action",
    "Adventures"
  ];

  TextEditingController userNameController = TextEditingController();
  bool _isUserNameValid = false;

  bool isSwitched = false;
  var textValue = 'Switch is OFF';
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void getMoviesListsTemp() {
    for (int i = 0; i < 3; i++) {
      List<MoviesModel> moviesModel = [];
      var j = 0;
      var catID = i + 1;
      for (int K = 0; K < 11; K++) {
        if (K == 6) {
          j = 0;
        }

        if (i == 2) {
          moviesModel.add(MoviesModel(
              catogoryID: catID.toString(),
              movieID: "3",
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
      }
      moviesCategoryModel.add(MoviesCategoryModel(
          catogoryID: catID.toString(),
          catogoryName: categoryItems[i],
          moviesModel: moviesModel));
    }
  }

  String pageTitle = "";
  String buttonText = "";
  String getSelectedIconID = "";
  String getSelectedIcon = "";
  bool isIconSelected = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.pageType == "New") {
      pageTitle = "Create User";
      buttonText = "Add User";
    } else {
      pageTitle = "Manage Profile";
      buttonText = "Update User";
      _isUserNameValid = true;


      profileName = widget.userData.profileName.toString();
      profilePicture = widget.userData.profilePicture.toString();
      profileID = widget.userData.profileID.toString();
      profilePictureID = widget.userData.profilePictureID.toString();

      print('profileiconNid$profileID');

      userNameController.text = profileName;
      if (widget.userData.isChild == 1) {
        setState(() {
          isSwitched = true;
        });
      }
    }

    getMoviesListsTemp();
    getInitalValue();
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          title: Text(
            pageTitle,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppDefaultColors.appColor,
          leading: const BackButton(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formkey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: 100.0,
                    height: 100.0,
                    // color: Colors.green,
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: widget.pageType == "Edit"
                          ? CircleAvatar(
                              backgroundColor: AppDefaultColors.boxDarkGray,
                              // foregroundColor: Colors.green,
                              backgroundImage:
                                  AssetImage('images/icon_user1.jpg'),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(isIconSelected
                                    ? getSelectedIcon
                                    : widget.userData.profilePicture
                                        .toString()),
                              ),
                            )
                          : isIconSelected == false
                              ? CircleAvatar(
                                  backgroundColor: AppDefaultColors.boxDarkGray,
                                  // foregroundColor: Colors.green,
                                  backgroundImage:
                                      AssetImage("images/icon_user1.jpg"),
                                )
                              : CircleAvatar(
                                  backgroundColor: AppDefaultColors.boxDarkGray,
                                  // foregroundColor: Colors.green,
                                  backgroundImage:
                                      NetworkImage(getSelectedIcon),
                                ),
                    ),
                  ),
                  SizedBox(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () {
                              _awaitReturnPictureFromIconScreen(context);
                            },
                            child: Text("Change Image",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppDefaultColors.boxDarkGray,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                        child: TextFormField(
                          cursorColor: AppDefaultColors.white,
                          style: TextStyle(color: Colors.white),
                          controller: userNameController,
                          validator: (txt) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                if (txt?.length != 0) {
                                  _isUserNameValid = true;
                                } else {
                                  _isUserNameValid = false;
                                  _errorMessage = "";
                                }
                              });
                            });
                            return null;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Enter name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Kid's profile?",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            splashRadius: 50.0,
                            onChanged: (val) {
                              setState(() {
                                isSwitched = val;
                              });
                            },
                            value: isSwitched,
                            // activeColor: AppDefaultColors.textLightGray,
                            // activeTrackColor: Colors.blue,
                            // inactiveThumbColor: AppDefaultColors.textLightGray,
                            // inactiveTrackColor: Colors.grey,
                          ),
                        ),
                        //   onChanged: toggleSwitch,
                        //   value: isSwitched,
                        //   activeColor: Colors.blue,
                        //   activeTrackColor: Colors.yellow,
                        //   inactiveThumbColor: Colors.redAccent,
                        //   inactiveTrackColor: Colors.grey,
                      ],
                    ),
                  ),
                  if (widget.pageType == "Edit")
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showDeleteUserAlertDialog();
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        color: AppDefaultColors.hardDarkGray,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: AppDefaultColors.white,
                                size: 25.0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Delete Profile User",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.arrow_forward_ios_sharp,
                                  size: 20, color: AppDefaultColors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(right: 5.0),
                      child: SubmitButtonDesign(
                        buttonText,
                        _isUserNameValid,
                        onTap: () async {
                          String profileName = userNameController.text;

                          if (formkey.currentState!.validate()) {
                            if (profileName.length < 4) {
                              setState(() {
                                _errorMessage =
                                    "Profile name must be 4 or above letters.";
                              });
                            } else {
                              setState(() {
                                _errorMessage = null;
                              });

                              var isKidEnabled = "0";
                              if (isSwitched) {
                                isKidEnabled = "1";
                              } else {
                                isKidEnabled = "0";
                              }
                              if (widget.pageType == "New") {
                                addUserProfile(
                                    _token,
                                    "0",
                                    getSelectedIconID == ""
                                        ? profilePictureID
                                        : getSelectedIconID,
                                    profileName,
                                    "0",
                                    "0",
                                    isKidEnabled,
                                    "0");
                              } else {
                                addUserProfile(
                                    _token,
                                    profileID,
                                    getSelectedIconID == ""
                                        ? profilePictureID
                                        : getSelectedIconID,
                                    profileName,
                                    "0",
                                    "0",
                                    isKidEnabled,
                                    "0");
                              }
                            }
                          } else {
                            setState(() {
                              _errorMessage = "Enter a valid name";
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  void addUserProfile(
      String token,
      String userID,
      String profileID,
      String name,
      String language,
      String autoplay,
      String isChild,
      String pin) async {
    print('profileicon_id$profileID');

    appUtils.showLoaderDialog(context);
    final postValues = {
      'profileicon_id': profileID,
      'name': name,
      'language': language,
      'autoplay': autoplay,
      'is_child': isChild,
      'pin': pin,
      'appnotify': "1"
    };

    ApiServices()
        .postRequestToken(AppConfig.setUserProfile + userID, postValues, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("setuserprofile_Response: $jsonsDataString");
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (mounted) {
            Navigator.of(context).pop('success');
          }
        } catch (e) {
          print('CreateUserProfileException:$e');
        }
      } else {
        if (mounted) {
          CommonWidget().showSnackBar(
              context, ContentType.failure, "Error", "Failed to save profile.");
        }
      }
    }).catchError((e) {
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
    });
  }

  void deleteUserProfile(
      String token,
      String userID,
      String profileID,
      String name,
      String language,
      String autoplay,
      String isChild,
      String pin) async {
    appUtils.showLoaderDialog(context);
    final postValues = {
      'profileicon_id': profileID,
      'name': name,
      'language': language,
      'autoplay': autoplay,
      'is_child': isChild,
      'pin': pin,
    };

    ApiServices()
        .postRequestToken(
            AppConfig.deleteUserProfile + userID, postValues, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("DeleteUserprofile_Response: $jsonsDataString");
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
      if (response.statusCode == 200) {
        try {
          // If deleted profile was currently active in SharedPreferences, clear active profile
          final pref = await SharedPreferences.getInstance();
          String activeID = pref.getString(AppPreferences.profileID) ?? "";
          if (activeID == userID) {
            await pref.remove(AppPreferences.profileID);
            await pref.remove(AppPreferences.profileName);
            await pref.remove(AppPreferences.profilePicture);
            await pref.remove(AppPreferences.profilePictureID);
            await pref.remove(AppPreferences.profilePictureTitle);
          }

          appUtils.showToast("Profile removed successfully.");
          if (mounted) {
            Navigator.of(context).pop('success');
          }
        } catch (e) {
          print('DeleteUserProfileException:$e');
          if (mounted) {
            Navigator.of(context).pop('success');
          }
        }
      } else {
        if (mounted) {
          CommonWidget().showSnackBar(
              context, ContentType.failure, "Error", "Could not remove profile. Please try again.");
        }
      }
    }).catchError((e) {
      if (mounted) {
        appUtils.hideLoaderDialog(context);
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", "Network error occurred.");
      }
    });
  }

  void _awaitReturnPictureFromIconScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result

    Navigator.of(context).pushNamed('profile_image_grid').then((value) {
      if (value != null && value is ProfileIconModel) {
        setState(() {
          getSelectedIconID = value.profilePictureID.toString();
          getSelectedIcon = value.profilePicture.toString();
          print("ValuePrint$getSelectedIcon");
          print("ValuePrintID$getSelectedIconID");
          isIconSelected = true;
        });
      }
    });
  }

  Widget showDeleteUserAlertDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Profile',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        "Are you sure you want to permanently remove this profile?",
        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppDefaultColors.primaryRed,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            Navigator.pop(context); // Close the dialog first!
            if (await CommonWidget().isInternetConnectivity()) {
              deleteUserProfile(
                  _token,
                  profileID,
                  getSelectedIconID == ""
                      ? profilePictureID
                      : getSelectedIconID,
                  profileName,
                  "0",
                  "0",
                  "0",
                  "0");
            } else {
              appUtils.showToast("Check your internet connection.");
            }
          },
        ),
      ],
    );
  }
}
