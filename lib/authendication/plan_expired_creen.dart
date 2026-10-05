import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_config/app_preferences.dart';
import '../app_config/appconfig.dart';
import '../common_files/app_default_colors.dart';
import '../plan_details/plan_details.dart';

class PlanExpiredScreen extends StatefulWidget {
  const PlanExpiredScreen({super.key});

  @override
  State<PlanExpiredScreen> createState() => _PlanExpiredScreenState();
}

class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _logout() async {
    try {
      final pref = await SharedPreferences.getInstance();
      const sessionKeys = [
        AppPreferences.loggedStatus,
        AppPreferences.id,
        AppPreferences.email,
        AppPreferences.phone,
        AppPreferences.name,
        AppPreferences.firstname,
        AppPreferences.lastname,
        AppPreferences.dob,
        AppPreferences.gender,
        AppPreferences.plan,
        AppPreferences.plan_expiry,
        AppPreferences.plan_device_status,
        AppPreferences.plan_status,
        AppPreferences.photo,
        AppPreferences.otp,
        AppPreferences.tvcode,
        AppPreferences.token,
        AppPreferences.accountCreatedStatus,
        AppPreferences.profileID,
        AppPreferences.profileName,
        AppPreferences.profilePictureID,
        AppPreferences.profilePictureTitle,
        AppPreferences.profilePicture,
        AppPreferences.isChild,
      ];
      for (final key in sessionKeys) {
        await pref.remove(key);
      }
    } catch (_) {}

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, 'mainscreen', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'mainscreen', (route) => false);
              }
            },
          ),
          actions: [
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/plan_expired.png',
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Plan has expired',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: AppDefaultColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your subscription plan has ended. Renew your account to continue enjoying unlimited streaming on Bestcast.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AppDefaultColors.textLightGray,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Primary Action: View Plans & Renew in-app
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(50),
                        backgroundColor: AppDefaultColors.appRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlanDetailsPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'View Plans & Renew',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Secondary Action: Renew via Website
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size.fromHeight(48),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        launchUrlStart(url: AppConfig.BaseUrl);
                      },
                      child: const Text(
                        'Renew via Website',
                        style: TextStyle(
                          color: AppDefaultColors.textLightGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> launchUrlStart({required String url}) async {
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Launch url error: $e');
    }
  }
}
