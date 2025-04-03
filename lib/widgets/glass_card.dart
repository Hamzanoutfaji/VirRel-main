import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.2), // ✅ FIXED
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.fromRGBO(255, 255, 255, 0.3),
            ), // ✅ FIXED
          ),
          padding: EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
