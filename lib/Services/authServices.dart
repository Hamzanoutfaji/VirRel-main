import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with Email & Password, Full Name, and Role
  Future<User?> registerWithEmail(
      String email, String password, String fullName, String role,
      {String? licenseNumber, String? specialization, String? location}) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After user is created, store their full name, role, and email in Firestore
      Map<String, dynamic> userData = {
        'fullName': fullName,  
        'email': email,
        'role': role,
      };

      if (role == 'physiotherapist') {
        userData.addAll({
          'licenseNumber': licenseNumber,
          'specialization': specialization,
          'location': location,
        });
      }

      await _firestore.collection('users').doc(userCredential.user?.uid).set(userData);

      return userCredential.user;
    } catch (e) {
      debugPrint("Error in register: $e");
      rethrow; // Rethrow to handle in the UI
    }
  }
 



  // Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Just return user, wrapper will handle navigation
    } catch (e) {
      debugPrint("Error in sign in: $e");
      rethrow;
    }
  }

  // Sign In Anonymously
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint("Error in anonymous sign in: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error in sign out: $e");
    }
  }
}