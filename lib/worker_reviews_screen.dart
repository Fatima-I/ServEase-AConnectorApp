import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'worker_profile.dart';
import 'user_worker_chat_screen.dart';

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
  final _textCtrl = TextEditingController();
  double _rating = 5.0;
  final int _selectedIndex = 2;

  void _post() async {
    if (_textCtrl.text.isEmpty) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final workerRef = FirebaseFirestore.instance.collection('users').doc(widget.workerUid);

      // Get my real name
      String myName = "User";
      final myDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if(myDoc.exists) myName = myDoc['name'] ?? "User";

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(workerRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> wDetails = data['workerDetails'] ?? {};

        double currentRating = (wDetails['rating'] ?? 0.0).toDouble();
        int currentCount = (wDetails['reviewCount'] ?? 0).toInt();

        double newAvg = ((currentRating * currentCount) + _rating) / (currentCount + 1);
        int newCount = currentCount + 1;

        transaction.update(workerRef, {
          'workerDetails.rating': double.parse(newAvg.toStringAsFixed(1)),
          'workerDetails.reviewCount': newCount,
        });

        DocumentReference newReviewRef = workerRef.collection('reviews').doc();
        transaction.set(newReviewRef, {
          'text': _textCtrl.text,
          'rating': _rating,
          'reviewerId': user.uid,
          'reviewerName': myName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      _textCtrl.clear();
      setState(() => _rating = 5.0);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review Posted!")));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isMe = user?.uid == widget.workerUid;

    return Scaffold(
      appBar: AppBar(title: const Text("Reviews"), backgroundColor: lightSeaGreen),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.workerUid).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          bool hasReviewed = docs.any((doc) => doc['reviewerId'] == user?.uid);

          return Column(
            children: [
              if (!isMe && !hasReviewed)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Rating: "),
                          Expanded(child: Slider(value: _rating, min: 1, max: 5, divisions: 4, label: "$_rating", activeColor: lightSeaGreen, onChanged: (v) => setState(() => _rating = v))),
                          Text("$_rating", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _textCtrl, decoration: const InputDecoration(hintText: "Write a review..."))),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: _post, style: ElevatedButton.styleFrom(backgroundColor: lightSeaGreen), child: const Text("Post", style: TextStyle(color: Colors.white))),
                        ],
                      ),
                    ],
                  ),
                )
              else if (!isMe && hasReviewed)
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[100],
                  child: const Text("You have already reviewed this worker.", style: TextStyle(color: Colors.grey)),
                ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: lightSeaGreen.withOpacity(0.2), child: const Icon(Icons.person, color: lightSeaGreen)),
                        title: Text(data['reviewerName'] ?? "User"),
                        subtitle: Text(data['text'] ?? ""),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(" ${data['rating']}")],),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: lightSeaGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerProfileScreen(
                workerUid: widget.workerUid, name: widget.name, profession: widget.profession, rating: widget.rating, reviews: widget.reviews, distance: widget.distance
            )));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerChatScreen(
                otherUserUid: widget.workerUid, otherUserName: widget.name, profession: widget.profession
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
}