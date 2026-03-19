import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/common_files/loading_widget.dart';
import 'package:bestcaststudios/main_screen.dart';
import 'package:bestcaststudios/register/profile_image_grid.dart';
import 'app_config/app_preferences.dart';
import 'common_files/app_default_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bestcast OTT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(fontSize: 12, color: Colors.white),
          labelStyle: TextStyle(fontSize: 18, color: Colors.white),
          floatingLabelStyle: TextStyle(color: AppDefaultColors.white),
          focusColor: AppDefaultColors.white,
        ),
        textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.grey, selectionHandleColor: Colors.white),

        switchTheme: SwitchThemeData(
            trackOutlineWidth: WidgetStateProperty.resolveWith<double?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return 1.0;
              }
              return 0; // Use the default width.
            }),
            trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppDefaultColors.helpBlue : AppDefaultColors.boxDarkGray),
            thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppDefaultColors.textLightGray : AppDefaultColors.textLightGray)),

        //Player Theme
        scaffoldBackgroundColor: Color(0xFFf9fbfe),
        cardColor: Color(0xFFfbfafe),
        primaryColor: Color(0xFFd81e27),
        shadowColor: Color(0xFF324754).withOpacity(0.24),
        textTheme: TextTheme(
          headlineMedium: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
          headlineSmall: GoogleFonts.montserrat(
            color: Color(0xFF324754),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: GoogleFonts.montserrat(
            color: Color(0xFF324754),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: GoogleFonts.montserrat(
            color: Color(0xFF324754),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleMedium: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 12,
          ),
          titleSmall: GoogleFonts.montserrat(
            color: Color(0xFF819ab1),
            fontSize: 12,
          ),
          labelLarge: GoogleFonts.montserrat(
            color: Colors.white,
            letterSpacing: 0.8,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Bestcast OTT'),
      routes: {
        "profile_image_grid": (context) => ProfileImageGrid(),
        'mainscreen': (context) => MainScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loggedStatus = false;
  bool loadStatus = false;

  Future<void> getInitialValue() async {
    final pref = await SharedPreferences.getInstance();
    loggedStatus = pref.getBool(AppPreferences.loggedStatus) ?? false;

    print("loggedStatus$loggedStatus");

    if (loggedStatus) {
      await Future.delayed(Duration(seconds: 3));
      setState(() {
        loadStatus = true;
      });
    } else {
      setState(() {
        loadStatus = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitialValue();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // statusBarColor: Colors.red, // You can use this as well
        statusBarIconBrightness: Brightness.light, // OR Vice Versa for ThemeMode.dark
        statusBarBrightness: Brightness.light, // OR Vice Versa for ThemeMode.dark
        systemNavigationBarColor: Colors.black, // OR Vice Versa for ThemeMode.dark
      ),
    );

    return loadStatus
        ? AnimatedSplashScreen(
            duration: 1000,
            // splash: Icons.home,
            splash: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              height: 250,
              child: const Image(
                image: AssetImage("images/logo_bestcast.png"),
                height: 150,
              ),
            ),
            nextScreen: MainScreen(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: Colors.black)
        : LoadingWidget();
  }
}
