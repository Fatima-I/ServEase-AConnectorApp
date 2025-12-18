import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_worker_chat_screen.dart';
import 'worker_reviews_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String workerUid;
  // Optional parameters for smoother transition before data loads
  final String name;
  final String profession;
  final String rating;
  final String reviews;
  final String distance;

  const WorkerProfileScreen({
    super.key,
    required this.workerUid,
    this.name = 'Loading...',
    this.profession = '',
    this.rating = '0.0',
    this.reviews = '0',
    this.distance = '0.0',
  });

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  int _selectedIndex = 0;

  // --- REPAIR FUNCTION (Click Wrench to Fix Ratings) ---
  Future<void> _fixRatings() async {
    final workerRef = FirebaseFirestore.instance.collection('users').doc(widget.workerUid);
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.workerUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final workerDetails = data['workerDetails'] as Map<String, dynamic>? ?? {};

          final liveName = data['name'] ?? widget.name;
          final liveProf = workerDetails['profession'] ?? widget.profession;
          final liveRating = (workerDetails['rating'] ?? widget.rating).toString();
          final liveReviews = (workerDetails['reviewCount'] ?? widget.reviews).toString();
          final bio = workerDetails['bio'] ?? "No description available.";
          final phone = data['phone'] ?? "+92 300 1234567";
          final username = "@${liveName.toLowerCase().replaceAll(' ', '_')}";

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
                _infoTile(Icons.location_on_outlined, "Location", "${widget.distance} km away"),
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
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerChatScreen(
                otherUserUid: widget.workerUid, otherUserName: widget.name, profession: widget.profession
            )));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerReviewsScreen(
                workerUid: widget.workerUid, name: widget.name, profession: widget.profession, rating: widget.rating, reviews: widget.reviews, distance: widget.distance
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