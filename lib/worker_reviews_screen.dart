import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'worker_profile.dart';
import 'user_worker_chat_screen.dart'; // Make sure file name matches your chat screen file

class WorkerReviewsScreen extends StatefulWidget {
  final String workerUid;
  final String name;
  final String profession;
  final String rating;
  final String reviews;
  final String distance;

  const WorkerReviewsScreen({
    super.key,
    required this.workerUid,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviews,
    required this.distance,
  });

  @override
  State<WorkerReviewsScreen> createState() => _WorkerReviewsScreenState();
}

class _WorkerReviewsScreenState extends State<WorkerReviewsScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final int _selectedIndex = 2;
  String _myRealName = "User"; // To store fetcher user name

  @override
  void initState() {
    super.initState();
    _fetchMyName();
  }

  // --- 1. Apka apna naam fetch karein (Review post karne ke liye) ---
  Future<void> _fetchMyName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('name')) {
        setState(() {
          _myRealName = doc.data()!['name'];
        });
      }
    }
  }

  void _addReview() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to review")));
      return;
    }

    await _firestore.collection('users').doc(widget.workerUid).collection('reviews').add({
      'text': text,
      'reviewerId': user.uid,
      'reviewerName': _myRealName, // Use fetched real name
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Optional: Update Worker's rating/count logic here if needed

    _reviewController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review added!")));
  }

  // --- 2. Helper to Navigate to Profile (Fixes the Error) ---
  void _navigateToProfile() async {
    try {
      // Worker ka latest data fetch karein
      DocumentSnapshot doc = await _firestore.collection('users').doc(widget.workerUid).get();

      if (doc.exists && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerProfileScreen(
              workerData: doc.data() as Map<String, dynamic>, // <-- Correct Data Passed
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error loading profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = _auth.currentUser?.uid == widget.workerUid;

    return Scaffold(
      appBar: AppBar(title: const Text("Worker Reviews"), backgroundColor: lightSeaGreen),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (!isMe)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        hintText: "Write a review...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      onSubmitted: (_) => _addReview(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(backgroundColor: lightSeaGreen),
                    child: const Text("Post", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(widget.workerUid)
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No reviews yet."));
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
                              child: const Icon(Icons.person, color: Colors.black54)
                          ),
                          title: Text(data['reviewerName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(data['text']),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: lightSeaGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == _selectedIndex) return;

          if (index == 0) {
            // FIX: Call helper function instead of direct push with old params
            _navigateToProfile();
          } else if (index == 1) {
            // Chat Navigation (Yeh already sahi hai kyunke humne chat screen update kar di thi)
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
}