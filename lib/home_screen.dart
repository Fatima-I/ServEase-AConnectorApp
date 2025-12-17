import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'get_started_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color bgColor = Color(0xFFE0F7F5);
  static const Color buttonColor = Color(0xFF4FB0A4);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double logoSize = screenSize.width * 0.7;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
              child: const Text(
                "Know About Us",
                style: TextStyle(
                  color: buttonColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 50), // push logo slightly from top
          // Logo - Centered
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: logoSize.clamp(200, 320),
              height: logoSize.clamp(200, 320),
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(), // push button to bottom
          // Get Started button - Centered and Elevated
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                elevation: 8,
                shadowColor: buttonColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GetStartedScreen(),
                  ),
                );
              },
              child: const Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,

                ),
              ),
            ),
          ),
          const SizedBox(height: 30), // optional bottom padding
        ],
      ),
    );
  }
}