import 'package:flutter/material.dart';
import 'get_started_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFF0FCFB); // same as HomeScreen

  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  final List<_Feature> _features = [
    _Feature(
      imagePath: 'assets/images/page1.jpg',
      title: "Workers Get a Platform",
      description:
      "Skilled workers (plumbers, electricians, etc.) create profiles and showcase their skills, rates, and reviews so they get more local jobs.",
    ),
    _Feature(
      imagePath: 'assets/images/page2.jpg',
      title: "Find Workers Easily",
      description:
      "Users can search and browse trusted local professionals, view profiles, ratings, and contact them directly — all inside the app.",
    ),
    _Feature(
      imagePath: 'assets/images/page3.jpg',
      title: "Find the Nearest Worker",
      description:
      "Using your location, the app shows nearby available workers so you can get help fast — ideal for urgent household fixes.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_features.length, (i) {
        final bool active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? lightSeaGreen : lightSeaGreen.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle headingStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: lightSeaGreen,
    );

    final TextStyle titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    final TextStyle descStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black54,
      height: 1.4,
    );

    return Scaffold(
      backgroundColor: bgColor, // updated to match HomeScreen
      appBar: AppBar(
        backgroundColor: lightSeaGreen,
        title: const Text("Know About Us"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "About Our App",
                  style: headingStyle,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We connect people with trusted local technicians — plumbers, electricians and other skilled workers — so getting repairs or services is fast and reliable.",
                style: descStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Our Services",
                  style: titleStyle.copyWith(color: lightSeaGreen),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _features.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    final _Feature f = _features[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: lightSeaGreen.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(80),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  f.imagePath,
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                f.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: lightSeaGreen.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                f.description,
                                style: descStyle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildDots(),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: lightSeaGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Ready to get started?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightSeaGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GetStartedScreen()),
                        );
                      },
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final String imagePath;
  final String title;
  final String description;
  const _Feature({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}