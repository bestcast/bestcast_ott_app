import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:bestcaststudios/main_screen.dart';
import 'package:bestcaststudios/register/profile_image_grid.dart';
import 'common_files/app_default_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
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
        scaffoldBackgroundColor: AppDefaultColors.appColor,
        cardColor: AppDefaultColors.darkGray,
        primaryColor: AppDefaultColors.primaryRed,
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
      home: const MainScreen(),
      routes: {
        "profile_image_grid": (context) => const ProfileImageGrid(),
        'mainscreen': (context) => const MainScreen(),
      },
    );
  }
}
