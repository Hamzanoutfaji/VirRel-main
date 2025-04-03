import 'package:flutter/material.dart';
import 'package:myapp/models/physiotherapist.dart';

class PhysioDetailsScreen extends StatelessWidget {
  final Physiotherapist physio;

  const PhysioDetailsScreen({super.key, required this.physio});

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = physio.image.startsWith("http") || physio.image.startsWith("https");

    return Scaffold(
      appBar: AppBar(title: Text(physio.fullName)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isNetworkImage
                  ? Image.network(
                      physio.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("❌ Error loading image: ${physio.image}");
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(Icons.error, size: 50, color: Colors.red),
                        );
                      },
                    )
                  : Image.asset(
                      physio.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 16),
            Text(
              physio.fullName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              physio.specialization,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildDetailRow(Icons.location_on, "📍 ${physio.location}"),
            _buildDetailRow(Icons.phone, "📞 ${physio.phoneNumber}"),
            _buildDetailRow(Icons.email, "📧 ${physio.email}"),
            _buildDetailRow(Icons.access_time, "🕒 ${physio.availability}"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
