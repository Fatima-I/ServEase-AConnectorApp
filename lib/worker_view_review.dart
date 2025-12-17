import 'package:flutter/material.dart';
import 'worker_profile.dart';
import 'user_worker_chat_screen.dart';

class WorkerViewScreen extends StatefulWidget {
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
  State<WorkerViewScreen> createState() => _WorkerReviewsScreenState();
}

class _WorkerReviewsScreenState extends State<WorkerViewScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);

  final TextEditingController _reviewController = TextEditingController();
  final List<String> _reviews = [
    "Excellent worker! Very punctual and skilled.",
    "Good experience, polite and efficient.",
    "Average work, could improve communication.",
  ];
  int _selectedIndex = 2;

  final bool isWorker = true;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _addReview() {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _reviews.insert(0, text);
      _reviewController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Reviews"),
        backgroundColor: lightSeaGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // ✅ Worker cannot write reviews, hide text field
            if (!isWorker)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        hintText: "Write a review...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                      ),
                      onSubmitted: (_) => _addReview(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightSeaGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Enter"),
                  ),
                ],
              ),

            if (!isWorker) const SizedBox(height: 15),

            Expanded(
              child: _reviews.isEmpty
                  ? const Center(
                child: Text(
                  "No reviews yet. Be the first to write one!",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        lightSeaGreen.withOpacity(0.2),
                        child: const Icon(Icons.person,
                            color: Colors.black54),
                      ),
                      title: Text(widget.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(_reviews[index]),
                    ),
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
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerProfileScreen(
                  name: widget.name,
                  profession: widget.profession,
                  rating: widget.rating,
                  reviews: widget.reviews,
                  distance: widget.distance,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerChatScreen(
                  username: widget.username,
                  name: widget.name,
                  profession: widget.profession,
                  description: widget.description,
                  location: widget.location,
                  phone: widget.phone,
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
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined), label: "Reviews"),
        ],
      ),
    );
  }
}
