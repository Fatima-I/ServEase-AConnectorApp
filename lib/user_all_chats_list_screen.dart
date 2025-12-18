import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_worker_chat_screen.dart';

class UserChatListScreen extends StatelessWidget {
  const UserChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightSeaGreen = Color(0xFF20B2AA);
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) return const Scaffold(body: Center(child: Text("Please login first")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        backgroundColor: lightSeaGreen,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: myUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No chats yet."));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final chatDoc = snapshot.data!.docs[index];
              final data = chatDoc.data() as Map<String, dynamic>;
              final List participants = data['participants'];
              final otherUid = participants.firstWhere((id) => id != myUid, orElse: () => null);

              if (otherUid == null) return const SizedBox();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
                builder: (context, userSnapshot) {
                  String displayName = '...';
                  String? profession;

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    displayName = userData['name'] ?? 'Unknown User';
                    if (userData.containsKey('workerDetails')) {
                      profession = userData['workerDetails']['profession'];
                    }
                  } else {
                    final names = data['participantNames'] as Map<String, dynamic>? ?? {};
                    displayName = names[otherUid] ?? 'User';
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: lightSeaGreen, child: const Icon(Icons.person, color: Colors.white)),
                      title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['lastMessage'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerChatScreen(
                              chatId: chatDoc.id,
                              otherUserUid: otherUid,
                              otherUserName: displayName,
                              profession: profession,
                              showNav: false, // Hides bottom bar
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}