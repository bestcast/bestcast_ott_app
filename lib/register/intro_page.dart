import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/app_config/app_preferences.dart';
import 'package:bestcaststudios/common_files/api_services.dart';
import 'package:bestcaststudios/common_files/common_widgets.dart';
import 'package:bestcaststudios/common_files/submitRedButton.dart';
import 'package:bestcaststudios/webview_pages/bestcast_webviewpages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authendication/otp_page.dart';
import '../common_files/app_default_colors.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  /// The widgets to display in the [ImageSlideshow].
  ///
  late List<Widget> children;
  late double width;

  /// Height of the [ImageSlideshow].
  late double height;

  /// The page to show when first creating the [ImageSlideshow].
  late int initialPage;

  /// The color to paint the indicator.
  late Color indicatorColor;

  /// The color to paint behind th indicator.
  late Color indicatorBackgroundColor;

  /// Called whenever the page in the center of the viewport changes.
  late ValueChanged<int> onPageChanged;

  /// Auto scroll interval.
  ///
  /// Do not auto scroll with null or 0.
  late int autoPlayInterval;

  /// Loops back to first slide.
  late bool isLoop;

  /// Radius of circle indicator.
  late double indicatorRadius;

  /// Disable page changes by the user.
  late bool disableUserScrolling;
  bool? _isEmailPhoneValid;
  bool isLoading = false;
  String? _errorMessage;

  TextEditingController userNameController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // statusBarColor: Colors.red, // You can use this as well
        statusBarIconBrightness: Brightness.light,
        // OR Vice Versa for ThemeMode.dark
        statusBarBrightness: Brightness.light,
        // OR Vice Versa for ThemeMode.dark
        systemNavigationBarColor: Colors.black, // OR Vice Versa for ThemeMode.dark
      ),
    );

    return Scaffold(
      //     height: 30,
      //   backgroundColor: Colors.transparent,
      body: LoaderOverlay(
        child: Form(
          key: formkey,
          child: SizedBox(
            child: Stack(children: <Widget>[
              ImageSlideshow(
                width: double.infinity,
                height: double.infinity,
                initialPage: 0,
                indicatorColor: AppDefaultColors.thikRed,
                indicatorRadius: 5,
                indicatorBottomPadding: 80,
                indicatorPadding: 15,
                indicatorBackgroundColor: Colors.grey,

                /// Called whenever the page in the center of the viewport changes.
                onPageChanged: (value) {
                  print('Page changed: $value');
                },
                autoPlayInterval: 5000,

                isLoop: true,
                children: [
                  Stack(children: [
                    Image.asset(
                      width: double.infinity,
                      height: double.infinity,
                      'images/slider_one.jpg',
                      fit: BoxFit.cover,
                    ),
                    //     width: double.infinity,
                    //     height: double.infinity,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 150.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    //forgot password screen
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        // "Unlimited\nentertainment,\none low price",
                                        "Unlimited\nentertainment",
                                        style: TextStyle(
                                            fontSize: 35.0,
                                            color: AppDefaultColors.white,
                                            fontFamily: GoogleFonts.titanOne().fontFamily),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                    'All of Bestcast starting at\naffordable price',
                                    // '',
                                    style: TextStyle(color: AppDefaultColors.white, fontSize: 20),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                  Stack(children: [
                    Image.asset(
                      width: double.infinity,
                      height: double.infinity,
                      'images/slider_two.jpg',
                      fit: BoxFit.cover,
                    ),
                    //     width: double.infinity,
                    //     height: double.infinity,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 150.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    //forgot password screen
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text("Cancel online at\nany time",
                                        style: TextStyle(
                                            fontSize: 35.0,
                                            color: AppDefaultColors.white,
                                            fontFamily: GoogleFonts.titanOne().fontFamily),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text('Join today, no reason to wait.',
                                    style: TextStyle(color: AppDefaultColors.white, fontSize: 20),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                  Stack(children: [
                    Image.asset(
                      width: double.infinity,
                      height: double.infinity,
                      'images/slider_three.jpg',
                      fit: BoxFit.cover,
                    ),
                    //     width: double.infinity,
                    //     height: double.infinity,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 150.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    //forgot password screen
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text("Watch\neverywhere",
                                        style: TextStyle(
                                            fontSize: 35.0,
                                            color: AppDefaultColors.white,
                                            fontFamily: GoogleFonts.titanOne().fontFamily),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text('Stream on your phone, tablet,\nlaptop,TV and more.',
                                    style: TextStyle(color: AppDefaultColors.white, fontSize: 20),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  width: 120,
                                  'images/logo_bestcast.png',
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => BestcastWebView(url: "privacy")));
                          },
                          child: Text("PRIVACY",
                              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(
                        // sized box with width 10
                        width: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: GestureDetector(
                          onTap: () {
                          },
                          child: Text("LOGIN",
                              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: PopupMenuButton<int>(
                          iconColor: Colors.grey,
                          onSelected: (item) => handleClick(item),
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(value: 0, child: Text('FAQs')),
                            PopupMenuItem<int>(value: 1, child: Text('HELP')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(right: 5.0),
                  child: SubmitRedButton(
                    "Get Started",
                    onTap: () async {
                      //---------Enable in ios----------
                      //     context,
                      //         builder: (context) =>

                      //   context: context,
                      //       height: 200,
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //             //     "Get Started",
                      //             //

                      //----------------------Hide in ios-------
                      showModalBottomSheet<void>(
                          context: context,
                          constraints: BoxConstraints(
                            maxHeight: double.infinity,
                          ),
                          scrollControlDisabledMaxHeightRatio: 0,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, void Function(void Function()) setState) {
                                return LoaderOverlay(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Container(
                                      height: double.infinity,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Row(
                                                  children: const [
                                                    Expanded(
                                                        child: SizedBox(
                                                      width: 10,
                                                    )),
                                                    Icon(Icons.close, color: AppDefaultColors.appColor),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                              child: Text(
                                                'Ready to watch?',
                                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                                              child: Text(
                                                // "Enter your email to create or sign in to your account.",
                                                "Enter your mobile number to create or sign in to your account.",
                                                style: TextStyle(fontSize: 17.0, color: AppDefaultColors.boxDarkGray),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 10, bottom: 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  border: Border.all(width: 1, color: Colors.blue),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                                                  child: TextFormField(
                                                    keyboardType: TextInputType.number,
                                                    controller: userNameController,
                                                    cursorColor: Colors.black,
                                                    style: TextStyle(color: Colors.black),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      labelText: 'Mobile number',
                                                      hintStyle: TextStyle(fontSize: 12, color: Colors.black),
                                                      labelStyle: TextStyle(fontSize: 18, color: Colors.black),
                                                      floatingLabelStyle: TextStyle(color: Colors.black),
                                                      focusColor: AppDefaultColors.darkBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            _isEmailPhoneValid == false
                                                ? Padding(
                                                    padding: const EdgeInsets.only(top: 1, bottom: 10),
                                                    child: Text(
                                                      // "Enter a valid email",
                                                      _errorMessage!,
                                                      // "Enter a valid mobile number",
                                                      style: TextStyle(fontSize: 17.0, color: AppDefaultColors.appRed),
                                                    ),
                                                  )
                                                : Text(""),
                                            Padding(
                                              padding: EdgeInsets.only(top: 25.0, bottom: 10),
                                              child: SubmitRedButton(
                                                "GET STARTED",
                                                onTap: () async {

                                                  if (await CommonWidget().isInternetConnectivity()) {
                                                    if (formkey.currentState != null &&
                                                        formkey.currentState!.validate()) {
                                                      String userName = userNameController.text;

                                                      if (userName.toString() != "") {
                                                        createAccount("user", userName);
                                                      } else {
                                                        setState(() {
                                                          _isEmailPhoneValid = false;
                                                          _errorMessage = "Enter a valid mobile number";
                                                        });
                                                      }
                                                    } else {
                                                      print("Not Validated");
                                                    }
                                                  } else {
                                                    CommonWidget().showSnackBar(context, ContentType.warning,
                                                        "Check your internet connection.", "");
                                                  }
                                                },
                                              ),
                                            ),
                                            if (isLoading)
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: CircularProgressIndicator(
                                                    color: AppDefaultColors.thikRed,
                                                  ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          });

                      //----------------------Enable in future-------
                    },
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BestcastWebView(url: "privacy")));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BestcastWebView(url: "help")));
        break;
    }
  }

  void verifyAccountEmail(String email) async {
    context.loaderOverlay.show();
    final postValues = {'phone': email};
    ApiServices().postRequest(AppConfig.emailverifyUrl, postValues).then((response) async {
      String jsonsDataString = response.body.toString();
      print("verfiyEmail_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            context.loaderOverlay.hide();
            Navigator.push(context, MaterialPageRoute(builder: (context) => OTPactivity(otpEmailorPhone: email)));
          } else {
            context.loaderOverlay.hide();
          }
          context.loaderOverlay.hide();
        } catch (e) {
          print('verifyEmailException:$e');
          CommonWidget().showSnackBar(context, ContentType.failure, "", "Something went wrong");
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }
      context.loaderOverlay.hide();
    });
  }

  void createAccount(String userName, String mobileNumber) async {
    setState(() {
      isLoading = true;
    });
    context.loaderOverlay.show();
    final pref = await SharedPreferences.getInstance();
    final referrerCode = pref.getString(AppPreferences.refferer) ?? '';
    
    final postValues = {'phone': mobileNumber, 'name': userName, 'refferer': referrerCode, 'device': "mobile"};
    ApiServices().postRequest(AppConfig.registerUrl, postValues).then((response) async {
      String jsonsDataString = response.body.toString();
      if (response.statusCode == 200) {
        print("register_Response: $jsonsDataString");

        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            context.loaderOverlay.hide();
            setState(() {
              isLoading = false;
            });
            verifyAccountEmailorPhone(mobileNumber);
          } else {
            String message = jsonReponse['message'];
            print("responseMessage: $status----$message");
            setState(() {
              _isEmailPhoneValid = false;
              _errorMessage = message;
            });
            context.loaderOverlay.hide();
            isLoading = false;
          }
        } catch (e) {
          print('RegisterError:$e');
          context.loaderOverlay.hide();
          isLoading = false;
          CommonWidget().showSnackBar(context, ContentType.failure, "", "Something went wrong");
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        isLoading = false;
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", "Something went wrong.");
      }
      context.loaderOverlay.hide();
      isLoading = false;
    });
  }

  void verifyAccountEmailorPhone(String email) async {
    context.loaderOverlay.show();
    final postValues = {'email': email};
    ApiServices().postRequest(AppConfig.sendOtp, postValues).then((response) async {
      String jsonsDataString = response.body.toString();
      print("sendOtp_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OTPactivity(otpEmailorPhone: email)));
          } else {
            String errorMessage = jsonReponse['message'];
            setState(() {
              _errorMessage = errorMessage;
            });
          }
          context.loaderOverlay.hide();
        } catch (e) {
          print('sendOTPmailException:$e');
          CommonWidget().showSnackBar(context, ContentType.failure, "", "Something went wrong");
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
      }
      context.loaderOverlay.hide();
    });
  }

  bool validateEmail(String email) {
    bool isvalid = EmailValidator.validate(email);
    if (isvalid) {
      setState(() {
        _isEmailPhoneValid = true;
      });
    } else {
      setState(() {
        _errorMessage = "Enter a valid mobile number";
        _isEmailPhoneValid = false;
      });
    }
    return isvalid;
  }
}
