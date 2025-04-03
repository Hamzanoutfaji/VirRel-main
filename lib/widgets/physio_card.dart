import 'package:flutter/material.dart';
import '../models/physiotherapist.dart';

class PhysioCard extends StatelessWidget {
  final Physiotherapist physio;
  final VoidCallback onTap;

  const PhysioCard({
    super.key,
    required this.physio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String image = physio.image;
    final bool isNetworkImage = image.startsWith("http") || image.startsWith("https");
    final bool hasImage = image.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasImage
                  ? (isNetworkImage
                      ? Image.network(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("❌ Error loading image: $image");
                            return Icon(Icons.broken_image, size: 80, color: Colors.red);
                          },
                        )
                      : Image.asset(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ))
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    physio.fullName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    physio.specialization,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    physio.location,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
