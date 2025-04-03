import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

// Physiotherapist Model
class Physiotherapist {
  final String name;
  final String specialty;
  final String image;
  final double latitude;
  final double longitude;

  Physiotherapist({
    required this.name,
    required this.specialty,
    required this.image,
    required this.latitude,
    required this.longitude,
  });
}

class PhysiotherapistsScreen extends StatefulWidget {
  const PhysiotherapistsScreen({super.key});

  @override
  _PhysiotherapistsScreenState createState() => _PhysiotherapistsScreenState();
}

class _PhysiotherapistsScreenState extends State<PhysiotherapistsScreen> {
  List<Physiotherapist> physiotherapists = [
    Physiotherapist(
      name: "Dr. Emily Reid",
      specialty: "Sports Therapy",
      image: "assets/images/physio1.jpg",
      latitude: 37.7749, // Example location (San Francisco)
      longitude: -122.4194,
    ),
    Physiotherapist(
      name: "Dr. Michael Chen",
      specialty: "Post-Op Recovery",
      image: "assets/images/physio2.jpg",
      latitude: 34.0522, // Example location (Los Angeles)
      longitude: -118.2437,
    ),
  ];

  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ✅ Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("❌ Location services are disabled.");
      return;
    }

    // ✅ Request permission if not already granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("❌ Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("❌ Location permissions are permanently denied.");
      return;
    }

    try {
      // ✅ Try getting current location
      Position position = await Geolocator.getCurrentPosition();
      debugPrint("✅ User location retrieved: ${position.latitude}, ${position.longitude}");

      setState(() {
        userLocation = position;
        _sortPhysiotherapistsByDistance();
      });
    } catch (e) {
      debugPrint("❌ Error getting location: $e");

      // ✅ Fallback: Try using last known location
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        debugPrint("⚠️ Using last known location: ${lastKnown.latitude}, ${lastKnown.longitude}");
        setState(() {
          userLocation = lastKnown;
          _sortPhysiotherapistsByDistance();
        });
      } else {
        debugPrint("❌ No last known location available.");
      }
    }
  }

  void _sortPhysiotherapistsByDistance() {
    if (userLocation == null) return;

    physiotherapists.sort((a, b) {
      double distanceA = _calculateDistance(userLocation!.latitude, userLocation!.longitude, a.latitude, a.longitude);
      double distanceB = _calculateDistance(userLocation!.latitude, userLocation!.longitude, b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });

    setState(() {}); // Refresh UI with sorted list
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Physiotherapists Near You")),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: physiotherapists.length,
              itemBuilder: (context, index) {
                Physiotherapist physio = physiotherapists[index];
                double distance = _calculateDistance(
                  userLocation!.latitude,
                  userLocation!.longitude,
                  physio.latitude,
                  physio.longitude,
                );

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      physio.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(physio.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${physio.specialty} • ${distance.toStringAsFixed(1)} km away"),
                  trailing: Icon(Icons.location_on, color: Colors.blue),
                );
              },
            ),
    );
  }
}
