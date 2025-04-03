import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/navigation/bottom_nav.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/home/physio_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) return const LoginScreen();

          // Check Firestore for the user's role
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (roleSnapshot.hasError || !roleSnapshot.hasData || !roleSnapshot.data!.exists) {
                return const LoginScreen(); // If user data is missing, send to login
              }

              final role = roleSnapshot.data!.get('role');
              if (role == 'physiotherapist') {
                return  PhysioScreen();
              } else {
                return const BottomNavScreen();
              }
            },
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
