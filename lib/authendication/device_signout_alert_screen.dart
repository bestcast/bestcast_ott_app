import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bestcaststudios/authendication/login_page.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';

// ignore: must_be_immutable
class DeviceSignOutAlertScreen extends StatefulWidget {
  String email = "";

  DeviceSignOutAlertScreen({super.key, required this.email});

  @override
  State<DeviceSignOutAlertScreen> createState() =>
      _DeviceSignOutAlertScreenState();
}

class _DeviceSignOutAlertScreenState extends State<DeviceSignOutAlertScreen> {
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;
  String emailDescription = "";
  String _token = "";

  @override
  void initState() {
    super.initState();
    String originalString = widget.email;
    String replacement = "*";
    List<String> parts = originalString.split('@');
    String username = parts[0];
    String domain = parts[1];

    String replacedUsername = username.length > 5
        ? username.substring(0, 5) + replacement * (username.length - 5)
        : username;
    String replacedString = "$replacedUsername@$domain";

    emailDescription =
        "Not $replacedString? Create an account to enjoy your own Bestcast today.";

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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              transform: GradientRotation(45),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                AppDefaultColors.carBgRed.withOpacity(0.3),
                AppDefaultColors.carBgBlue.withOpacity(0.2),
                AppDefaultColors.carBgBlue.withOpacity(0.2),
              ],
            ),
          ),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 30.0, right: 5.0),
                  child: const Text(
                    'Your device is not part of the Bestcast Household for this account',
                    style: TextStyle(
                      fontSize: 25,
                      color: AppDefaultColors.textLightGray,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.0, right: 5.0),
                  child: Text(
                    emailDescription,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppDefaultColors.textLightGray,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 30),
                  decoration: BoxDecoration(
                    color: AppDefaultColors.darkGray.withOpacity(0.4),
                    border: Border.all(
                      color: AppDefaultColors.textLightGray, // Border color
                      width: 0.5, // Border width
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'bestcast.co/register',
                              style: TextStyle(
                                  color: AppDefaultColors.white, fontSize: 17),
                            ),
                          ),
                        ),
                        Container(
                          child: SizedBox(
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size.fromHeight(10),
                                foregroundColor: AppDefaultColors.white,
                                backgroundColor: AppDefaultColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                launchUrlStart(
                                    url: "https://bestcast.co/register");
                              },
                              child: Text(
                                'Go to Link',
                                style: TextStyle(
                                    color: AppDefaultColors.darkGray,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        if (await CommonWidget().isInternetConnectivity()) {
                          context.loaderOverlay.show();
                          getLogout(_token);
                        } else {
                          CommonWidget().showSnackBar(
                              context,
                              ContentType.warning,
                              "Check your internet connection.",
                              "");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10),
                        child: Text(
                          "Sign Out",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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

  void getLogout(String token) async {
    appUtils.showLoaderDialog(context);
    setState(() {
      context.loaderOverlay.show();
    });
    ApiServices()
        .postRequestTokenWithoutBody(AppConfig.logoutUrl, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("logout_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            final pref = await SharedPreferences.getInstance();
            await pref.clear();

            await Future.delayed(Duration(seconds: 3));

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          }
          appUtils.hideLoaderDialog(context);
          context.loaderOverlay.hide();
        } catch (e) {
          appUtils.hideLoaderDialog(context);
          context.loaderOverlay.hide();
          print('logoutException:$e');
        }
      } else {
        appUtils.hideLoaderDialog(context);
        setState(() {
          context.loaderOverlay.hide();
        });
        print("logoutError: $response");
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      appUtils.hideLoaderDialog(context);
      context.loaderOverlay.hide();
    });
  }

  Future<void> launchUrlStart({required String url}) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
