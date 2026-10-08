import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config/app_preferences.dart';
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

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;

  String? _nameErrorMessage;
  String? _phoneErrorMessage;

  SingingCharacter character = SingingCharacter.whatsAppOtp;
  final TextEditingController userNameController = TextEditingController();
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
    userNameController.dispose();
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
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join Bestcast to start streaming movies and exclusive series.',
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

                // Full Name Input Field
                TextfieldWidget(
                  label: 'Full Name',
                  controller: userNameController,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ),
                if (_nameErrorMessage != null) _buildError(_nameErrorMessage!),

                const SizedBox(height: 14),

                // Mobile Number Input Field
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
                if (_phoneErrorMessage != null) _buildError(_phoneErrorMessage!),

                const SizedBox(height: 28),

                // Submit Button
                SendButtonWidgets(
                  "Create Account",
                  isLoading: isLoading,
                  onPressed: _onSubmitPressed,
                ),

                const SizedBox(height: 28),

                // Already Have Account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        AuthNavigator.navigateWithFade(context, const LoginPage());
                      },
                      child: const Text(
                        'Log In',
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

                // Terms disclaimer
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
                  _phoneErrorMessage = null;
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
                  _phoneErrorMessage = null;
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

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, left: 4.0),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 14),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmitPressed() async {
    HapticFeedback.lightImpact();
    if (!_validateInputs()) return;

    if (await CommonWidget().isInternetConnectivity()) {
      createAccount(
        character,
        userNameController.text.trim(),
        getCountryCode.text,
        mobileNumberController.text.trim(),
      );
    } else {
      if (!mounted) return;
      CommonWidget().showSnackBar(
        context,
        ContentType.failure,
        "Error",
        "No Internet Connection",
      );
    }
  }

  void createAccount(
    SingingCharacter character,
    String userName,
    String countryCode,
    String mobileNumber,
  ) async {
    setState(() => isLoading = true);
    final otpMessageType = _getOtpType(character);
    final resolvedCountryCode =
        (countryCode.isEmpty || otpMessageType == "sms") ? "+91" : countryCode;

    final pref = await SharedPreferences.getInstance();
    final referrerCode = pref.getString(AppPreferences.refferer) ?? '';

    final postValues = {
      "phone": mobileNumber,
      "name": userName,
      "refferer": referrerCode,
      "device": "mobile",
      "otp_message_type": otpMessageType,
      "country_code": resolvedCountryCode,
    };

    try {
      final response =
          await ApiServices().postRequest(AppConfig.registerUrl, postValues);

      if (!mounted) return;
      final body = response.body.toString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(body);
        if (jsonResponse['status'] == "success") {
          AuthNavigator.navigateWithFade(
            context,
            OTPactivity(
              otpEmailorPhone: mobileNumber,
              getOtpMessageType: otpMessageType,
              getCountryCode: resolvedCountryCode,
            ),
          );
        } else {
          CommonWidget().showSnackBar(
            context,
            ContentType.failure,
            "Failed",
            jsonResponse['message'] ?? "Something went wrong",
          );
        }
      } else if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(body);
        setState(() {
          _nameErrorMessage = jsonResponse['errors']?['name']?[0];
          _phoneErrorMessage = jsonResponse['errors']?['phone']?[0];
        });
        CommonWidget().showSnackBar(
          context,
          ContentType.failure,
          "Failed",
          jsonResponse['message'] ?? "Something went wrong",
        );
      } else {
        CommonWidget().showSnackBar(
          context,
          ContentType.failure,
          "Error",
          "Server error occurred",
        );
      }
    } catch (e) {
      if (!mounted) return;
      CommonWidget().showSnackBar(
        context,
        ContentType.failure,
        "Error",
        "The phone has already been taken or network error occurred.",
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
    } else if (phone.length < 7 ||
        phone.length > 15 ||
        !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError = "Enter a valid number with 7 to 15 digits";
    }

    setState(() {
      _nameErrorMessage = nameError;
      _phoneErrorMessage = phoneError;
    });

    return nameError == null && phoneError == null;
  }
}
