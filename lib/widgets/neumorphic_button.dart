import 'package:flutter/material.dart';

class NeumorphicButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const NeumorphicButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              offset: Offset(-4, -4),
              blurRadius: 6,
              color: Colors.white,
            ),
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 6,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
