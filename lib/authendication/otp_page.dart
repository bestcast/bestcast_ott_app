import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../components/widgets/button_widgets.dart';
import '../register/who_watching_page.dart';

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
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final AppUtils appUtils = AppUtils();

  late final String registerContent;
  late final String otpMessageType;
  late final String countryCode;

  bool _resendButtonEnabled = false;
  bool _isLoading = false;
  bool clearText = false;
  String? _errorMessage;
  String _otp = "";

  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    registerContent = widget.otpEmailorPhone;
    otpMessageType = widget.getOtpMessageType ?? "sms";
    countryCode = widget.getCountryCode ?? "+91";
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _resendButtonEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),

                // Brand Logo / Emblem
                Center(
                  child: Image.asset(
                    'images/logo_bestcast.png',
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 36),

                // Heading & Subtitle
                const Text(
                  'Verify Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Phone recipient with Edit button
                Row(
                  children: [
                    const Text(
                      'Code sent to ',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      registerContent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: AppDefaultColors.primaryRed,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Sleek Dark OTP Input Boxes
                Center(
                  child: OtpTextField(
                    numberOfFields: 4,
                    fieldWidth: 64,
                    cursorColor: AppDefaultColors.primaryRed,
                    borderWidth: 1.5,
                    borderRadius: BorderRadius.circular(12),
                    showFieldAsBox: true,
                    filled: true,
                    fillColor: const Color(0xFF141416),
                    borderColor: Colors.white.withValues(alpha: 0.12),
                    enabledBorderColor: Colors.white.withValues(alpha: 0.12),
                    focusedBorderColor: AppDefaultColors.primaryRed,
                    clearText: clearText,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    onCodeChanged: (String code) {
                      setState(() {
                        _otp = code;
                        _errorMessage = null;
                      });
                    },
                    onSubmit: (String verificationCode) {
                      setState(() {
                        _otp = verificationCode;
                        _errorMessage = null;
                      });
                      _onVerifyPressed();
                    },
                  ),
                ),

                // Inline Error Display
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Submit Button
                SendButtonWidgets(
                  "Verify & Continue",
                  isLoading: _isLoading,
                  onPressed: _onVerifyPressed,
                ),

                const SizedBox(height: 28),

                // Resend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    if (_resendButtonEnabled)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          resendOTP(registerContent, otpMessageType, countryCode);
                        },
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: AppDefaultColors.primaryRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Resend in ${_secondsRemaining}s',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onVerifyPressed() async {
    HapticFeedback.lightImpact();

    if (_otp.length < 4) {
      setState(() => _errorMessage = "Please enter the 4-digit code");
      return;
    }

    if (await CommonWidget().isInternetConnectivity()) {
      verifyOTP(registerContent, _otp);
    } else {
      if (!mounted) return;
      CommonWidget().showSnackBar(
        context,
        ContentType.warning,
        "No Connection",
        "Please check your internet connection and try again.",
      );
    }
  }

  void verifyOTP(String email, String otp) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final pref = await SharedPreferences.getInstance();
    final refCode =
        pref.getString(AppPreferences.bmpReferralCode) ?? pref.getString(AppPreferences.refferer);

    final Map<String, dynamic> postValues = {
      'email': email,
      'otp': otp,
      'device': "mobile",
    };
    if (refCode != null && refCode.isNotEmpty) {
      postValues['ref'] = refCode;
    }

    try {
      final response = await ApiServices().postRequest(AppConfig.verifyOtp, postValues);

      if (!mounted) return;
      final String jsonsDataString = response.body.toString();

      if (response.statusCode == 200) {
        final jsonReponse = jsonDecode(jsonsDataString);
        final String status = jsonReponse['status'] ?? "";

        if (status == "success") {
          final results = jsonReponse['results'];
          final user = results?['user'];
          if (user != null && user is Map) {
            await pref.setString(AppPreferences.id, (user['id'] ?? '').toString());
            await pref.setString(AppPreferences.email, (user['email'] ?? '').toString());
            await pref.setString(AppPreferences.phone, (user['phone'] ?? '').toString());
            await pref.setString(AppPreferences.name, (user['name'] ?? '').toString());
            await pref.setString(AppPreferences.firstname, (user['firstname'] ?? '').toString());
            await pref.setString(AppPreferences.lastname, (user['lastname'] ?? '').toString());
            await pref.setString(AppPreferences.dob, (user['dob'] ?? '').toString());
            await pref.setString(AppPreferences.gender, (user['gender'] ?? '').toString());
            await pref.setString(AppPreferences.plan, (user['plan'] ?? '').toString());
            await pref.setString(AppPreferences.plan_expiry, (user['plan_expiry'] ?? '').toString());
            await pref.setString(AppPreferences.photo, (user['photo'] ?? '').toString());
            await pref.setString(AppPreferences.otp, (user['otp'] ?? '').toString());
            await pref.setString(AppPreferences.tvcode, (user['tvcode'] ?? '').toString());
            await pref.setString(AppPreferences.referal_code, (user['referal_code'] ?? '').toString());
            await pref.setString(AppPreferences.credits_used, (user['credits_used'] ?? '').toString());
            await pref.setString(AppPreferences.refferer, (user['refferer'] ?? '').toString());

            final bmpReferralCode = user['bmp_referral_code']?.toString();
            if (bmpReferralCode != null &&
                bmpReferralCode.isNotEmpty &&
                bmpReferralCode != "null") {
              await pref.setString(AppPreferences.bmpReferralCode, bmpReferralCode);
              await pref.setString(AppPreferences.refferer, bmpReferralCode);
            }
          }

          final String token = (results?['token'] ?? '').toString();
          await pref.setString(AppPreferences.token, token);
          await pref.setBool(AppPreferences.loggedStatus, true);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WhosWatchingPage(activityType: "New"),
            ),
          );
        } else {
          final String message = jsonReponse['message'] ?? "Invalid OTP. Please try again.";
          setState(() => _errorMessage = message);
        }
      } else {
        setState(() => _errorMessage = "Invalid verification code");
      }
    } catch (e) {
      if (!mounted) return;
      CommonWidget().showSnackBar(
        context,
        ContentType.failure,
        "Error",
        "Something went wrong. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void resendOTP(String email, String otpMessageType, String countryCode) async {
    setState(() => _isLoading = true);
    final postValues = {
      'email': email,
      "otp_message_type": otpMessageType,
      "country_code": countryCode,
    };

    try {
      final response = await ApiServices().postRequest(AppConfig.sendOtp, postValues);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonReponse = jsonDecode(response.body.toString());
        final String status = jsonReponse['status'] ?? "";

        if (status == "success") {
          appUtils.showToast("OTP has been resent successfully.");
          setState(() {
            _otp = "";
            _resendButtonEnabled = false;
            _secondsRemaining = 30;
            _errorMessage = null;
          });
          _startTimer();
        } else {
          setState(() {
            _errorMessage = jsonReponse['message'] ?? "Failed to resend code";
          });
        }
      } else {
        CommonWidget().showSnackBar(
          context,
          ContentType.failure,
          "Error",
          "Failed to resend OTP. Please try again.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      CommonWidget().showSnackBar(
        context,
        ContentType.failure,
        "Error",
        "Something went wrong. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
