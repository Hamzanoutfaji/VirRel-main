import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Services/authServices.dart';
import 'package:myapp/screens/auth/signup_screen.dart';
import 'package:myapp/navigation/bottom_nav.dart';
import 'package:myapp/screens/home/physio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthServices _authServices = AuthServices();

  String? _errorMessage;
  bool _isLoading = false;
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  // Validate form inputs
  bool _validateInputs() {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = "Email is required");
      return false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Password is required");
      return false;
    }
    return true;
  }

  // Handle sign in
  Future<void> _signIn() async {
    if (!_validateInputs()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _authServices.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // No need to manually navigate, it's handled by stream.
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = "No user found with this email";
              break;
            case 'wrong-password':
              _errorMessage = "Incorrect password";
              break;
            case 'invalid-email':
              _errorMessage = "Invalid email format";
              break;
            default:
              _errorMessage = "Login failed: ${e.message}";
          }
        } else {
          _errorMessage = "An error occurred. Please try again";
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Handle anonymous sign in
  Future<void> _signInAnonymously() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _authServices.signInAnonymously();
      // No need to manually navigate, it's handled by stream.
    } catch (e) {
      setState(() => _errorMessage = 'Anonymous sign-in failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _emailController,
              labelText: "Email",
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              labelText: "Password",
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Sign In",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading ? null : _signInAnonymously,
              child: const Text("Sign In Anonymously",
                  style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?",
                    style: TextStyle(color: Colors.white70)),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                  child: const Text("Register",
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            StreamBuilder<User?>(
  stream: _authStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasData) {
      User? user = snapshot.data;
      if (user != null) {
        if (user.isAnonymous) {
          // ✅ Directly navigate anonymous users to BottomNavScreen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavScreen()),
            );
          });
        } else {
          // ✅ Fetch user role from Firestore for registered users
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .then((DocumentSnapshot userDoc) {
            if (userDoc.exists) {
              String role = userDoc['role'];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => role == 'physiotherapist'
                        ? PhysioScreen()
                        : const BottomNavScreen(),
                  ),
                );
              });
            }
          }).catchError((error) {
            debugPrint("Error fetching user role: $error");
          });
        }
      }
    }
    return const SizedBox(); // No user logged in yet, stay on login screen
  },
),


          ],
        ),
      ),
    );
  }
}

// Reusable AuthTextField widget
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;

  const AuthTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
        filled: true,
        fillColor: Colors.blueGrey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
