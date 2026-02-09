import 'package:flutter/material.dart';

class AuthNavigator {
  /// Smooth navigation with fade transition
  static void navigateWithFade<T extends Widget>(
    BuildContext context,
    T page, {
    bool replace = true, // true = pushReplacement, false = push
  }) {
    final route = PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );

    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  /// Smooth navigation with slide transition (extra utility)
  static void navigateWithSlide<T extends Widget>(
    BuildContext context,
    T page, {
    bool replace = true,
    Offset begin = const Offset(1, 0), // default: slide from right
  }) {
    final route = PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(begin: begin, end: Offset.zero).animate(animation),
          child: child,
        );
      },
    );

    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }
}




// Slide From Bottom
//   context,
