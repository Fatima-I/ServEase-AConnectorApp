import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_worker_chat_screen.dart';

class UserChatListScreen extends StatelessWidget {
  final bool isWorker;

  const UserChatListScreen({super.key, this.isWorker = false});

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    String hour = date.hour > 12 ? (date.hour - 12).toString() : (date.hour == 0 ? '12' : date.hour.toString());
    String minute = date.minute.toString().padLeft(2, '0');
    String period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    const Color lightSeaGreen = Color(0xFF20B2AA);
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) return const Scaffold(body: Center(child: Text("Please login first")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: lightSeaGreen,
        automaticallyImplyLeading: false,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: myUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No chats yet."));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.symmetric(vertical: 4),
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
                    displayName = userData['name'] ?? 'User';
                    if (userData.containsKey('workerDetails')) {
                      profession = userData['workerDetails']['profession'];
                    }
                  } else {
                    final names = data['participantNames'] as Map<String, dynamic>? ?? {};
                    displayName = names[otherUid] ?? 'User';
                  }

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: lightSeaGreen.withOpacity(0.15),
                          child: const Icon(Icons.person, color: lightSeaGreen, size: 30),
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data['lastMessage'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatTime(data['lastMessageTime']), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            // Mock unread indicator for professional look
                            const Icon(Icons.done_all, color: Colors.blue, size: 16),
                          ],
                        ),
                        onTap: () {
                          // USE rootNavigator to hide the Dashboard bar
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => WorkerChatScreen(
                                chatId: chatDoc.id,
                                otherUserUid: otherUid,
                                otherUserName: displayName,
                                profession: profession,
                                showNav: false, // Internal nav hidden
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 80, endIndent: 16),
                    ],
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