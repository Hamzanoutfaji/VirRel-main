import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'dart:io';

class PhysioScreen extends StatefulWidget {
  @override
  _PhysioScreenState createState() => _PhysioScreenState();
}

class _PhysioScreenState extends State<PhysioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? user;
  TextEditingController availabilityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  
  String? imageUrl;
  bool isProfileUpdated = false; // To track if profile was updated

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['fullName'] ?? '';
          specializationController.text = userDoc['specialization'] ?? '';
          locationController.text = userDoc['location'] ?? '';
          availabilityController.text = userDoc['availability'] ?? '';
          latitudeController.text = userDoc['latitude']?.toString() ?? '';
          longitudeController.text = userDoc['longitude']?.toString() ?? '';
          imageUrl = userDoc['image']; // Load image
        });
      }
    }
  }

  // 📌 Function to Upload Image
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    String fileName = 'physio_${user!.uid}.jpg';
    Reference ref = _storage.ref().child('physios/$fileName');

    try {
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });

      // Update Firestore with Image URL
      await _firestore.collection('users').doc(user!.uid).update({'image': downloadUrl});
    } catch (e) {
      print("❌ Error uploading image: $e");
    }
  }

  // 📌 Function to Fetch Location Automatically
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("❌ Location permission denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
    });

    // Update Firestore with Location
    await _firestore.collection('users').doc(user!.uid).update({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  void _updateProfile() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'fullName': nameController.text,
        'specialization': specializationController.text,
        'location': locationController.text,
        'availability': availabilityController.text,
        'latitude': double.tryParse(latitudeController.text) ?? 0,
        'longitude': double.tryParse(longitudeController.text) ?? 0,
        'image': imageUrl ?? '',
      });

      setState(() {
        isProfileUpdated = true; // Profile update status
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Your profile has been updated!')));
    }
  }

  // 📌 Logout and Navigate to Login Screen
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Adjust your LoginScreen widget here
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physiotherapist Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: specializationController,
              decoration: InputDecoration(labelText: 'Specialization'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: availabilityController,
              decoration: InputDecoration(labelText: 'Availability'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latitudeController,
                    decoration: InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: longitudeController,
                    decoration: InputDecoration(labelText: 'Longitude'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.location_on, color: Colors.blue),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
            if (isProfileUpdated)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Your profile has been updated, and you can exit/logout of our app.",
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
