import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bestcaststudios/authendication/login_page.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';

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
  String maskedIdentifier = "";
  String _token = "";

  @override
  void initState() {
    super.initState();
    _formatMaskedIdentifier();
    getInitalValue();
  }

  void _formatMaskedIdentifier() {
    final String raw = widget.email.trim();
    if (raw.isEmpty) {
      maskedIdentifier = "";
      return;
    }

    if (raw.contains('@')) {
      final parts = raw.split('@');
      final username = parts[0];
      final domain = parts.length > 1 ? parts[1] : '';

      String maskedUser;
      if (username.length <= 2) {
        maskedUser = '${username[0]}*';
      } else {
        final prefix = username.substring(0, 2);
        maskedUser = '$prefix${'*' * (username.length - 2)}';
      }
      maskedIdentifier = domain.isNotEmpty ? '$maskedUser@$domain' : maskedUser;
    } else {
      if (raw.length <= 4) {
        maskedIdentifier = raw;
      } else {
        final start = raw.substring(0, (raw.length > 6 ? 4 : 2));
        final end = raw.substring(raw.length - 2);
        maskedIdentifier = '$start${'*' * (raw.length - start.length - 2)}$end';
      }
    }
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _token = pref.getString(AppPreferences.token) ?? '';
      });
    }
  }

  Future<void> _handleBackToLogin() async {
    await getLogout(_token);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackToLogin();
        }
      },
      child: LoaderOverlay(
        child: Scaffold(
          backgroundColor: AppDefaultColors.appColor,
          appBar: AppBar(
            backgroundColor: AppDefaultColors.appColor,
            elevation: 0,
            leading: BackButton(
              color: Colors.white,
              onPressed: _handleBackToLogin,
            ),
            title: SizedBox(
              height: 28,
              child: const Image(image: AssetImage("images/logo_bestcast.png")),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Device Limit Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppDefaultColors.warningYellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppDefaultColors.warningYellow.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.devices_other_rounded,
                    color: AppDefaultColors.warningYellow,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Device Limit Reached',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle / Limit Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppDefaultColors.primaryRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppDefaultColors.primaryRed.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Maximum 6 Active Devices / Sessions Allowed',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Explanation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppDefaultColors.hardDarkGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white12,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (maskedIdentifier.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              size: 20,
                              color: AppDefaultColors.textLightGray,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                maskedIdentifier,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 24),
                      ],
                      const Text(
                        'This Bestcast account is currently active on 6 different devices or login sessions.',
                        style: TextStyle(
                          color: AppDefaultColors.textLightGray,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'How to access on this device:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInstructionStep(
                        icon: Icons.logout_rounded,
                        text:
                            'Sign out from any of your other 6 active phones, TVs, tablets, or browser sessions.',
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                        icon: Icons.login_rounded,
                        text:
                            'Once a slot is freed, sign back in on this device to start streaming immediately.',
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                        icon: Icons.swap_horiz_rounded,
                        text:
                            'Or tap "Sign Out of This Device" below to switch to another account.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDefaultColors.primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => getLogout(_token),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Sign Out of This Device",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Need Another Account Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppDefaultColors.darkGray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white10,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Need your own account?",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "bestcast.co/register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          launchUrlStart(url: "https://bestcast.co/register");
                        },
                        child: const Text(
                          'Go to Link',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppDefaultColors.warningYellow),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppDefaultColors.textLightGray,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Future<void> launchUrlStart({required String url}) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
