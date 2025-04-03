import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/models/physiotherapist.dart';
import 'package:myapp/widgets/physio_card.dart';
import 'physio_details_screen.dart';
import 'dart:math';

class PhysiotherapistsScreen extends StatefulWidget {
  const PhysiotherapistsScreen({super.key});

  @override
  _PhysiotherapistsScreenState createState() => _PhysiotherapistsScreenState();
}

class _PhysiotherapistsScreenState extends State<PhysiotherapistsScreen> {
  List<Physiotherapist> physiotherapists = [];
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _fetchPhysiotherapists();
    _getUserLocation();
  }

  Future<void> _fetchPhysiotherapists() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')  // ✅ Fetch from users collection
        .where("role", isEqualTo: "physiotherapist")  // ✅ Filter by role
        .get();

    List<Physiotherapist> fetchedPhysios = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Physiotherapist(
        id: doc.id,
        fullName: data["fullName"] ?? "Unknown",
        specialization: data["specialization"] ?? "Not specified",
        image: data["image"] ?? "assets/default.png",  // Default image if missing
        latitude: (data["latitude"] ?? 0.0).toDouble(),  // ✅ Ensure double
        longitude: (data["longitude"] ?? 0.0).toDouble(), // ✅ Ensure double
        phoneNumber: data["phone_number"] ?? "No phone",
        location: data["location"] ?? "Unknown location",
        availability: data["availability"] ?? "Not available",
        email: data["email"] ?? "No email",
        licenseNumber: data["licenseNumber"] ?? "N/A",
      );
    }).toList();

    setState(() {
      physiotherapists = fetchedPhysios;
    });

    _sortPhysiotherapistsByDistance();
  } catch (e) {
    print("❌ Error fetching physiotherapists: $e");
  }
}




  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        userLocation = position;
      });
      _sortPhysiotherapistsByDistance();
    } catch (e) {
      print("❌ Error getting user location: $e");
    }
  }

  void _sortPhysiotherapistsByDistance() {
    if (userLocation == null) return;

    physiotherapists.sort((a, b) {
      double distanceA = _calculateDistance(userLocation!.latitude, userLocation!.longitude, a.latitude, a.longitude);
      double distanceB = _calculateDistance(userLocation!.latitude, userLocation!.longitude, b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });

    setState(() {});
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Physiotherapists Near You")),
      body: physiotherapists.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: physiotherapists.length,
              itemBuilder: (context, index) {
                final physio = physiotherapists[index];
                return PhysioCard(
                  physio: physio,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhysioDetailsScreen(physio: physio),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
