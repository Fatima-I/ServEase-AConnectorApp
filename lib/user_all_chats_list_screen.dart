import 'package:flutter/material.dart';
import 'user_worker_chat_screen.dart';

class UserChatListScreen extends StatelessWidget {
  const UserChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightSeaGreen = Color(0xFF20B2AA);

    // Dummy data for chat list
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Ali Raza',
        'profession': 'Electrician',
        'rating': '4.7',
        'reviews': '156',
        'distance': '3.2',
        'lastMessage': 'Sure, I can come tomorrow morning!',
        'time': '10:45 AM',
      },
      {
        'name': 'Sana Malik',
        'profession': 'Plumber',
        'rating': '4.9',
        'reviews': '203',
        'distance': '2.1',
        'lastMessage': 'Please share your address.',
        'time': 'Yesterday',
      },
      {
        'name': 'Hassan Raza',
        'profession': 'Carpenter',
        'rating': '4.5',
        'reviews': '92',
        'distance': '5.5',
        'lastMessage': 'I will check and let you know.',
        'time': '2 days ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        backgroundColor: lightSeaGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        itemCount: chats.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: lightSeaGreen.withOpacity(0.2),
                child: const Icon(Icons.person, color: lightSeaGreen, size: 28),
              ),
              title: Text(
                chat['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                chat['lastMessage'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Text(
                chat['time'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                // Open actual chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerChatScreen(
                      username: "@${chat['name'].toLowerCase().replaceAll(' ', '_')}",
                      name: chat['name'],
                      profession: chat['profession'],
                      description: "Experienced ${chat['profession']} with quality work.",
                      location: "${chat['distance']} km away - Lahore",
                      phone: "+92 300 1234567",
                      rating: chat['rating'],
                      reviews: chat['reviews'],
                      distance: chat['distance'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}