import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Note: Imports for bottom nav or profile are optional here depending on if you want navigation
// For "My Reviews", usually it's just a back button to the Drawer/Home.

class WorkerViewScreen extends StatefulWidget {
  // We might not need all these passed in if we are just fetching for "current user"
  // but keeping them to match your existing navigation structure.
  final String username;
  final String name;
  final String profession;
  final String description;
  final String location;
  final String phone;
  final String rating;
  final String reviews;
  final String distance;

  const WorkerViewScreen({
    super.key,
    required this.username,
    required this.name,
    required this.profession,
    required this.description,
    required this.location,
    required this.phone,
    required this.rating,
    required this.reviews,
    required this.distance,
  });

  @override
  State<WorkerViewScreen> createState() => _WorkerViewScreenState();
}

class _WorkerViewScreenState extends State<WorkerViewScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final myUid = _auth.currentUser?.uid;

    if (myUid == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reviews"),
        backgroundColor: lightSeaGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Header Stats (Optional)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      "${widget.rating} Rating",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "(${widget.reviews} Reviews)",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Reviews List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(myUid) // Fetching reviews for ME (the logged in worker)
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No reviews yet", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: lightSeaGreen.withOpacity(0.2),
                            child: const Icon(Icons.person, color: Colors.black54),
                          ),
                          title: Text(
                            data['reviewerName'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(data['text']),
                            ],
                          ),
                          // Optional: Show timestamp
                          // trailing: Text(
                          //   // Format timestamp here if needed
                          //   "Date",
                          //   style: TextStyle(fontSize: 12, color: Colors.grey),
                          // ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}