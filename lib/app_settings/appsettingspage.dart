// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/webview_pages/bestcast_webviewpages.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../register/who_watching_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool isNotificationSwitched = false;
  bool isDownloadWifiSwitched = false;
  bool isMobileDataSwitched = false;

  final AppUtils appUtils = AppUtils();

  String deviceDetails = "";

  DownloadQualityStatus? _qualityStatus = DownloadQualityStatus.Standard;
  MobileDateUsageStatus? _mobileDataStatus = MobileDateUsageStatus.WifiData;
  String downloadQualityStatus = "";
  String mobileDataStatus = "";

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

  String mobileDataUsage = "";
  bool enabelNotification = false;
  bool downloadDataOption = false;
  String downloadQuality = "";

  @override
  void initState() {
    super.initState();
    downloadQualityStatus = "Standard";
    mobileDataStatus = "Automatic";
    getInitalValue();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDeviceInfo();
    initDeviceInfo();
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

      mobileDataUsage = pref.getString(AppPreferences.mobileDataUsage) ?? '';
      enabelNotification = pref.getBool(AppPreferences.enabelNotification) ?? false;
      downloadDataOption = pref.getBool(AppPreferences.downloadDataOption) ?? false;
      downloadQuality = pref.getString(AppPreferences.downloadQuality) ?? 'Standard';

      mobileDataStatus = mobileDataUsage;
      downloadQualityStatus = downloadQuality;

      print("mobileDataUsage$mobileDataUsage");
      // print("downloadDataOption"+downloadDataOption);

      if (mobileDataStatus == "Automatic") {
        isMobileDataSwitched = true;
      } else {
        isMobileDataSwitched = false;

        if (mobileDataStatus == "Wi-FiOnly") {
          _mobileDataStatus = MobileDateUsageStatus.WifiData;
        } else if (mobileDataStatus == "Save Data") {
          _mobileDataStatus = MobileDateUsageStatus.WifiData;
        } else if (mobileDataStatus == "Maximum Data") {
          _mobileDataStatus = MobileDateUsageStatus.MaximumData;
        } else {
          mobileDataStatus = "Automatic";
        }
      }

      if (downloadQualityStatus == "Standard") {
        _qualityStatus = DownloadQualityStatus.Standard;
      } else {
        _qualityStatus = DownloadQualityStatus.High;
      }

      isNotificationSwitched = enabelNotification;
      isDownloadWifiSwitched = downloadDataOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          title: const Text(
            "App Settings",
            style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppDefaultColors.appColor,
          leading: const BackButton(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Container(
            // margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Video playback
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 5, top: 30),
                  child: Text(
                    "Video Playback",
                    style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showMobileDataUsageDialog(context);
                  },
                  child: Container(
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.signal_cellular_alt,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mobile Data Usage",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                Text(mobileDataStatus,
                                    style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 12)),
                              ],
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

                //Notification
                Visibility(
                  visible: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 5, top: 30),
                    child: Text(
                      "Notifications",
                      style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Visibility(
                    visible: false,
                    child: Container(
                      color: AppDefaultColors.hardDarkGray,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.notifications,
                              color: AppDefaultColors.white,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Allow Notifications",
                                    style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                  Text("Customise in settings->Notifications",
                                      style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              splashRadius: 50.0,
                              onChanged: (val) {
                                setState(() {
                                  isNotificationSwitched = val;
                                  saveNotificationData(isNotificationSwitched);
                                });
                              },
                              value: isNotificationSwitched,
                              // activeColor: AppDefaultColors.textLightGray,
                              // activeTrackColor: Colors.blue,
                              // inactiveThumbColor: AppDefaultColors.textLightGray,
                              // inactiveTrackColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //Downloads
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 5, top: 30),
                  child: Text(
                    "Downloads",
                    style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  color: AppDefaultColors.hardDarkGray,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.wifi,
                          color: AppDefaultColors.white,
                          size: 25.0,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Wi-Fi Only",
                                style: const TextStyle(color: Colors.white, fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          splashRadius: 50.0,
                          onChanged: (val) {
                            setState(() {
                              isDownloadWifiSwitched = val;
                              saveDownloadWifiData(isDownloadWifiSwitched);
                            });
                          },
                          value: isDownloadWifiSwitched,
                          // activeColor: AppDefaultColors.textLightGray,
                          // activeTrackColor: Colors.blue,
                          // inactiveThumbColor: AppDefaultColors.textLightGray,
                          // inactiveTrackColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDownloadQualityDialog(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: const Image(
                            image: AssetImage("images/video_resolution.png"),
                            height: 20,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Download Video Quality",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                Text(downloadQualityStatus,
                                    style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //About
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 5, top: 30),
                  child: Text(
                    "About",
                    style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.phone_android,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Device",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                Text(deviceDetails,
                                    style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WhosWatchingPage(
                                  activityType: "Manage",
                                )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.person_outline_sharp,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                Text("Email: $_email",
                                    style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.input_sharp, size: 20, color: AppDefaultColors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (await CommonWidget().isInternetConnectivity()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return showDeleteAlertDialog();
                        },
                      );
                    } else {
                      CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.delete_forever,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Delete account",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                              ],
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

                // GestureDetector(
                //   onTap: () async {
                //     if (await CommonWidget().isInternetConnectivity()) {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => QRcodeScannerScreen()));
                //     } else {
                //       CommonWidget().showSnackBar(context, ContentType.warning,
                //           "Check your internet connection.", "");
                //     }
                //   },
                //   child: Container(
                //     margin: EdgeInsets.only(top: 2),
                //     color: AppDefaultColors.hardDarkGray,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.all(12.0),
                //           child: Icon(
                //             Icons.delete_forever,
                //             color: AppDefaultColors.white,
                //             size: 25.0,
                //           ),
                //         ),
                //         Expanded(
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "Scan QR code",
                //                   style: const TextStyle(
                //                       color: Colors.white, fontSize: 16.0),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         IconButton(
                //           padding: EdgeInsets.zero,
                //           icon: Icon(Icons.arrow_forward_ios_sharp,
                //               size: 20, color: AppDefaultColors.white),
                //           onPressed: () {},
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                //Legal
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 5, top: 30),
                  child: Text(
                    "Legal",
                    style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BestcastWebView(
                                  url: "privacy",
                                )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.feed_sharp,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Privacy",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.input_sharp, size: 20, color: AppDefaultColors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BestcastWebView(
                                  url: "privacy",
                                )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2),
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.feed_sharp,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cookie Preferences",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.input_sharp, size: 20, color: AppDefaultColors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => BestcastWebView(
                    //           url: "Ad-choices",
                    //         )));
                  },
                  child: Visibility(
                    visible: false,
                    child: Container(
                      margin: EdgeInsets.only(top: 2),
                      color: AppDefaultColors.hardDarkGray,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.feed_sharp,
                              color: AppDefaultColors.white,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ad-choices",
                                    style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.input_sharp, size: 20, color: AppDefaultColors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BestcastWebView(
                                  url: "terms-conditions",
                                )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 2, bottom: 2),
                    color: AppDefaultColors.hardDarkGray,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.feed_sharp,
                            color: AppDefaultColors.white,
                            size: 25.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Terms of use",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.input_sharp, size: 20, color: AppDefaultColors.white),
                          onPressed: () {},
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
  }

  Future<void> showDownloadQualityDialog(context) async {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: AppDefaultColors.darkGray,
            surfaceTintColor: Colors.transparent,
            title: Text('Download Video Quality',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Radio<DownloadQualityStatus>(
                            activeColor: Colors.white,
                            value: DownloadQualityStatus.Standard,
                            groupValue: _qualityStatus,
                            onChanged: (DownloadQualityStatus? value) {
                              setState(() {
                                _qualityStatus = value;
                              });
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Standard', style: TextStyle(color: Colors.white, fontSize: 17)),
                              Text('Downloads faster and uses less storage',
                                  style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<DownloadQualityStatus>(
                            activeColor: Colors.white,
                            value: DownloadQualityStatus.High,
                            groupValue: _qualityStatus,
                            onChanged: (DownloadQualityStatus? value) {
                              setState(() {
                                _qualityStatus = value;
                              });
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('High', style: TextStyle(color: Colors.white, fontSize: 17)),
                              Text('Uses more storage', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontSize: 15)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 15)),
                onPressed: () {
                  setState(() {
                    _qualityStatus == DownloadQualityStatus.Standard
                        ? downloadQualityStatus = "Standard"
                        : downloadQualityStatus = "High";
                    changeTextField(downloadQualityStatus);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> showMobileDataUsageDialog(context) async {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: AppDefaultColors.darkGray,
            surfaceTintColor: Colors.transparent,
            title: Text('Mobile Data Usage',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Automatic",
                                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                splashRadius: 50.0,
                                onChanged: (val) {
                                  setState(() {
                                    // isDownloadWifiSwitched = val;
                                    isMobileDataSwitched = val;

                                    if (isMobileDataSwitched) {
                                      _mobileDataStatus = null;
                                    }
                                  });
                                },
                                // value: isDownloadWifiSwitched,
                                value: isMobileDataSwitched,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<MobileDateUsageStatus>(
                            activeColor: Colors.white,
                            value: MobileDateUsageStatus.WifiData,
                            groupValue: _mobileDataStatus,
                            onChanged: isMobileDataSwitched
                                ? null
                                : (MobileDateUsageStatus? value) {
                                    setState(() {
                                      _mobileDataStatus = value;
                                    });
                                  },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Wi-Fi Only', style: TextStyle(color: Colors.white, fontSize: 17)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<MobileDateUsageStatus>(
                            activeColor: Colors.white,
                            value: MobileDateUsageStatus.saveData,
                            groupValue: _mobileDataStatus,
                            onChanged: isMobileDataSwitched
                                ? null
                                : (MobileDateUsageStatus? value) {
                                    setState(() {
                                      _mobileDataStatus = value;
                                    });
                                  },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Save Data', style: TextStyle(color: Colors.white, fontSize: 17)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Radio<MobileDateUsageStatus>(
                            activeColor: Colors.white,
                            value: MobileDateUsageStatus.MaximumData,
                            groupValue: _mobileDataStatus,
                            onChanged: isMobileDataSwitched
                                ? null
                                : (MobileDateUsageStatus? value) {
                                    setState(() {
                                      _mobileDataStatus = value;
                                    });
                                  },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Maximum Data',
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.normal)),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontSize: 15)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 15)),
                onPressed: () {
                  setState(() {
                    if (_mobileDataStatus == MobileDateUsageStatus.WifiData) {
                      mobileDataStatus = "Wi-FiOnly";
                    } else if (_mobileDataStatus == MobileDateUsageStatus.saveData) {
                      mobileDataStatus = "Save Data";
                    } else if (_mobileDataStatus == MobileDateUsageStatus.MaximumData) {
                      mobileDataStatus = "Maximum Data";
                    } else {
                      mobileDataStatus = "Automatic";
                    }
                    changeMobileDataUsaeTextField(mobileDataStatus);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget showDeleteAlertDialog() {
    return AlertDialog(
      backgroundColor: AppDefaultColors.darkGray,
      title: const Text('Are you sure want to delete acccount?', style: TextStyle(color: Colors.white, fontSize: 17)),
      content: Text("Delete user account means you'll delete account permanently from Bestcast.",
          style: TextStyle(color: Colors.white, fontSize: 15)),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Delete Account', style: TextStyle(color: Colors.white, fontSize: 15)),
          onPressed: () async {
            Navigator.pop(context);
            if (await CommonWidget().isInternetConnectivity()) {
              deleteAccount(_token);
            } else {
              CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
            }
          },
        ),
      ],
    );
  }

  void deleteAccount(String token) async {
    // context.loaderOver lay.show();
    appUtils.showLoaderDialog(context);

    ApiServices().getRequestData(AppConfig.deleteaAccountUrl, token).then((response) async {
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
            // context.loaderOverlay.hide();

            Navigator.of(context).pushNamedAndRemoveUntil(
              'login',
              (route) => false, // Removes all routes from the stack
            );
            // await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(requiredEmail: "")));
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

  void initDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // print('Running on ${androidInfo.model}');

    // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    // print('Running on ${iosInfo.utsname.machine}');

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        setState(() {
          deviceDetails =
              "Device Model: ${androidInfo.model}\nDevice ID: ${androidInfo.id}\nVersion: ${androidInfo.version.release}\n";
        });

        print('Device Model: ${androidInfo.model}');
        print('Android Version: ${androidInfo.version}');
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

        setState(() {
          deviceDetails =
              "Device Model: ${iosInfo.model}\nDevice ID: ${iosInfo.identifierForVendor}\nVersion: ${iosInfo.systemVersion}\n";
        });

        print('Device Model: ${iosInfo.model}');
        print('iOS Version: ${iosInfo.systemVersion}');
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }
  }

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Device Name: ${androidInfo.model}');
      print('Device ID: ${androidInfo.id}');
      print('Device Version: ${androidInfo.version.release}');
      // You can access more device information from androidInfo
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Device Name: ${iosInfo.name}');
      print('Device ID: ${iosInfo.identifierForVendor}');
      print('Device System Name: ${iosInfo.systemName}');
      // You can access more device information from iosInfo
    }
  }

  void changeTextField(String textStatus) {
    setState(() {
      downloadQualityStatus = textStatus;
      saveDownloadQualityData(downloadQualityStatus);
    });
  }

  void changeMobileDataUsaeTextField(String textStatus) {
    setState(() {
      mobileDataStatus = textStatus;
      saveMobileDataUsage(mobileDataStatus);
    });
  }

  Future<void> saveMobileDataUsage(String mobileDataStatus) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppPreferences.mobileDataUsage, mobileDataStatus);
  }

  Future<void> saveNotificationData(bool notificationStatus) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(AppPreferences.enabelNotification, notificationStatus);
  }

  Future<void> saveDownloadWifiData(bool downloadWifiStatus) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(AppPreferences.downloadDataOption, downloadWifiStatus);
  }

  Future<void> saveDownloadQualityData(String qualityStatus) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppPreferences.downloadQuality, qualityStatus);
  }
}

enum DownloadQualityStatus { Standard, High }

enum MobileDateUsageStatus { WifiData, saveData, MaximumData }
