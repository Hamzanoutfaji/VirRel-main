import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFAFAFA),
                Color(0xFFEFEFEF),
              ], // ✅ Smooth light gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        child, // ✅ The actual screen content
      ],
    );
  }
}
