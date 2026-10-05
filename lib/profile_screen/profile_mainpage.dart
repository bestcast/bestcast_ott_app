import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bestcaststudios/Dashboard/Models/Usermovies.dart';
import 'package:bestcaststudios/download_files/dowloadmoviefiles.dart';
import 'package:bestcaststudios/register/who_watching_page.dart';
import 'package:bestcaststudios/webview_pages/bestcast_webviewpages.dart';
import '../Dashboard/Models/Movie.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../app_settings/appsettingspage.dart';
import '../authendication/login_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../main_screen.dart';
import '../streamingpalyer/video_player.dart';

class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({super.key});

  @override
  State<ProfileMainPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  final AppUtils appUtils = AppUtils();

  List<Movies> moviesMyListModel = [];
  List<Movies> moviesWatchingModel = [];
  List<Movies> moviesRecentlyModel = [];

  bool isLoading = false;
  bool loggedStatus = false;
  String _token = "";

  String profileName = "";
  String profilePicture = "";
  String profileID = "";
  String profilePictureID = "";
  String userPhone = "";
  String userEmail = "";
  String userPlan = "";

  String version = "1.0.0";
  String buildNumber = "1";

  @override
  void initState() {
    super.initState();
    getInitalValue();
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';
      loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;

      profileName = pref.getString(AppPreferences.profileName) ?? '';
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
      profileID = pref.getString(AppPreferences.profileID) ?? '';
      profilePictureID = pref.getString(AppPreferences.profilePictureID) ?? '';
      userPhone = pref.getString(AppPreferences.phone) ?? '';
      userEmail = pref.getString(AppPreferences.email) ?? '';
      userPlan = pref.getString(AppPreferences.plan) ?? '';
    });

    if (loggedStatus && _token.isNotEmpty) {
      getTokenValid(_token);
      getUserMoviesLitMyList(_token, profileID, "1");
    }

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    } catch (_) {}
  }

  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type.toString() == "Barcode" && result.rawContent.isNotEmpty) {
        setqrcode(_token, result.rawContent.toString());
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Scanner canceled or unavailable");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          backgroundColor: AppDefaultColors.appColor,
          elevation: 0,
          titleSpacing: 20,
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            if (loggedStatus)
              IconButton(
                tooltip: "Scan TV QR Code",
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: _scanQRCode,
              ),
            const SizedBox(width: 12),
          ],
        ),
        body: isLoading && moviesMyListModel.isEmpty && moviesWatchingModel.isEmpty
            ? const Center(child: LoadingWidget())
            : RefreshIndicator(
                color: AppDefaultColors.primaryRed,
                backgroundColor: const Color(0xFF1E1E26),
                onRefresh: () async {
                  await getInitalValue();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card / Hero Section
                      _buildProfileHero(),
                      const SizedBox(height: 20),

                      // Quick Action Bar (Downloads & TV Login)
                      _buildQuickActions(),
                      const SizedBox(height: 24),

                      // Continue Watching Carousel
                      if (moviesWatchingModel.isNotEmpty) ...[
                        _buildSectionHeader("Continue Watching", moviesWatchingModel.length),
                        const SizedBox(height: 12),
                        _buildContinueWatchingList(),
                        const SizedBox(height: 24),
                      ],

                      // My List Carousel
                      if (moviesMyListModel.isNotEmpty) ...[
                        _buildSectionHeader("My List", moviesMyListModel.length),
                        const SizedBox(height: 12),
                        _buildMyListCarousel(),
                        const SizedBox(height: 24),
                      ],

                      // Recently Watched Carousel
                      if (moviesRecentlyModel.isNotEmpty) ...[
                        _buildSectionHeader("Recently Watched", moviesRecentlyModel.length),
                        const SizedBox(height: 12),
                        _buildRecentlyWatchedList(),
                        const SizedBox(height: 24),
                      ],

                      // Menu Group (Account, Settings, Help, etc.)
                      _buildSettingsGroup(),
                      const SizedBox(height: 28),

                      // App Version Footer
                      Center(
                        child: Text(
                          "Bestcast OTT • v$version ($buildNumber)",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12.0,
                            letterSpacing: 0.3,
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

  // -------------------------------------------------------------
  // PROFILE HERO CARD
  // -------------------------------------------------------------
  Widget _buildProfileHero() {
    if (!loggedStatus) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF15151C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppDefaultColors.primaryRed.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppDefaultColors.primaryRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Welcome to Bestcast",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Sign in to access your watchlist, downloads, and continue watching anywhere.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((_) => getInitalValue());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDefaultColors.primaryRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text(
                  "Sign In or Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final displayName = profileName.isNotEmpty
        ? profileName
        : (userPhone.isNotEmpty ? userPhone : "Bestcast User");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Profile Avatar with subtle glowing border
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppDefaultColors.primaryRed, width: 2),
            ),
            child: ClipOval(
              child: profilePicture.isNotEmpty
                  ? Image.network(
                      profilePicture,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _avatarFallback(displayName),
                    )
                  : _avatarFallback(displayName),
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                if (userPhone.isNotEmpty)
                  Text(
                    userPhone,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    "Bestcast Member",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                if (userPlan.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppDefaultColors.primaryRed.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      userPlan.toUpperCase(),
                      style: const TextStyle(
                        color: AppDefaultColors.primaryRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Switch Profile Pill Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WhosWatchingPage(activityType: "Switch"),
                ),
              ).then((_) => getInitalValue());
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Switch",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "B";
    return Container(
      color: const Color(0xFF22222E),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // QUICK ACTIONS (Downloads & TV Login)
  // -------------------------------------------------------------
  Widget _buildQuickActions() {
    return Row(
      children: [
        // Downloads Card
        Expanded(
          child: _quickActionTile(
            icon: Icons.download_for_offline_rounded,
            iconColor: AppDefaultColors.primaryRed,
            title: "Downloads",
            subtitle: "Watch offline",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DownloadMovieFiles()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // TV Login Card
        Expanded(
          child: _quickActionTile(
            icon: Icons.tv_rounded,
            iconColor: Colors.white,
            title: "TV Login",
            subtitle: "Scan QR code",
            onTap: _scanQRCode,
          ),
        ),
      ],
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF15151C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SECTION HEADERS
  // -------------------------------------------------------------
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // CONTINUE WATCHING CAROUSEL
  // -------------------------------------------------------------
  Widget _buildContinueWatchingList() {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: moviesWatchingModel.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = moviesWatchingModel[index];
          double progress = 0.0;
          if (movie.usermovies != null && movie.usermovies!.watchedPercent != null) {
            double? parsed = double.tryParse(movie.usermovies!.watchedPercent.toString());
            if (parsed != null) {
              progress = (parsed / 100.0).clamp(0.0, 1.0);
            }
          }

          return SizedBox(
            width: 130,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoApp(getMovieID: movie.id.toString()),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster with Play Overlay & Progress
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 145,
                          width: 130,
                          child: FadeInImage(
                            placeholder: const AssetImage("images/default_portrate_small.jpg"),
                            image: NetworkImage(movie.portraitsmall.toString()),
                            imageErrorBuilder: (_, __, ___) => Image.asset(
                              'images/default_portrate_small.jpg',
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Play icon centered
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Bottom Progress bar
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                          child: LinearProgressIndicator(
                            value: progress > 0 ? progress : 0.35,
                            minHeight: 3.5,
                            color: AppDefaultColors.primaryRed,
                            backgroundColor: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Title & More options
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => getMovieDetailsBottomWidget(movie, 1),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // MY LIST CAROUSEL
  // -------------------------------------------------------------
  Widget _buildMyListCarousel() {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: moviesMyListModel.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = moviesMyListModel[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoApp(getMovieID: movie.id.toString()),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 110,
                height: 165,
                child: FadeInImage(
                  placeholder: const AssetImage("images/default_portrate_small.jpg"),
                  image: NetworkImage(movie.portraitsmall.toString()),
                  imageErrorBuilder: (_, __, ___) => Image.asset(
                    'images/default_portrate_small.jpg',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // RECENTLY WATCHED CAROUSEL
  // -------------------------------------------------------------
  Widget _buildRecentlyWatchedList() {
    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: moviesRecentlyModel.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = moviesRecentlyModel[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoApp(getMovieID: movie.id.toString()),
                ),
              );
            },
            child: SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 180,
                      height: 105,
                      child: FadeInImage(
                        placeholder: const AssetImage("images/default_landscape.jpg"),
                        image: NetworkImage(movie.thumbnail.toString()),
                        imageErrorBuilder: (_, __, ___) => Image.asset(
                          'images/default_landscape.jpg',
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final encodedTitle = Uri.encodeComponent(movie.title.toString());
                          Share.share(
                            'Watch ${movie.title} on Bestcast OTT:\n${AppConfig.BaseUrl}/search?search=$encodedTitle',
                          );
                        },
                        child: Icon(
                          Icons.share_outlined,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => getMovieDetailsBottomWidget(movie, 2),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // SETTINGS & MENU GROUP
  // -------------------------------------------------------------
  Widget _buildSettingsGroup() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15151C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          if (loggedStatus) ...[
            _menuTile(
              icon: Icons.people_outline_rounded,
              title: "Manage Profiles",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhosWatchingPage(activityType: "Manage"),
                  ),
                ).then((_) => getInitalValue());
              },
            ),
            _menuDivider(),
            _menuTile(
              icon: Icons.person_outline_rounded,
              title: "Account",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BestcastWebView(url: "account"),
                  ),
                );
              },
            ),
            _menuDivider(),
            _menuTile(
              icon: Icons.card_giftcard_rounded,
              title: "BMP Referral Program",
              onTap: _openBMPWebsite,
            ),
            _menuDivider(),
          ],
          _menuTile(
            icon: Icons.settings_outlined,
            title: "App Settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppSettingsPage()),
              );
            },
          ),
          _menuDivider(),
          _menuTile(
            icon: Icons.help_outline_rounded,
            title: "Help & Support",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BestcastWebView(url: "help"),
                ),
              );
            },
          ),
          if (loggedStatus) ...[
            _menuDivider(),
            _menuTile(
              icon: Icons.logout_rounded,
              title: "Sign Out",
              titleColor: AppDefaultColors.primaryRed,
              iconColor: AppDefaultColors.primaryRed,
              showArrow: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => showSignOutAlertDialog(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.white.withOpacity(0.85),
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.25),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      endIndent: 16,
      color: Colors.white.withOpacity(0.05),
    );
  }

  // -------------------------------------------------------------
  // MOVIE DETAILS BOTTOM SHEET
  // -------------------------------------------------------------
  void getMovieDetailsBottomWidget(Movies moviesModel, int type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        moviesModel.title.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: Colors.white),
                  title: const Text(
                    "Details & More",
                    style: TextStyle(color: Colors.white, fontSize: 14.5),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoApp(getMovieID: moviesModel.id.toString()),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: Colors.white),
                  title: const Text(
                    "Share with friends",
                    style: TextStyle(color: Colors.white, fontSize: 14.5),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    final encodedTitle = Uri.encodeComponent(moviesModel.title.toString());
                    Share.share(
                      'Watch ${moviesModel.title} on Bestcast OTT:\n${AppConfig.BaseUrl}/search?search=$encodedTitle',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppDefaultColors.primaryRed),
                  title: const Text(
                    "Remove from row",
                    style: TextStyle(color: AppDefaultColors.primaryRed, fontSize: 14.5),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Map<String, int> postValues = (type == 1)
                        ? {'watching': 0, 'watch_time': 0, 'watched_percent': 0}
                        : {'watched': 0};
                    setUserMovies(_token, profileID, moviesModel.id.toString(), postValues, type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // SIGN OUT DIALOG
  // -------------------------------------------------------------
  Widget showSignOutAlertDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Sign Out',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        "Are you sure you want to sign out of Bestcast on this device?",
        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppDefaultColors.primaryRed,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            Navigator.pop(context);
            if (await CommonWidget().isInternetConnectivity()) {
              Fluttertoast.showToast(msg: "Signing out...");
              getLogout(_token);
            } else {
              if (mounted) {
                CommonWidget().showSnackBar(
                  context,
                  ContentType.warning,
                  "Check your internet connection.",
                  "",
                );
              }
            }
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // API & BACKEND SERVICES
  // -------------------------------------------------------------
  Future<void> _openBMPWebsite() async {
    final Uri url = Uri.parse('https://partners.bestcast.co/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: "Could not open website");
    }
  }

  void setqrcode(String token, String qrcode) async {
    setState(() {
      context.loaderOverlay.show();
      isLoading = true;
    });

    final postValues = {'qrcode': qrcode};
    ApiServices().postRequestToken(AppConfig.setqrcode, postValues, token).then((response) async {
      if (mounted) {
        context.loaderOverlay.hide();
        setState(() {
          isLoading = false;
        });
      }

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "TV login successful!");
      } else {
        if (mounted) {
          CommonWidget().showSnackBar(
            context,
            ContentType.failure,
            "Error",
            "Could not link TV account",
          );
        }
      }
    }).catchError((_) {
      if (mounted) {
        context.loaderOverlay.hide();
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void getUserMoviesLitMyList(String token, String profileId, String searchType) async {
    moviesMyListModel.clear();
    ApiServices().getRequestData("${AppConfig.usermovieslist}$profileId&mylist=$searchType", token).then((response) async {
      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          if (responseData["data"] != null && responseData["data"] is List) {
            for (var movieData in responseData["data"]) {
              Usermovies? usermovies;
              if (movieData['usermovies'] != null &&
                  movieData['usermovies'] is Map &&
                  (movieData['usermovies'] as Map).isNotEmpty) {
                var um = movieData['usermovies'];
                usermovies = Usermovies(
                  id: um["id"]?.toString() ?? "",
                  movieId: (um["movieId"] ?? um["movie_id"])?.toString() ?? "",
                  mylist: um["mylist"]?.toString() ?? "",
                  likes: um["likes"]?.toString() ?? "",
                  watchTime: (um["watchTime"] ?? um["watch_time"])?.toString() ?? "",
                  watching: um["watching"]?.toString() ?? "",
                  watched: um["watched"]?.toString() ?? "",
                  watchedPercent: (um["watchedPercent"] ?? um["watched_percent"])?.toString() ?? "",
                  viewed: um["viewed"]?.toString() ?? "",
                );
              }

              String thumbnailUrl = "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
              String portraitsmallUrl = "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
              String portraitUrl = "${AppConfig.BaseUrl}/${movieData["portrait"]}";

              moviesMyListModel.add(Movies(
                id: movieData["id"].toString(),
                title: movieData["title"].toString(),
                movie_access: movieData["movie_access"]?.toString() ?? "",
                topten: movieData["topten"]?.toString() ?? "",
                trailer: movieData["trailer"]?.toString() ?? "",
                certificate: movieData["certificate"]?.toString() ?? "",
                duration: movieData["duration"]?.toString() ?? "",
                tagText: movieData["tag_text"]?.toString() ?? "",
                publishedDate: movieData["published_date"]?.toString() ?? "",
                userlist: movieData["userlist"]?.toString() ?? "",
                userlike: movieData["userlike"]?.toString() ?? "",
                thumbnail: thumbnailUrl,
                portraitsmall: portraitsmallUrl,
                portrait: portraitUrl,
                usermovies: usermovies,
              ));
            }
          }

          if (mounted) {
            setState(() {});
          }

          if (moviesMyListModel.isEmpty && searchType.isNotEmpty) {
            getUserMoviesLitMyList(_token, profileID, "");
          } else {
            getUserMoviesLitWatching(_token, profileID, "1");
          }
        } catch (e) {
          print('MylistsMovieException: $e');
        }
      }
    });
  }

  void getUserMoviesLitWatching(String token, String profileId, String searchType) async {
    moviesWatchingModel.clear();
    ApiServices().getRequestData("${AppConfig.usermovieslist}$profileId&watching=$searchType", token).then((response) async {
      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          if (responseData["data"] != null && responseData["data"] is List) {
            for (var movieData in responseData["data"]) {
              Usermovies? usermovies;
              if (movieData['usermovies'] != null &&
                  movieData['usermovies'] is Map &&
                  (movieData['usermovies'] as Map).isNotEmpty) {
                var um = movieData['usermovies'];
                usermovies = Usermovies(
                  id: um["id"]?.toString() ?? "",
                  movieId: (um["movie_id"] ?? um["movieId"])?.toString() ?? "",
                  mylist: um["mylist"]?.toString() ?? "",
                  likes: um["likes"]?.toString() ?? "",
                  watchTime: (um["watch_time"] ?? um["watchTime"])?.toString() ?? "",
                  watching: um["watching"]?.toString() ?? "",
                  watched: um["watched"]?.toString() ?? "",
                  watchedPercent: (um["watched_percent"] ?? um["watchedPercent"])?.toString() ?? "",
                  viewed: um["viewed"]?.toString() ?? "",
                );
              }

              String thumbnailUrl = "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
              String portraitsmallUrl = "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
              String portraitUrl = "${AppConfig.BaseUrl}/${movieData["portrait"]}";

              moviesWatchingModel.add(Movies(
                id: movieData["id"].toString(),
                title: movieData["title"].toString(),
                movie_access: movieData["movie_access"]?.toString() ?? "",
                topten: movieData["topten"]?.toString() ?? "",
                trailer: movieData["trailer"]?.toString() ?? "",
                certificate: movieData["certificate"]?.toString() ?? "",
                duration: movieData["duration"]?.toString() ?? "",
                tagText: movieData["tag_text"]?.toString() ?? "",
                publishedDate: movieData["published_date"]?.toString() ?? "",
                userlist: movieData["userlist"]?.toString() ?? "",
                userlike: movieData["userlike"]?.toString() ?? "",
                thumbnail: thumbnailUrl,
                portraitsmall: portraitsmallUrl,
                portrait: portraitUrl,
                usermovies: usermovies,
              ));
            }
          }

          if (mounted) {
            setState(() {});
          }

          if (moviesWatchingModel.isEmpty && searchType.isNotEmpty) {
            getUserMoviesLitWatching(_token, profileID, "");
          } else {
            getUserMoviesLitRWatched(_token, profileID, "1");
          }
        } catch (e) {
          print('WatchingMovieException: $e');
        }
      }
    });
  }

  void getUserMoviesLitRWatched(String token, String profileId, String searchType) async {
    moviesRecentlyModel.clear();
    ApiServices().getRequestData("${AppConfig.usermovieslist}$profileId&watched=$searchType", token).then((response) async {
      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          if (responseData["data"] != null && responseData["data"] is List) {
            for (var movieData in responseData["data"]) {
              Usermovies? usermovies;
              if (movieData['usermovies'] != null &&
                  movieData['usermovies'] is Map &&
                  (movieData['usermovies'] as Map).isNotEmpty) {
                var um = movieData['usermovies'];
                usermovies = Usermovies(
                  id: um["id"]?.toString() ?? "",
                  movieId: (um["movieId"] ?? um["movie_id"])?.toString() ?? "",
                  mylist: um["mylist"]?.toString() ?? "",
                  likes: um["likes"]?.toString() ?? "",
                  watchTime: (um["watchTime"] ?? um["watch_time"])?.toString() ?? "",
                  watching: um["watching"]?.toString() ?? "",
                  watched: um["watched"]?.toString() ?? "",
                  watchedPercent: (um["watchedPercent"] ?? um["watched_percent"])?.toString() ?? "",
                  viewed: um["viewed"]?.toString() ?? "",
                );
              }

              String thumbnailUrl = "${AppConfig.BaseUrl}/${movieData["thumbnail"]}";
              String portraitsmallUrl = "${AppConfig.BaseUrl}/${movieData["portraitsmall"]}";
              String portraitUrl = "${AppConfig.BaseUrl}/${movieData["portrait"]}";

              moviesRecentlyModel.add(Movies(
                id: movieData["id"].toString(),
                title: movieData["title"].toString(),
                movie_access: movieData["movie_access"]?.toString() ?? "",
                topten: movieData["topten"]?.toString() ?? "",
                trailer: movieData["trailer"]?.toString() ?? "",
                certificate: movieData["certificate"]?.toString() ?? "",
                duration: movieData["duration"]?.toString() ?? "",
                tagText: movieData["tag_text"]?.toString() ?? "",
                publishedDate: movieData["published_date"]?.toString() ?? "",
                userlist: movieData["userlist"]?.toString() ?? "",
                userlike: movieData["userlike"]?.toString() ?? "",
                thumbnail: thumbnailUrl,
                portraitsmall: portraitsmallUrl,
                portrait: portraitUrl,
                usermovies: usermovies,
              ));
            }
          }

          if (mounted) {
            setState(() {});
          }

          if (moviesRecentlyModel.isEmpty && searchType.isNotEmpty) {
            getUserMoviesLitRWatched(_token, profileID, "");
          }
        } catch (e) {
          print('WatchedMovieException: $e');
        }
      }
    });
  }

  void setUserMovies(String token, String profileID, String movieID, Map<String, int> postValues, int type) async {
    appUtils.showLoaderDialog(context);
    ApiServices().postRequestToken("${AppConfig.setUserMovie}$movieID?profile_id=$profileID", postValues, token).then((response) async {
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
      if (response.statusCode == 200) {
        if (type == 1) {
          getUserMoviesLitWatching(_token, profileID, "1");
        } else {
          getUserMoviesLitRWatched(_token, profileID, "1");
        }
        Fluttertoast.showToast(msg: "Updated list");
      }
    }).catchError((_) {
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
    });
  }

  void getTokenValid(String token) async {
    ApiServices().postRequestTokenWithoutBody(AppConfig.tokenexist, token).then((response) async {
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(response.body);
          String status = jsonReponse['status'];

          if (status == "error") {
            final pref = await SharedPreferences.getInstance();
            pref.clear();

            if (mounted) {
              setState(() {
                loggedStatus = false;
              });

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ).then((result) {
                if (result != null && mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                }
              });
            }
          }
        } catch (e) {
          print('getTokenExistException: $e');
        }
      }
    });
  }

  void getLogout(String token) async {
    appUtils.showLoaderDialog(context);

    ApiServices().postRequestTokenWithoutBody(AppConfig.logoutUrl, token).then((response) async {
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(response.body);
          String status = jsonReponse['status'];

          if (status == "success") {
            final pref = await SharedPreferences.getInstance();
            await pref.clear();

            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                'mainscreen',
                (route) => false,
              );
            }
          }
        } catch (e) {
          print('logoutException: $e');
        }
      } else {
        if (mounted) {
          CommonWidget().showSnackBar(
            context,
            ContentType.failure,
            "Error",
            "Logout failed. Please try again.",
          );
        }
      }
    }).catchError((_) {
      if (mounted) {
        appUtils.hideLoaderDialog(context);
      }
    });
  }
}
