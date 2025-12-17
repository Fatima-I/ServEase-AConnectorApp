import 'package:flutter/material.dart';
import 'worker_profile.dart';
import 'worker_reviews_screen.dart';

class WorkerChatScreen extends StatefulWidget {
  final String username;
  final String name;
  final String profession;
  final String description;
  final String location;
  final String phone;
  final String rating;
  final String reviews;
  final String distance;

  const WorkerChatScreen({
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
  State<WorkerChatScreen> createState() => _WorkerChatScreenState();
}

class _WorkerChatScreenState extends State<WorkerChatScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);

  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  int _selectedIndex = 1;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(text));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightSeaGreen,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(widget.username),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: lightSeaGreen.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _messages[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: lightSeaGreen,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
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
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerReviewsScreen(
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
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.reviews_outlined), label: "Reviews"),
        ],
      ),
    );
  }
}
