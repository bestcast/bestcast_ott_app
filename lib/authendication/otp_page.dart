import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../components/widgets/button_widgets.dart';
import '../register/who_watching_page.dart';

// ignore: must_be_immutable
class OTPactivity extends StatefulWidget {
  final String otpEmailorPhone;
  final String? getOtpMessageType;
  final String? getCountryCode;

  const OTPactivity({
    super.key,
    required this.otpEmailorPhone,
    this.getOtpMessageType,
    this.getCountryCode,
  });

  @override
  State<OTPactivity> createState() => _OTPactivityState();
}

class _OTPactivityState extends State<OTPactivity> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final AppUtils appUtils = AppUtils();

  var registerContent = "";
  var otpMessageType = "";
  var countryCode = "";
  var isButtonEnabled;
  var _resesndButtonEnabled;
  bool clearText = false;
  String? _errorMessage;
  String? _otp = "";

  int _secondsRemaining = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = false;
    _resesndButtonEnabled = false;
    registerContent = widget.otpEmailorPhone;
    otpMessageType = widget.getOtpMessageType!;
    countryCode = widget.getCountryCode!;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppDefaultColors.appColor,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LoaderOverlay(
        child: Form(
          key: formkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 60),
                // ! Text 001
                Text(
                  "Enter the code we just sent.",
                  style: TextStyle(
                      color: AppDefaultColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 25),
                // ! Text 002
                Text(
                    "We sent a OTP to $registerContent. \nThe code will expire in 15 minutes.",
                    style: TextStyle(
                        fontSize: 18.0, color: AppDefaultColors.textLightGray),
                    textAlign: TextAlign.center),
                SizedBox(height: 25),
                // ! OTP TextField
                OtpTextField(
                  numberOfFields: 4,
                  cursorColor: AppDefaultColors.white,
                  borderWidth: 2,
                  fieldWidth: 62,
                  borderColor: AppDefaultColors.boxDarkGray,
                  focusedBorderColor: AppDefaultColors.white,
                  disabledBorderColor: AppDefaultColors.boxDarkGray,
                  enabledBorderColor: AppDefaultColors.boxDarkGray,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 5),
                    ),
                  ),
                  clearText: clearText,
                  showFieldAsBox: true,
                  textStyle: TextStyle(
                      color: AppDefaultColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                  //runs when a code is typed in
                  onCodeChanged: (String code) {
                    if (code.isEmpty) {
                      setState(() {
                        isButtonEnabled = false;
                      });
                    }
                  },
                  //runs when every textfield is filled
                  onSubmit: (String verificationCode) {
                    setState(() {
                      if (verificationCode.length == 4) {
                        _otp = verificationCode;
                        isButtonEnabled = true;
                      } else {
                        isButtonEnabled = false;
                      }
                    });
                  }, // end onSubmit
                ),
                SizedBox(height: 35),
                SendButtonWidgets(
                  "Sign In",
                  onPressed: () async {
                    if (await CommonWidget().isInternetConnectivity()) {
                      context.loaderOverlay.show();
                      verifyOTP(registerContent, _otp!);
                    } else {
                      CommonWidget().showSnackBar(context, ContentType.warning,
                          "Check your internet connection.", "");
                    }
                  },
                ),
                // ! Error Message
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
                SizedBox(height: 35),
                const Text(
                  "Didn't receive a code?",
                  style: TextStyle(
                      color: AppDefaultColors.textLightGray, fontSize: 18),
                ),
                // ! Resend Code Button
                TextButton(
                  onPressed: () async {
                    if (await CommonWidget().isInternetConnectivity()) {
                      if (_resesndButtonEnabled) {
                        context.loaderOverlay.show();
                        resendOTP(registerContent, otpMessageType, countryCode);
                      }
                    } else {
                      CommonWidget().showSnackBar(context, ContentType.warning,
                          "Check your internet connection.", "");
                    }
                  },
                  child: Text(
                    _resesndButtonEnabled
                        ? 'Resend Code'
                        : 'Resend enabled in $_secondsRemaining seconds',
                    style:
                        TextStyle(color: AppDefaultColors.appRed, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTP(String email, String otp) async {
    context.loaderOverlay.show();

    final pref = await SharedPreferences.getInstance();
    final refCode = pref.getString(AppPreferences.bmpReferralCode) ?? pref.getString(AppPreferences.refferer);

    final Map<String, dynamic> postValues = {
      'email': email,
      'otp': otp,
      'device': "mobile",
    };
    if (refCode != null && refCode.isNotEmpty) {
      postValues['ref'] = refCode;
    }

    ApiServices()
        .postRequest(AppConfig.verifyOtp, postValues)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("verifyOtp_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

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
            await pref.setBool(AppPreferences.loggedStatus, true);

            print("_token_OTPLogin$token");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WhosWatchingPage(activityType: "New"),
              ),
            );
          } else {
            String message = jsonReponse['message'];
            appUtils.showToast(message);
          }
          context.loaderOverlay.hide();
        } catch (e) {
          print('verifyOtpException:$e');
          CommonWidget().showSnackBar(
              context, ContentType.failure, "", "Something went wrong");
        }
      } else {
        print("verifyOtpError: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      context.loaderOverlay.hide();
    });
  }

  void resendOTP(String email, String otpMessageType, String countryCode,) async {
    context.loaderOverlay.hide();
    final postValues = {'email': email, "otp_message_type": otpMessageType, "country_code": countryCode};
    ApiServices()
        .postRequest(AppConfig.sendOtp, postValues)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "success") {
            appUtils.showToast("OTP has resent successfully.");
            setState(() {
              isButtonEnabled = false;
              _resesndButtonEnabled = false;
              _secondsRemaining = 10;
            });
            _startTimer();
          } else {
            String errorMessage = jsonReponse['message'];
            setState(() {
              _errorMessage = errorMessage;
            });
          }
          context.loaderOverlay.hide();
        } catch (e) {
          print('sendOTPmailException:$e');
          CommonWidget().showSnackBar(
              context, ContentType.failure, "", "Something went wrong");
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      context.loaderOverlay.hide();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _resesndButtonEnabled = true;
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
