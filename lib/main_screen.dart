// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:bestcaststudios/Dashboard/dashboard.dart';
import 'package:bestcaststudios/notification_activity/notification_screen.dart';
import 'package:bestcaststudios/profile_screen/profile_mainpage.dart';
import 'package:bestcaststudios/search_activity/search_screen.dart';
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

  // Define your pages/screens here
  final List<Widget> _pages = [
    Dashboard(),
    SearchScreen(),
    NotificationScreen(),
    ProfileMainPage(),
    LoginPage()
  ];

  String _token = "";

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    BackButtonInterceptor.add(myInterceptor);

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    //TODO will popscope
    // SystemChannels.platform.setMethodCallHandler((call) async {
    //   if (call.method == 'SystemNavigator.pop') {
    //     return onWillPop();
    //   }
    //   return false;
    // });
    getInitalValue();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!");
    return false;
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;
    _token = pref.getString(AppPreferences.token) ?? '';
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
                // getTokenValid(_token,index);
                if (loggedStatus == false) {
                  if (index == 3) {
                    // _pageIndex = index + 1;
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
          // isLoading = false;
        } catch (e) {
          // isLoading = false;
          print('getTokenExistException:$e');
        }
      } else {
        // setState(() {
        //   isLoading = false;
        // });
        print("geTokenResError: $response");
      }

      // isLoading = false;
    });
    // isLoading = false;
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
