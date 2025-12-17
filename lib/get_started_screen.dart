import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for role check
import 'marketplace_screen.dart';
import 'forgot_password_screen.dart';
import 'general_info_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFE0F7F5);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state for login button
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = "Email is required");
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = "Password is required");
      return;
    }

    setState(() => _isLoading = true); // Start loading

    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // 2. Fetch User Role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc.get('role') ?? 'user';
          bool isWorker = role == 'worker';

          // 3. Navigate with correct role
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // Pass the actual role here!
                builder: (context) => WorkerFeedScreen(isWorker: isWorker),
              ),
            );
          }
        } else {
          // Handle missing user document
          setState(() {
            _emailError = "User data not found in database.";
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _emailError = "Email doesn't exist";
        } else if (e.code == 'wrong-password') {
          _passwordError = "Wrong password";
        } else if (e.code == 'invalid-credential') {
          _emailError = "Invalid email or password";
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${e.message}")),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: lightSeaGreen),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [lightSeaGreen, Colors.teal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: const Icon(Icons.shield, size: 60, color: Colors.white),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Login",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightSeaGreen),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              errorText: _emailError,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              errorText: _passwordError,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GeneralInfoScreen())),
                                child: const Text("Register Now", style: TextStyle(color: lightSeaGreen, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                            child: const Text("Forgot Password?"),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lightSeaGreen,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : _login, // Disable if loading
                              child: _isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("LOGIN", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}