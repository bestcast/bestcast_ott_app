// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// Project imports:
import '../app_config/app_utils.dart';
import '../authendication/otp_page.dart';
import '../components/functions/navigation_fun.dart';
import '../app_config/app_strings.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../components/widgets/button_widgets.dart';
import '../components/widgets/textfield_widgets.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum SingingCharacter { smsOtp, whatsAppOtp }

class _LoginPageState extends State<LoginPage> {
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;

  String? _errorMessage;

  SingingCharacter? character = SingingCharacter.whatsAppOtp;

  TextEditingController getCountryCode = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();

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
    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: AppDefaultColors.appColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 60),
              // ! Text Heading
              Text(
                'Verify your phone number',
                style: TextStyle(color: AppDefaultColors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              // ! Button for sms and whatsapp otp
              RadioGroup<SingingCharacter>(
                groupValue: character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    character = value;
                  });
                },
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<SingingCharacter>(
                        title: Text('Whats App', style: TextStyle(color: Colors.white)),
                        activeColor: AppDefaultColors.thikRed,
                        value: SingingCharacter.whatsAppOtp,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<SingingCharacter>(
                        title: Text('SMS', style: TextStyle(color: Colors.white)),
                        activeColor: AppDefaultColors.thikRed,
                        value: SingingCharacter.smsOtp,
                      ),
                    ),
                  ],
                ),
              ),
              // Todo: ----------------------------OTP Country Code ----------------------------------
              // ! Enter Mobile Number
              SizedBox(height: 12.0),
              if (character == SingingCharacter.whatsAppOtp)
                WhatsApptextfieldWidget(
                  controller: mobileNumberController,
                  onChanged: (phone) {
                    getCountryCode.text = phone.countryCode;
                  },
                ),
              if (character == SingingCharacter.smsOtp)
                SMStextfieldWidget(
                  controller: mobileNumberController,
                ),
              if (_errorMessage != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ),
              // Todo: ----------------------------OTP Country Code ----------------------------------
              // ! Send Code Button
              SizedBox(height: 25.0),
              SendButtonWidgets(
                "Send",
                onPressed: () async {
                  String emailorPhone = mobileNumberController.text.trim();
                  if (formkey.currentState!.validate()) {
                    if (!appUtils.validateEmail(emailorPhone) && !appUtils.isNumericUsing_tryParse(emailorPhone)) {
                      setState(() {
                        _errorMessage = AppStrings.errorMessagePhoneOrEmail;
                      });
                    } else {
                      setState(() => _errorMessage = null);
                      verifyAccountEmailorPhone(character, getCountryCode.text, emailorPhone);
                    }
                  } else {
                    setState(() {
                      _errorMessage = AppStrings.errorMessagePhoneOrEmail;
                    });
                  }
                },
              ),
              // ! New User Sign Up
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New to Bestcast?",
                    style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 17),
                  ),
                  TextButton(
                    onPressed: () {
                      AuthNavigator.navigateWithFade(context, RegisterPage());
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: AppDefaultColors.appRed, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (isLoading) LoadingWidget(),

              // Todo: ----------------------------OTP ACTIVITY NAVIGATION----------------------------------
              // SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Go to",
              //       style: TextStyle(
              //           color: AppDefaultColors.textLightGray, fontSize: 17),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         AuthNavigator.navigateWithFade(
              //             context, OTPactivity(otpEmailorPhone: "7545808885"));
              //       },
              //       child: const Text(
              //         'OTP PAGE',
              //         style: TextStyle(
              //             color: AppDefaultColors.appRed,
              //             fontSize: 15,
              //             fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ],
              // ),
              // Todo: ----------------------------OTP ACTIVITY NAVIGATION----------------------------------
            ],
          ),
        ),
      ),
    );
  }

  void verifyAccountEmailorPhone(SingingCharacter? character, String countryCode, String input) async {
    setState(() => isLoading = true);

    try {
      final otpMessageType = _getOtpType(character);
      countryCode = (countryCode.isEmpty || otpMessageType == "sms") ? "+91" : countryCode;

      final postValues = {'email': input, "otp_message_type": otpMessageType, "country_code": countryCode};
      final response = await ApiServices().postRequest(AppConfig.sendOtp, postValues);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final status = jsonResponse['status'];

        if (status == "success") {
          AuthNavigator.navigateWithFade(context,
              OTPactivity(otpEmailorPhone: input, getOtpMessageType: otpMessageType, getCountryCode: countryCode));
        } else {
          setState(() => _errorMessage = jsonResponse['message']);
        }
      } else if (response.statusCode == 201 && jsonResponse['status'] == "error") {
        setState(() => _errorMessage = jsonResponse['message']);
      } else {
        print("Error: $response");
        CommonWidget().showSnackBar(
          context,
          ContentType.failure,
          "Error",
          response.toString(),
        );
      }
    } catch (e) {
      print('sendOTPmailException: $e');
      CommonWidget().showSnackBar(
        context,
        ContentType.failure,
        "",
        "Something went wrong",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Helper to get OTP type
  String _getOtpType(SingingCharacter? character) {
    switch (character) {
      case SingingCharacter.whatsAppOtp:
        return "whatsapp";
      case SingingCharacter.smsOtp:
      default:
        return "sms";
    }
  }
}
