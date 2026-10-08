import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/app_config/app_strings.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/login.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../common_files/submitRedButton.dart';
import '../webview_pages/bestcast_webviewpages.dart';

// ignore: must_be_immutable
class CreateAccount extends StatefulWidget {
  String requiredEmail = "";

  CreateAccount({super.key, required this.requiredEmail});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  final AppUtils appUtils = AppUtils();
  bool isLoading = false;
  String titleText = "";
  String descriptionText = "";
  String registerEmail = "";
  String token = "";
  bool accountCreatedStatus = false;

  @override
  void initState() {
    super.initState();
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,

    getInitialValue();

    if (widget.requiredEmail.isNotEmpty) {
      userNameController.text = widget.requiredEmail;
      registerEmail = widget.requiredEmail;
    }
  }

  Future<void> getInitialValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      accountCreatedStatus =
          pref.getBool(AppPreferences.accountCreatedStatus) ?? false;
      token = pref.getString(AppPreferences.token) ?? '';
    });

    print("accountCreatedStatus$accountCreatedStatus");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GlobalLoaderOverlay(
        useDefaultLoading: true,
        child: Form(
          key: formkey,
          child: Stack(children: <Widget>[
            Padding(
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
                      Container(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BestcastWebView(url: "help")));
                                  },
                                  child: Text("HELP",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600)),
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
                                    if (accountCreatedStatus) {
                                      getLogout(token);
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LoginPage(
                                                  requiredEmail: "")));
                                    }
                                  },
                                  child: Text(
                                      accountCreatedStatus
                                          ? "SIGN OUT"
                                          : "LOGIN",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 10),
                        child: Text(
                          accountCreatedStatus
                              ? AppStrings.finishingSigningUpTitle2
                              : AppStrings.unlimitedMoviesTitle,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (accountCreatedStatus)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, bottom: 0),
                              child: Text(
                                "Almost there! We just sent an email to ",
                                style: TextStyle(
                                    fontSize: 17.0,
                                    color: AppDefaultColors.boxDarkGray),
                              ),
                            ),
                            Text(
                              registerEmail,
                              style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                        child: Text(
                          accountCreatedStatus
                              ? AppStrings.youAreOnlyDescription
                              : AppStrings.asMemberDescriptoin,
                          style: TextStyle(
                              fontSize: 17.0,
                              color: AppDefaultColors.boxDarkGray),
                        ),
                      ),
                      if (accountCreatedStatus == false)
                        Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1, color: Colors.blue),
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15, top: 0),
                                        child: TextFormField(
                                          controller: userNameController,
                                          cursorColor: Colors.black,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: 'Email',
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                            labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                            floatingLabelStyle:
                                                TextStyle(color: Colors.black),
                                            focusColor:
                                                AppDefaultColors.darkBlue,
                                          ),
                                        )))),
                            Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1, color: Colors.blue),
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15, top: 0),
                                        child: TextFormField(
                                          cursorColor: Colors.black,
                                          controller: passwordController,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: 'Password',
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                            labelStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                            floatingLabelStyle:
                                                TextStyle(color: Colors.black),
                                            focusColor:
                                                AppDefaultColors.darkBlue,
                                          ),
                                        )))),
                            Padding(
                              padding: EdgeInsets.only(top: 25.0, bottom: 10),
                              child: SubmitRedButton(
                                "CREATE ACCOUNT",
                                onTap: () async {
                                  if (await CommonWidget()
                                      .isInternetConnectivity()) {
                                    if (formkey.currentState!.validate()) {
                                      String userName = userNameController.text;
                                      String password = passwordController.text;

                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                      context.loaderOverlay.show();
                                      createAccount(userName, password);
                                    } else {
                                      print("Not Validated");
                                    }
                                  } else {
                                    CommonWidget().showSnackBar(
                                        context,
                                        ContentType.warning,
                                        "Check your internet connection.",
                                        "");
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading) LoadingWidget(),
          ]),
        ),
      ),
    );
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        break;
      case 1:
        break;
    }
  }

  void createAccount(String userName, String password) async {
    setState(() {
      isLoading = true;
    });
    context.loaderOverlay.show();

    try {
      final postValues = {
        'email': userName,
        'password': password,
        'device': "mobile"
      };

      final response = await ApiServices()
          .postRequest(AppConfig.registerUrl, postValues)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final String jsonsDataString = response.body.toString();
      if (response.statusCode == 200) {
        print("register_Response: $jsonsDataString");

        final dynamic jsonReponse = jsonDecode(jsonsDataString);
        final String status = jsonReponse['status']?.toString() ?? "";

        if (status == "success") {
          String? id = jsonReponse['results']['user']['id'].toString();
          String? email = jsonReponse['results']['user']['email'].toString();
          String? phone = jsonReponse['results']['user']['phone'].toString();
          String? name = jsonReponse['results']['user']['name'].toString();
          String? firstname =
              jsonReponse['results']['user']['firstname'].toString();
          String? lastname =
              jsonReponse['results']['user']['lastname'].toString();
          String? dob = jsonReponse['results']['user']['dob'].toString();
          String? gender =
              jsonReponse['results']['user']['gender'].toString();
          String? plan = jsonReponse['results']['user']['plan'].toString();
          String? planExpiry =
              jsonReponse['results']['user']['plan_expiry'].toString();
          String? photo = jsonReponse['results']['user']['photo'].toString();
          String? otp = jsonReponse['results']['user']['otp'].toString();
          String? tvcode =
              jsonReponse['results']['user']['tvcode'].toString();
          String? referalCode =
              jsonReponse['results']['user']['referal_code'].toString();
          String? creditsUsed =
              jsonReponse['results']['user']['credits_used'].toString();
          String? refferer =
              jsonReponse['results']['user']['refferer'].toString();
          String? bmpReferralCode =
              jsonReponse['results']['user']['bmp_referral_code']?.toString();
          String? token = jsonReponse['results']['token'].toString();

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
          if (bmpReferralCode != null && bmpReferralCode.isNotEmpty && bmpReferralCode != "null") {
            await pref.setString(AppPreferences.bmpReferralCode, bmpReferralCode);
            await pref.setString(AppPreferences.refferer, bmpReferralCode);
          }
          await pref.setString(AppPreferences.token, token);

          if (!mounted) return;
          setState(() {
            this.token = token;
            pref.setBool(AppPreferences.accountCreatedStatus, true);
            accountCreatedStatus = true;
            registerEmail = email;
          });
        } else {
          String message = jsonReponse['message']?.toString() ?? "Registration failed";
          appUtils.showToast(message);
        }
      } else {
        print("Error: $response");
        if (mounted) {
          CommonWidget().showSnackBar(
              context, ContentType.failure, "Error", "Something went wrong.");
        }
      }
    } catch (e) {
      print('RegisterError:$e');
      if (mounted) {
        CommonWidget().showSnackBar(
            context,
            ContentType.failure,
            "Connection Error",
            "Registration timed out or network error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        try {
          context.loaderOverlay.hide();
        } catch (_) {}
      }
    }
  }

  Future<void> getLogout(String token) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      context.loaderOverlay.show();
    } catch (_) {}

    Future<void> performLocalSignout() async {
      try {
        final pref = await SharedPreferences.getInstance();
        await AppPreferences.clearUserSession(pref);
      } catch (e) {
        print('Error clearing session: $e');
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        try {
          context.loaderOverlay.hide();
        } catch (_) {}

        Navigator.of(context).pushNamedAndRemoveUntil(
          'login',
          (route) => false,
        );
      }
    }

    try {
      if (token.isNotEmpty) {
        await ApiServices()
            .postRequestTokenWithoutBody(AppConfig.logoutUrl, token)
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      print("Remote logout error: $e");
    } finally {
      await performLocalSignout();
    }
  }
}
