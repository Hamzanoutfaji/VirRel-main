import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Services/authServices.dart';
import 'package:myapp/navigation/bottom_nav.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/home/physio_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedRole = 'user';  // Default role

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final AuthServices _authServices = AuthServices();

  String? _errorMessage;
  bool _isLoading = false;

  // Validate form inputs
  bool _validateInputs() {
    if (_fullNameController.text.isEmpty) {
      setState(() => _errorMessage = "Full name is required");
      return false;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = "Email is required");
      return false;
    }
    if (!_emailController.text.contains("@") || !_emailController.text.contains(".")) {
      setState(() => _errorMessage = "Enter a valid email");
      return false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Password is required");
      return false;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters");
      return false;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return false;
    }
    if (_selectedRole == 'physiotherapist') {
      if (_licenseNumberController.text.isEmpty || _specializationController.text.isEmpty || _locationController.text.isEmpty) {
        setState(() => _errorMessage = "Please fill all the physiotherapist details");
        return false;
      }
    }
    return true;
  }

  // Handle registration
  Future<void> _register() async {
    if (!_validateInputs()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Register based on selected role
      if (_selectedRole == 'physiotherapist') {
        await _authServices.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _fullNameController.text.trim(),
          _selectedRole,
          licenseNumber: _licenseNumberController.text.trim(),
          specialization: _specializationController.text.trim(),
          location: _locationController.text.trim(),
        );
      } else {
        await _authServices.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _fullNameController.text.trim(),
          _selectedRole,
        );
      }

      // Navigate to home screen after successful registration
     if (mounted) {
  if (_selectedRole == 'physiotherapist') {
    // Navigate to a specific screen for physiotherapists (you can replace 'PhysioDashboardScreen()' with your desired screen)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PhysioScreen()),//physioScreen
       // Removes all previous routes from the stack
    );
  } else {
    // Navigate to the BottomNavScreen for other users
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>  const BottomNavScreen()),
      // Removes all previous routes from the stack
    );
  }
}

    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              _errorMessage = "This email is already registered";
              break;
            case 'weak-password':
              _errorMessage = "Password is too weak";
              break;
            case 'invalid-email':
              _errorMessage = "Invalid email format";
              break;
            default:
              _errorMessage = "Registration failed: ${e.message}";
          }
        } else {
          _errorMessage = "An error occurred. Please try again";
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Prevents the back arrow from appearing
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name Input Field
            AuthTextField(
              controller: _fullNameController,
              labelText: "Full Name",
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmPasswordController,
              labelText: "Confirm Password",
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Radio buttons for role selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'user',
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const Text('User', style: TextStyle(color: Colors.white)),
                Radio<String>(
                  value: 'physiotherapist',
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const Text('Physiotherapist', style: TextStyle(color: Colors.white)),
              ],
            ),

            // Additional fields for Physiotherapist role
            if (_selectedRole == 'physiotherapist') ...[
              const SizedBox(height: 12),
              AuthTextField(
                controller: _licenseNumberController,
                labelText: "License Number",
                prefixIcon: Icons.badge,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _specializationController,
                labelText: "Specialization",
                prefixIcon: Icons.school,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _locationController,
                labelText: "Location",
                prefixIcon: Icons.location_on,
              ),
            ],

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
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Register",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),  // Navigate back to login screen
                      );
                    },
              child: const Text("Already have an account? Sign In",
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
