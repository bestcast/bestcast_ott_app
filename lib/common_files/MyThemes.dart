import 'package:flutter/material.dart';

import 'app_default_colors.dart';

enum MyThemeKeys { LIGHT, DARK }

class MyThemes {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: AppDefaultColors.appMaterialColor,
    primaryColor: AppDefaultColors.appColor,
    primaryColorLight: AppDefaultColors.appColor,
    primaryColorDark: AppDefaultColors.appColor,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
      labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
      floatingLabelStyle: TextStyle(color: AppDefaultColors.appColor),
      alignLabelWithHint: true,
      focusedBorder: OutlineInputBorder(
        borderSide:
            const BorderSide(color: AppDefaultColors.appColor, width: 1.5),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusColor: AppDefaultColors.lightRed,
    ),

    appBarTheme: AppBarTheme(backgroundColor: AppDefaultColors.appColor),
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppDefaultColors.appColor,
        cursorColor: AppDefaultColors.appColor,
        selectionHandleColor: AppDefaultColors.appColor),
    brightness: Brightness.light,
    highlightColor: Colors.white,

    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppDefaultColors.appColor,
        focusColor: AppDefaultColors.appColor,
        splashColor: AppDefaultColors.appColor),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.grey,
    brightness: Brightness.dark,
    highlightColor: Colors.white,
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.grey),
  );

  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT:
        return lightTheme;
      case MyThemeKeys.DARK:
        return darkTheme;
    }
  }
}
