import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/login_page.dart';
import '../authendication/otp_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../components/functions/navigation_fun.dart';
import '../components/widgets/button_widgets.dart';
import '../components/widgets/textfield_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum SingingCharacter { smsOtp, whatsAppOtp }

class _RegisterPageState extends State<RegisterPage> {
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;

  String? _nameErrorMessage;
  String? _phoneErrorMessage;

  SingingCharacter? character = SingingCharacter.whatsAppOtp;
  TextEditingController userNameController = TextEditingController();
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
      body: SingleChildScrollView(
        child: LoaderOverlay(
          child: Form(
            key: formkey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 60),
                  // ! Text Heading
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Ready To Watch.',
                      style: TextStyle(color: AppDefaultColors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // ! Text Widgets
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Enter your mobile number to create your account.",
                      style: TextStyle(fontSize: 16.0, color: AppDefaultColors.textLightGray),
                    ),
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
                  SizedBox(height: 12.0),
                  // ! Name TextField
                  TextfieldWidget(
                    label: 'Full Name',
                    controller: userNameController,
                  ),
                  if (_nameErrorMessage != null) _buildError(_nameErrorMessage!),
                  // ! Mobile Number TextField
                  SizedBox(height: 12.0),
                  if (character == SingingCharacter.whatsAppOtp)
                    WhatsApptextfieldWidget(
                      controller: mobileNumberController,
                      onChanged: (phone) {
                        print("AZMAT: ${phone.countryCode}");
                        getCountryCode.text = phone.countryCode;
                      },
                    ),
                  if (character == SingingCharacter.smsOtp)
                    SMStextfieldWidget(
                      controller: mobileNumberController,
                    ),
                  if (_phoneErrorMessage != null) _buildError(_phoneErrorMessage!),
                  // ! Submit Button
                  SizedBox(height: 25.0),
                  SendButtonWidgets(
                    "Send",
                    onPressed: () async {
                      if (!_validateInputs()) return;
                      if (await CommonWidget().isInternetConnectivity()) {
                        createAccount(
                          character,
                          userNameController.text.trim(),
                          getCountryCode.text,
                          mobileNumberController.text.trim(),
                        );
                      } else {
                        CommonWidget().showSnackBar(
                          context,
                          ContentType.failure,
                          "Error",
                          "No Internet Connection",
                        );
                      }
                    },
                  ),
                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: AppDefaultColors.thikRed,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 17),
                      ),
                      TextButton(
                        onPressed: () {
                          AuthNavigator.navigateWithFade(context, LoginPage());
                        },
                        child: const Text(
                          'Login In',
                          style: TextStyle(
                            color: AppDefaultColors.appRed,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Error Text Builder (avoids duplication)
  Widget _buildError(String error) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0, left: 4.0),
        child: Text(
          error,
          style: const TextStyle(color: Colors.orange, fontSize: 13),
        ),
      ),
    );
  }

  void createAccount(SingingCharacter? character, String userName, String countryCode, String mobileNumber) async {
    setState(() => isLoading = true);
    context.loaderOverlay.hide();
    final otpMessageType = _getOtpType(character);
    countryCode = (countryCode.isEmpty || otpMessageType == "sms") ? "+91" : countryCode;

    final pref = await SharedPreferences.getInstance();
    final referrerCode = pref.getString(AppPreferences.refferer) ?? '';

    final postValues = {
      "phone": mobileNumber,
      "name": userName,
      "refferer": referrerCode,
      "device": "mobile",
      "otp_message_type": otpMessageType,
      "country_code": countryCode,
    };

    try {
      final response = await ApiServices().postRequest(AppConfig.registerUrl, postValues);
      final body = response.body.toString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(body);
        if (jsonResponse['status'] == "success") {
          AuthNavigator.navigateWithFade(
              context,
              OTPactivity(
                  otpEmailorPhone: mobileNumber, getOtpMessageType: otpMessageType, getCountryCode: countryCode));
        } else {
          CommonWidget()
              .showSnackBar(context, ContentType.failure, "Failed", jsonResponse['message'] ?? "Something went wrong");
        }
      } else if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(body);
        setState(() {
          _nameErrorMessage = jsonResponse['errors']['name']?[0];
          _phoneErrorMessage = jsonResponse['errors']['phone']?[0];
        });
        CommonWidget()
            .showSnackBar(context, ContentType.failure, "Failed", jsonResponse['message'] ?? "Something went wrong");
      } else {
        CommonWidget().showSnackBar(context, ContentType.failure, "Error", "Server error occurred");
      }
    } catch (e) {
      CommonWidget().showSnackBar(context, ContentType.failure, "Error", "The phone has already been taken.");
    } finally {
      context.loaderOverlay.hide();
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

  bool _validateInputs() {
    final name = userNameController.text.trim();
    final phone = mobileNumberController.text.trim();

    String? nameError;
    String? phoneError;

    // Name validation
    if (name.isEmpty) {
      nameError = "Name is required";
    } else if (name.length < 3) {
      nameError = "Name must be at least 3 characters";
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      nameError = "Only alphabets allowed";
    }

    // Phone validation
    if (phone.isEmpty) {
      phoneError = "Mobile number is required";
    } else if (phone.length < 7 || phone.length > 15 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError = "Enter a valid number with 7 to 15 digits";
    }

    setState(() {
      _nameErrorMessage = nameError;
      _phoneErrorMessage = phoneError;
    });
    return nameError == null && phoneError == null;
  }
}
