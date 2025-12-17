import 'package:flutter/material.dart';
import 'user_worker_chat_screen.dart';
import 'worker_reviews_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String name;
  final String profession;
  final String rating;
  final String reviews;
  final String distance;

  const WorkerProfileScreen({
    super.key,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviews,
    required this.distance,
  });

  @override
  State<WorkerProfileScreen> createState() => _SimpleWorkerProfileScreenState();
}

class _SimpleWorkerProfileScreenState extends State<WorkerProfileScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFE0F7F5);

  int _selectedIndex = 0;

  // Generate username from name
  String get username => "@${widget.name.toLowerCase().replaceAll(' ', '_')}";

  // Generate description from profession
  String get description => "Experienced ${widget.profession} with quality work and customer satisfaction guaranteed.";

  // Generate location from distance
  String get location => "${widget.distance} km away - Lahore, Pakistan";

  // Dummy phone
  String get phone => "+92 300 1234567";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightSeaGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Worker Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightSeaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: lightSeaGreen.withOpacity(0.3),
                    child: const Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                  const SizedBox(width: 16),

                  // Name, Profession, Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.profession,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.reviews} reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // General Information
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "General Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _infoTile(Icons.person_outline, "Username", username),
            _infoTile(Icons.description_outlined, "Description", description),
            _infoTile(Icons.location_on_outlined, "Location", location),
            _infoTile(Icons.phone_outlined, "Phone", phone),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: lightSeaGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == _selectedIndex) return;

          if (index == 1) {
            // Navigate to Chat
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerChatScreen(
                  username: username,
                  name: widget.name,
                  profession: widget.profession,
                  description: description,
                  location: location,
                  phone: phone,
                  rating: widget.rating,
                  reviews: widget.reviews,
                  distance: widget.distance,
                ),
              ),
            );
          } else if (index == 2) {
            // Navigate to Reviews
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerReviewsScreen(
                  username: username,
                  name: widget.name,
                  profession: widget.profession,
                  description: description,
                  location: location,
                  phone: phone,
                  rating: widget.rating,
                  reviews: widget.reviews,
                  distance: widget.distance,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.reviews_outlined), label: "Reviews"),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: lightSeaGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
