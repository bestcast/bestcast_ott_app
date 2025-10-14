// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/authendication/plan_expired_creen.dart';
import 'package:bestcaststudios/common_files/submitButton.dart';
import 'package:bestcaststudios/register/intro_page.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_strings.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../register/create_account.dart';
import '../register/who_watching_page.dart';
import '../webview_pages/bestcast_webviewpages.dart';
import 'device_signout_alert_screen.dart';

class LoginPage extends StatefulWidget {
  String requiredEmail = "";

  LoginPage({super.key, required this.requiredEmail});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final AppUtils appUtils = AppUtils();

  var _passwordVisible;
  bool _enablePassowdShowBtn = false;
  bool _isPassowdValid = false;
  bool _isEmailPhoneValid = false;
  bool isButtonEnabled = false;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _passwordVisible = true;
    // userNameController.text = "kharykaran@gmail.com";
    // userNameController.text = "support@bestcast.co";
    // passwordController.text = "password";

    if (widget.requiredEmail.isNotEmpty) {
      userNameController.text = widget.requiredEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          title: SizedBox(
            height: 30,
            child: const Image(image: AssetImage("images/logo_bestcast.png")),
          ),
          backgroundColor: AppDefaultColors.appColor,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              SystemNavigator.pop();
              exit(0);
            },
          ),
        ),
        body: LoaderOverlay(
          child: Form(
            key: formkey,
            // onChanged: () => setState(() => _enablePassowdShowBtn = formkey.currentState!.validate()),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Stack(children: <Widget>[
              if (isLoading) LoadingWidget(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: <Widget>[
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
                              if (txt?.length != 0) {
                                _isEmailPhoneValid = true;
                              } else {
                                _isEmailPhoneValid = false;
                                _errorMessage = "";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Email or phone number',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Stack(
                        alignment: const Alignment(0, 0),
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                color: AppDefaultColors.boxDarkGray,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                                  child: TextFormField(
                                      obscureText: _passwordVisible,
                                      autovalidateMode: AutovalidateMode.always,
                                      validator: (txt) {
                                        if (txt?.length != 0) {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            setState(() {
                                              _enablePassowdShowBtn = true;
                                              _isPassowdValid = true;
                                            });
                                          });
                                        } else {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            setState(() {
                                              _enablePassowdShowBtn = false;
                                              _isPassowdValid = false;
                                            });
                                          });
                                        }

                                        if (_isEmailPhoneValid && _isPassowdValid) {
                                          isButtonEnabled = true;
                                        } else {
                                          isButtonEnabled = false;
                                        }
                                        return null;
                                      },
                                      style: TextStyle(color: Colors.white),
                                      cursorColor: AppDefaultColors.white,
                                      controller: passwordController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Password',
                                      )))),
                          Container(
                            child: _enablePassowdShowBtn
                                ? Positioned(
                                    right: 0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size.fromHeight(70),
                                        foregroundColor: AppDefaultColors.lightGray,
                                        backgroundColor: AppDefaultColors.boxDarkGray,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          // borders: Border.all(width: 1, color: Colors.grey),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                      child: Text(
                                        _passwordVisible ? 'SHOW' : "HIDE",
                                        style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 15),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
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
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 5.0),
                        child: SubmitButtonDesign(
                          "Sign In",
                          isButtonEnabled,
                          onTap: () async {
                            if (await CommonWidget().isInternetConnectivity()) {
                              if (formkey.currentState!.validate()) {
                                String userName = userNameController.text;
                                String password = passwordController.text;
                                if (!appUtils.validateEmail(userName) && !appUtils.isNumericUsing_tryParse(userName)) {
                                  setState(() {
                                    _errorMessage = AppStrings.errorMessagePhoneOrEmail;
                                  });
                                } else {
                                  setState(() {
                                    _errorMessage = null;
                                  });

                                  context.loaderOverlay.show();
                                  LoginProcess(userName, password);
                                  print(userNameController.text);
                                  print(passwordController.text);
                                }
                              } else {
                                print("Not Validated");
                              }
                            } else {
                              CommonWidget()
                                  .showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
                            }

                            // Navigator.push(context, MaterialPageRoute(builder: (context) => WhosWatchingPage(activityType: 'New',)));
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(right: 5.0),
                      child: TextButton(
                        onPressed: () {
                          //forgot password screen
                        },
                        child: const Text(
                          'OR',
                          style: TextStyle(color: AppDefaultColors.textLightGray),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      // child: SubmitGreyButtonDesign(
                      //   "Use a Sign-In Code",
                      //   onTap: () async {
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      //   },
                      // ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(right: 5.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BestcastWebView(
                                        url: "forgotpassword",
                                      )));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 17),
                        ),
                      ),
                    ),

                    //TODO hide for ios
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(right: 5.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => const IntroPage()));
                        },
                        child: const Text(
                          'New to Bestcast? Sign up now.',
                          style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 17),
                        ),
                      ),
                    ),

                    //TODO enable if the future
                    // Container(
                    //   alignment: Alignment.center,
                    //   padding: const EdgeInsets.all(15.0),
                    //   child: TextButton(
                    //     onPressed: () {
                    //       //forgot password screen
                    //     },
                    //     child: Align(
                    //       alignment: Alignment.center,
                    //       child: Text("Sign in protected by Google reCAPTCHA to ensure you\'re not a bot. Learn more.",
                    //           style: TextStyle(fontSize: 12.0, color: AppDefaultColors.boxDarkGray), textAlign: TextAlign.center),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  //Api Login Integrations
  Future<void> LoginProcess(String userName, String password) async {
    isLoading = true;
    final postValues = {'email': userName, 'password': password, 'device': "mobile"};
    ApiServices().postRequest(AppConfig.LoginUrl, postValues).then((response) async {
      String jsonsDataString = response.body.toString();
      // if (response.statusCode == 200) {
      print("Login_Response: $jsonsDataString");

      try {
        var jsonReponse = jsonDecode(jsonsDataString);
        String status = jsonReponse['status'];

        if (status == "success") {
          String? id = jsonReponse['results']['user']['id'].toString();
          String? email = jsonReponse['results']['user']['email'].toString();
          String? phone = jsonReponse['results']['user']['phone'].toString();
          String? name = jsonReponse['results']['user']['name'].toString();
          String? firstname = jsonReponse['results']['user']['firstname'].toString();
          String? lastname = jsonReponse['results']['user']['lastname'].toString();
          String? dob = jsonReponse['results']['user']['dob'].toString();
          String? gender = jsonReponse['results']['user']['gender'].toString();
          String? plan = jsonReponse['results']['user']['plan'].toString();
          String? planExpiry = jsonReponse['results']['user']['plan_expiry'].toString();
          String? photo = jsonReponse['results']['user']['photo'].toString();
          String? otp = jsonReponse['results']['user']['otp'].toString();
          String? tvcode = jsonReponse['results']['user']['tvcode'].toString();
          String? referalCode = jsonReponse['results']['user']['referal_code'].toString();
          String? creditsUsed = jsonReponse['results']['user']['credits_used'].toString();
          String? refferer = jsonReponse['results']['user']['refferer'].toString();
          String? planStatus = jsonReponse['results']['user']['plan_status'].toString();
          String? planDeviceStatus = jsonReponse['results']['user']['plan_device_status'].toString();
          String? token = jsonReponse['results']['token'].toString();

          print("TokenLogin$token");

          final pref = await SharedPreferences.getInstance();
          await pref.setString(AppPreferences.id, id);
          await pref.setString(AppPreferences.email, email);
          await pref.setString(AppPreferences.phone, phone);
          await pref.setString(AppPreferences.name, name);
          await pref.setString(AppPreferences.firstname, firstname);
          await pref.setString(AppPreferences.lastname, lastname);
          await pref.setString(AppPreferences.dob, dob);
          await pref.setString(AppPreferences.gender, gender);
          await pref.setString(AppPreferences.plan, plan);
          await pref.setString(AppPreferences.plan_expiry, planExpiry);
          await pref.setString(AppPreferences.photo, photo);
          await pref.setString(AppPreferences.otp, otp);
          await pref.setString(AppPreferences.tvcode, tvcode);
          await pref.setString(AppPreferences.referal_code, referalCode);
          await pref.setString(AppPreferences.credits_used, creditsUsed);
          await pref.setString(AppPreferences.refferer, refferer);
          await pref.setString(AppPreferences.token, token);

          // CommonWidget().showSnackBar(context, ContentType.success, "Success", "Login successful.");
          context.loaderOverlay.hide();
          isLoading = false;

          if (plan == "0") {
            await pref.setBool(AppPreferences.accountCreatedStatus, true);
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount(requiredEmail: email)));
          } else if (planStatus == "0" && plan != "0") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PlanExpiredScreen()));
          } else if (planDeviceStatus == "0") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DeviceSignOutAlertScreen(
                          email: email,
                        )));
          } else {
            await pref.setBool(AppPreferences.loggedStatus, true);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WhosWatchingPage(
                  activityType: 'New',
                ),
              ),
            );
          }
        } else {
          String errorMessage = jsonReponse['message'];
          setState(() {
            _errorMessage = errorMessage;
          });
          // CommonWidget().showSnackBar(context, ContentType.failure, "Failed", "Invalid Credentials.");
        }
      } catch (e) {
        print('LoginError:$e');
        CommonWidget().showSnackBar(context, ContentType.failure, "", "Something went wrong");
      }
      // } else {
      //   print("Error: " + response.toString());
      //   context.loaderOverlay.hide();
      //   CommonWidget().showSnackBar(context, ContentType.failure, "Error", "Something went wrong.");
      // }
      isLoading = false;
      context.loaderOverlay.hide();
    });
  }

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
  }
}
