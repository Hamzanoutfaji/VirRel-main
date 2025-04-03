import 'package:flutter/material.dart';

void navigateWithFade(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        ); // ✅ Smooth fade animation
      },
    ),
  );
}
