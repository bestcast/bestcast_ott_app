// Flutter imports:
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

// Fade Navigation (replace current page)
// AuthNavigator.navigateWithFade(context, OTPactivity(otpEmailorPhone: "12345"));

// Fade Navigation (keep previous page in stack)
// AuthNavigator.navigateWithFade(context, LoginActivity(), replace: false);

// Slide Navigation (default: slide from right)
// AuthNavigator.navigateWithSlide(context, DashboardPage());

// Slide From Bottom
// AuthNavigator.navigateWithSlide(
//   context,
//   SettingsPage(),
//   begin: const Offset(0, 1),
// );
