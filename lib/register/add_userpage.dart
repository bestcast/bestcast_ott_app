// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
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

      // print("UserData:"+widget.userData.toString());
      // var jsonReponse = jsonDecode(widget.userData);
      // var data = jsonReponse['data'];
      // isChild: profileUser["is_child"].toInt();

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
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
                      },
                      child: widget.pageType == "Edit"
                          ? CircleAvatar(
                              backgroundColor: AppDefaultColors.boxDarkGray,
                              // foregroundColor: Colors.green,
                              // backgroundImage: AssetImage('images/loading.gif'),
                              backgroundImage:
                                  AssetImage('images/icon_user1.jpg'),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(isIconSelected
                                    ? getSelectedIcon
                                    : widget.userData.profilePicture
                                        .toString()),
                                // backgroundImage: NetworkImage("https://moviesdev.harikaran.com/img/sample/profile-1.jpg"),
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
                        // Switch(
                        //   onChanged: toggleSwitch,
                        //   value: isSwitched,
                        //   activeColor: Colors.blue,
                        //   activeTrackColor: Colors.yellow,
                        //   inactiveThumbColor: Colors.redAccent,
                        //   inactiveTrackColor: Colors.grey,
                        // ),
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
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
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

    context.loaderOverlay.show();
    final postValues = {
      'profileicon_id': profileID,
      'name': name,
      'language': language,
      'autoplay': autoplay,
      'is_child': isChild,
      'pin': pin,
      'appnotify': "1"
    };

    // final postValues = {
    //   'profileicon_id': 3,
    //   'name': "Harikaran",
    //   'language': 0,
    //   'autoplay': 0,
    //   'is_child': 0,
    //   'pin': "0",
    //   'appnotify': 1
    // };

    ApiServices()
        .postRequestToken(AppConfig.setUserProfile + userID, postValues, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("setuserprofile_Response: $jsonsDataString");
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // var jsonReponse = jsonDecode(jsonsDataString);
          // String status = jsonReponse['status'];

          // if (status == "success") {
          Navigator.of(context).pop('success');
          // Navigator.pop(context, "success");
          // appUtils.showToast("Profile added successful.");
          // } else {
          //   appUtils.showToast("Profile not added updated.");
          // }
          context.loaderOverlay.hide();
        } catch (e) {
          print('CreateUserProfileException:$e');
        }
      } else {
        setState(() {
          context.loaderOverlay.hide();
        });
        print("Error: $response");
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      // setState(() {
      // });
      context.loaderOverlay.hide();
    });
    context.loaderOverlay.hide();
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
    context.loaderOverlay.show();
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
      if (response.statusCode == 200) {
        try {
          Navigator.of(context).pop('success');
          appUtils.showToast("Profile removed successful.");
          context.loaderOverlay.hide();
        } catch (e) {
          print('DeleteUserProfileException:$e');
        }
      } else {
        setState(() {
          context.loaderOverlay.hide();
        });
        print("DeleteUserError: $response");
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      // setState(() {
      // });
      context.loaderOverlay.hide();
    });
    context.loaderOverlay.hide();
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
    // final value = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ProfileImageGrid(),
    //     ));
    //
    // if (value != null && value is ProfileIconModel) {
    //   getSelectedIconID =value.profilePictureID.toString();
    //   getSelectedIcon =value.profilePicture.toString();
    //   print("ValuePrint"+getSelectedIcon);
    // }else{
    //   print("ValuenotPrint");
    // }
  }

  Widget showDeleteUserAlertDialog() {
    return AlertDialog(
      backgroundColor: AppDefaultColors.darkGray,
      title: const Text('Delete User',
          style: TextStyle(color: Colors.white, fontSize: 17)),
      content: Text("Are sure want to remove user permanently.",
          style: TextStyle(color: Colors.white, fontSize: 15)),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Remove',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () async {
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
