import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/auth/login_screen.dart';

class PhysioScreen extends StatefulWidget {
  @override
  _PhysioScreenState createState() => _PhysioScreenState();
}

class _PhysioScreenState extends State<PhysioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  TextEditingController availabilityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  
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
        });
      }
    }
  }

  void _updateProfile() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'fullName': nameController.text,
        'specialization': specializationController.text,
        'location': locationController.text,
        'availability': availabilityController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }
  }

  void _logout() async {
  await _auth.signOut();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => LoginScreen()),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
