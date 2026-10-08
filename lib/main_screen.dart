import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/Dashboard/dashboard.dart';
import 'package:bestcaststudios/notification_activity/notification_screen.dart';
import 'package:bestcaststudios/profile_screen/profile_mainpage.dart';
import 'package:bestcaststudios/search_activity/search_screen.dart';
import 'package:bestcaststudios/plan_details/plan_details.dart';
import 'package:bestcaststudios/Webseries/webseries_detail_screen.dart';
import 'app_config/app_preferences.dart';
import 'app_config/appconfig.dart';
import 'authendication/login_page.dart';
import 'common_files/api_services.dart';
import 'common_files/app_default_colors.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _pageIndex = 0;

  bool loggedStatus = false;
  String profilePicture = "";
  bool isLoading = false;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Define persistent pages for IndexedStack to preserve scroll state
  late final List<Widget> _pages = const [
    Dashboard(),
    SearchScreen(),
    NotificationScreen(),
    ProfileMainPage(),
  ];

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _pageIndex = widget.initialIndex;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    BackButtonInterceptor.add(myInterceptor);

    getInitalValue();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Deep Link Error: $err');
    });

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(initialUri);
        });
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) async {
    print('Handling deep link: $uri');
    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      final pref = await SharedPreferences.getInstance();
      await pref.setString(AppPreferences.bmpReferralCode, ref);
      await pref.setString(AppPreferences.refferer, ref);
    }
    if (uri.path == '/pricing') {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanDetailsPage(refCode: ref),
          ),
        );
      }
    } else if (uri.path.startsWith('/webseries/')) {
      final webseriesId = uri.pathSegments.last;
      if (webseriesId.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebseriesDetailScreen(webseriesId: webseriesId),
          ),
        );
      }
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!");
    return false;
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;
      profilePicture = pref.getString(AppPreferences.profilePicture) ?? '';
    });
  }

  void _onTabTapped(int index) async {
    HapticFeedback.selectionClick();
    if (index == _currentIndex) return;

    if (index == 3) {
      if (!loggedStatus) {
        await Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const LoginPage()),
        );
        final pref = await SharedPreferences.getInstance();
        final bool nowLogged = pref.getBool(AppPreferences.loggedStatus) ?? false;
        final String newPic = pref.getString(AppPreferences.profilePicture) ?? '';
        if (mounted) {
          setState(() {
            loggedStatus = nowLogged;
            profilePicture = newPic;
            if (nowLogged) {
              _currentIndex = 3;
              _pageIndex = 3;
            }
          });
        }
        return;
      }
    }

    setState(() {
      _currentIndex = index;
      _pageIndex = index;
    });
  }

  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // If not on Home tab, smoothly navigate back to Home first
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
            _pageIndex = 0;
          });
          return;
        }

        // On Home tab: double back press to exit
        final DateTime currentTime = DateTime.now();
        if (_lastPressedAt == null ||
            currentTime.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = currentTime;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 16, right: 32, left: 32),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // IndexedStack preserves state and scroll positions of all tabs
        body: IndexedStack(
          index: _pageIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                selectedIcon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
              ),
              _buildNavItem(
                index: 1,
                label: 'Search',
                selectedIcon: Icons.search_rounded,
                unselectedIcon: Icons.search_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Notifications',
                selectedIcon: Icons.notifications_rounded,
                unselectedIcon: Icons.notifications_none_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Profile',
                selectedIcon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
                isProfile: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    bool isProfile = false,
  }) {
    final bool isSelected = _currentIndex == index;
    const Color activeColor = AppDefaultColors.primaryRed;
    const Color inactiveColor = Colors.white54;

    Widget iconWidget;
    if (isProfile && loggedStatus && profilePicture.isNotEmpty) {
      final String imgUrl = profilePicture.startsWith('http')
          ? profilePicture
          : "${AppConfig.BaseUrl}/$profilePicture";
      iconWidget = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : Colors.white24,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            imgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ),
      );
    } else {
      iconWidget = Icon(
        isSelected ? selectedIcon : unselectedIcon,
        size: 23,
        color: isSelected ? activeColor : inactiveColor,
      );
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          splashColor: activeColor.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon scale
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: iconWidget,
              ),
              const SizedBox(height: 4),
              // Navigation label
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getTokenValid(String token, int index) async {
    setState(() {
      isLoading = true;
    });
    ApiServices()
        .postRequestTokenWithoutBody(AppConfig.tokenexist, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("getTokenExist_Response: $jsonsDataString");
      print("getTokenExist_Token: $token");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          String status = jsonReponse['status'];

          if (status == "error") {
            final pref = await SharedPreferences.getInstance();
            pref.clear();

            setState(() {
              loggedStatus = false;
            });
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            _pageIndex = index;
          }
        } catch (e) {
          print('getTokenExistException:$e');
        }
      } else {
        print("geTokenResError: $response");
      }
    });
    setState(() {
      isLoading = false;
    });
  }
}
