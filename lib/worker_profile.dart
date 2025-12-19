import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_worker_chat_screen.dart';
import 'worker_reviews_screen.dart';
import 'worker_map_screen.dart'; // Map screen import zaroori hai

class WorkerProfileScreen extends StatefulWidget {
  // --- CHANGE 1: Ab ye sirf Map accept karega (Crash rokne ke liye) ---
  final Map<String, dynamic> workerData;

  const WorkerProfileScreen({
    super.key,
    required this.workerData,
  });

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  int _selectedIndex = 0;

  // Helper to safely get UID
  String get _workerUid => widget.workerData['uid'] ?? widget.workerData['id'] ?? '';

  // --- REPAIR FUNCTION (As per your code) ---
  Future<void> _fixRatings() async {
    if (_workerUid.isEmpty) return;

    final workerRef = FirebaseFirestore.instance.collection('users').doc(_workerUid);
    final reviewsSnapshot = await workerRef.collection('reviews').get();

    if (reviewsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No reviews found.")));
      return;
    }

    double totalRating = 0;
    int count = 0;

    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc['rating'] ?? 0).toDouble();
      count++;
    }

    double newAverage = count > 0 ? totalRating / count : 0.0;

    await workerRef.update({
      'workerDetails.rating': double.parse(newAverage.toStringAsFixed(1)),
      'workerDetails.reviewCount': count,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fixed! Count: $count, Avg: $newAverage")));
  }

  @override
  Widget build(BuildContext context) {
    // --- CHANGE 2: Initial Data from Map (Fallback values) ---
    final initialData = widget.workerData;
    final initialDetails = initialData['workerDetails'] ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Worker Profile"),
        backgroundColor: lightSeaGreen,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.build, color: Colors.white),
            tooltip: "Fix Ratings",
            onPressed: _fixRatings,
          )
        ],
      ),

      // STREAM BUILDER (APKA ORIGINAL CODE)
      body: StreamBuilder<DocumentSnapshot>(
        stream: _workerUid.isNotEmpty
            ? FirebaseFirestore.instance.collection('users').doc(_workerUid).snapshots()
            : null,
        builder: (context, snapshot) {
          // Agar loading hai ya data nahi hai, to 'initialData' use karein taake screen blank na ho
          var data = initialData;
          if (snapshot.hasData && snapshot.data!.exists) {
            data = snapshot.data!.data() as Map<String, dynamic>;
          }

          final workerDetails = data['workerDetails'] as Map<String, dynamic>? ?? {};

          final liveName = data['name'] ?? "Unknown";
          final liveProf = workerDetails['profession'] ?? "Worker";
          final liveRating = (workerDetails['rating'] ?? 0.0).toString();
          final liveReviews = (workerDetails['reviewCount'] ?? 0).toString();
          final bio = workerDetails['bio'] ?? "No description available.";
          final phone = data['phone'] ?? "+92 300 1234567";
          final username = "@${liveName.toLowerCase().replaceAll(' ', '_')}";

          // Location variables
          final address = workerDetails['address'] ?? "No address";
          final city = workerDetails['city'] ?? "Lahore";
          double? lat;
          if (workerDetails['latitude'] != null) lat = double.tryParse(workerDetails['latitude'].toString());
          double? lng;
          if (workerDetails['longitude'] != null) lng = double.tryParse(workerDetails['longitude'].toString());
          final bool showExact = workerDetails['showExactLocation'] ?? false;

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
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: lightSeaGreen,
                        child: Icon(Icons.person, size: 45, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(liveName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(liveProf, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(liveRating, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('($liveReviews reviews)', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                _infoTile(Icons.description_outlined, "Description", bio),

                // --- MAP BUTTON INSIDE TILE ---
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: lightSeaGreen),
                    title: const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$address, $city"),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerMapScreen(
                              workerLat: lat,
                              workerLng: lng,
                              address: address,
                              city: city,
                              showExactLocation: showExact,
                            )));
                          },
                          child: const Text("View on Map", style: TextStyle(color: lightSeaGreen, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        )
                      ],
                    ),
                  ),
                ),

                _infoTile(Icons.phone_outlined, "Phone", phone),
              ],
            ),
          );
        },
      ),

      // --- BOTTOM NAVIGATION (RESTORED) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: lightSeaGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) return; // Already on Profile

          if (index == 1) {
            // Chat Navigation
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerChatScreen(
                otherUserUid: _workerUid,
                otherUserName: widget.workerData['name'] ?? "User",
                profession: widget.workerData['workerDetails']?['profession']
            )));
          } else if (index == 2) {
            // Reviews Navigation
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerReviewsScreen(
                workerUid: _workerUid,
                name: widget.workerData['name'] ?? "User",
                profession: widget.workerData['workerDetails']?['profession'] ?? "",
                rating: (widget.workerData['workerDetails']?['rating'] ?? 0).toString(),
                reviews: (widget.workerData['workerDetails']?['reviewCount'] ?? 0).toString(),
                distance: "N/A"
            )));
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

  Widget _infoTile(IconData icon, String title, String val) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: lightSeaGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(val),
      ),
    );
  }
}