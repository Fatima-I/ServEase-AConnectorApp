import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'marketplace_screen.dart';
import 'forgot_password_screen.dart';
import 'general_info_screen.dart';
// import 'worker_feed_screen.dart'; // make sure this file exists

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

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Clear previous errors before attempting login
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Basic validation
    if (email.isEmpty) {
      setState(() {
        _emailError = "Email is required";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = "Password is required";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _passwordError = "Password must be at least 6 characters";
      });
      return;
    }

    try {
      // Firebase sign-in
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Login successful, navigate to WorkerFeedScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkerFeedScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      setState(() {
        if (e.code == 'user-not-found') {
          _emailError = "Email doesn't exist";
        } else if (e.code == 'invalid-email') {
          _emailError = "Invalid email format";
        } else if (e.code == 'wrong-password') {
          _passwordError = "Wrong password";
        } else if (e.code == 'invalid-credential') {
          // This is a newer Firebase error code that covers both wrong email and password
          _emailError = "Email doesn't exist or password is incorrect";
        } else if (e.code == 'user-disabled') {
          _emailError = "This account has been disabled";
        } else if (e.code == 'too-many-requests') {
          _passwordError = "Too many attempts. Try again later";
        } else {
          // For unknown errors, show in snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Login failed: ${e.message}")),
            );
          }
        }
      });
    } catch (e) {
      // Handle other unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred: $e")),
        );
      }
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
                          // Shield Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
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
                            child: const Icon(
                              Icons.shield,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: lightSeaGreen,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _emailError,
                              errorMaxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _passwordError,
                              errorMaxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Register Now
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const GeneralInfoScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register Now",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: lightSeaGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text("Forgot Password?"),
                          ),

                          const SizedBox(height: 20),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lightSeaGreen,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _login,
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
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