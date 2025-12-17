import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_worker_chat_screen.dart';
import 'worker_reviews_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String workerUid;
  final String name;
  final String profession;
  final String rating;
  final String reviews;
  final String distance;

  const WorkerProfileScreen({
    super.key,
    required this.workerUid,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviews,
    required this.distance,
  });

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  int _selectedIndex = 0;

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
        title: const Text('Worker Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      // FETCH REAL DATA HERE
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.workerUid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Default values if fetch fails or fields missing
          String phone = "Not available";
          String description = "Experienced ${widget.profession}.";
          String location = "${widget.distance} km away";
          String username = "@${widget.name.replaceAll(' ', '_').toLowerCase()}";

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final workerDetails = data['workerDetails'] as Map<String, dynamic>? ?? {};

            phone = data['phone'] ?? phone;
            description = workerDetails['bio'] ?? description;
            location = "${workerDetails['city'] ?? 'Lahore'} (${widget.distance} km)";
            // You can also update name/profession here if you want the absolute latest
          }

          return SingleChildScrollView(
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
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: lightSeaGreen.withOpacity(0.3),
                        child: const Icon(Icons.person, size: 45, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.profession, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(widget.rating, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('(${widget.reviews} reviews)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("General Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                _infoTile(Icons.person_outline, "Username", username),
                _infoTile(Icons.description_outlined, "Description", description),
                _infoTile(Icons.location_on_outlined, "Location", location),
                _infoTile(Icons.phone_outlined, "Phone", phone),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: lightSeaGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == _selectedIndex) return;
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerChatScreen(
                  otherUserUid: widget.workerUid,
                  otherUserName: widget.name,
                  profession: widget.profession,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerReviewsScreen(
                  workerUid: widget.workerUid,
                  name: widget.name,
                  profession: widget.profession,
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