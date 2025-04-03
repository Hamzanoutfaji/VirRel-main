import 'package:flutter/material.dart';

class PhysioCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String image;

  const PhysioCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 255, 255, 0.9), // ✅ FIXED
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color.fromRGBO(200, 200, 200, 0.6), // ✅ FIXED
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                specialty,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
