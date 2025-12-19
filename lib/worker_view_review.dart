import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerViewScreen extends StatelessWidget {
  const WorkerViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    const Color lightSeaGreen = Color(0xFF20B2AA);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reviews"),
        backgroundColor: lightSeaGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch reviews for CURRENT LOGGED IN USER (Worker)
        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No reviews yet", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String reviewerId = data['reviewerId'] ?? '';

              // Fetch the Real Name of the reviewer
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(reviewerId).get(),
                builder: (context, userSnapshot) {
                  String realName = "User";
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    realName = userSnapshot.data!['name'] ?? "User";
                  } else {
                    realName = data['reviewerName'] ?? "User";
                  }

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lightSeaGreen.withOpacity(0.1),
                        child: Text(realName.isNotEmpty ? realName[0].toUpperCase() : 'U', style: const TextStyle(color: lightSeaGreen, fontWeight: FontWeight.bold)),
                      ),
                      title: Row(
                        children: [
                          Text(realName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(" ${data['rating']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(data['text'] ?? "", style: const TextStyle(color: Colors.black87)),
                      ),
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