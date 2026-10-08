import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../app_config/app_strings.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/otp_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../components/functions/navigation_fun.dart';
import '../components/widgets/button_widgets.dart';
import '../components/widgets/textfield_widgets.dart';
import '../register/register_page.dart';

enum SingingCharacter { smsOtp, whatsAppOtp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;
  String? _errorMessage;

  SingingCharacter character = SingingCharacter.whatsAppOtp;

  final TextEditingController getCountryCode = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    getCountryCode.dispose();
    mobileNumberController.dispose();
    super.dispose();
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
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your phone number to sign in and continue watching.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                // Sleek Delivery Mode Selector (Segmented Pill Switcher)
                _buildDeliverySelector(),

                const SizedBox(height: 18),

                // Phone Input Field
                if (character == SingingCharacter.whatsAppOtp)
                  WhatsApptextfieldWidget(
                    controller: mobileNumberController,
                    onChanged: (phone) {
                      getCountryCode.text = phone.countryCode;
                    },
                  )
                else
                  SMStextfieldWidget(
                    controller: mobileNumberController,
                  ),

                // Inline Error Display
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),

                // Primary Submit Button
                SendButtonWidgets(
                  "Continue",
                  isLoading: isLoading,
                  onPressed: _onSendPressed,
                ),

                const SizedBox(height: 28),

                // New User Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "New to Bestcast? ",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        AuthNavigator.navigateWithFade(context, const RegisterPage());
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppDefaultColors.primaryRed,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Subtle terms disclaimer
                const Center(
                  child: Text(
                    'By continuing, you agree to Bestcast\'s Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliverySelector() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentItem(
              title: "WhatsApp",
              icon: Icons.chat_bubble_outline_rounded,
              isSelected: character == SingingCharacter.whatsAppOtp,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  character = SingingCharacter.whatsAppOtp;
                  _errorMessage = null;
                });
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSegmentItem(
              title: "SMS",
              icon: Icons.sms_outlined,
              isSelected: character == SingingCharacter.smsOtp,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  character = SingingCharacter.smsOtp;
                  _errorMessage = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF24242A) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white38,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSendPressed() async {
    HapticFeedback.lightImpact();
    final String emailorPhone = mobileNumberController.text.trim();

    if (emailorPhone.isEmpty) {
      setState(() => _errorMessage = "Please enter your mobile number");
      return;
    }

    if (!appUtils.validateEmail(emailorPhone) &&
        !appUtils.isNumericUsing_tryParse(emailorPhone)) {
      setState(() => _errorMessage = AppStrings.errorMessagePhoneOrEmail);
      return;
    }

    setState(() => _errorMessage = null);
    verifyAccountEmailorPhone(character, getCountryCode.text, emailorPhone);
  }

  void verifyAccountEmailorPhone(
      SingingCharacter character, String countryCode, String input) async {
    setState(() => isLoading = true);

    try {
      final otpMessageType = _getOtpType(character);
      final resolvedCountryCode =
          (countryCode.isEmpty || otpMessageType == "sms") ? "+91" : countryCode;

      final postValues = {
        'email': input,
        "otp_message_type": otpMessageType,
        "country_code": resolvedCountryCode
      };

      final response =
          await ApiServices().postRequest(AppConfig.sendOtp, postValues);

      if (!mounted) return;

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final status = jsonResponse['status'];

        if (status == "success") {
          AuthNavigator.navigateWithFade(
            context,
            OTPactivity(
              otpEmailorPhone: input,
              getOtpMessageType: otpMessageType,
              getCountryCode: resolvedCountryCode,
            ),
          );
        } else {
          setState(() => _errorMessage = jsonResponse['message'] ?? "Verification failed");
        }
      } else if (response.statusCode == 201 &&
          jsonResponse['status'] == "error") {
        setState(() => _errorMessage = jsonResponse['message'] ?? "Verification failed");
      } else {
        CommonWidget().showSnackBar(
          context,
          ContentType.failure,
          "Error",
          jsonResponse['message'] ?? response.toString(),
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
        setState(() => isLoading = false);
      }
    }
  }

  String _getOtpType(SingingCharacter character) {
    switch (character) {
      case SingingCharacter.whatsAppOtp:
        return "whatsapp";
      case SingingCharacter.smsOtp:
        return "sms";
    }
  }
}
