import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _pageIndex = 0;

  bool loggedStatus = false;
  bool isLoading = false;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Define your pages/screens here
  final List<Widget> _pages = [
    Dashboard(),
    SearchScreen(),
    NotificationScreen(),
    ProfileMainPage(),
    LoginPage()
  ];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    BackButtonInterceptor.add(myInterceptor);

    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,

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
    loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;
  }

  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 600),
        margin: EdgeInsets.only(bottom: 0, right: 32, left: 32),
        content: Text('Tap back button again to exit'),
      ),
    );
  }

  void hideSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Tap back button again to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  bool isExit = false;
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isExit,
      onPopInvoked: (didPop) async {
        DateTime currentTime = DateTime.now();
        if (_lastPressedAt == null ||
            currentTime.difference(_lastPressedAt!) > Duration(seconds: 2)) {
          _lastPressedAt = currentTime;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ));

          setState(() {
            isExit = false;
          });
        }

        setState(() {
          isExit = true;
        });
      },
      child: Scaffold(
        // body: _pages[_pageIndex], // Show the current page
        body: _pages[_pageIndex], // Show the current page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Update the current index when an item is tapped
            setState(() {
              print("object_index:$index");
              if (index != 3) {
                _currentIndex = index;
                _pageIndex = index;
              } else {
                if (loggedStatus == false) {
                  if (index == 3) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  }
                } else {
                  _pageIndex = index;
                }
              }
            });
          },
          backgroundColor: AppDefaultColors.appColor,
          selectedItemColor: AppDefaultColors.white,
          unselectedItemColor: AppDefaultColors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
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
