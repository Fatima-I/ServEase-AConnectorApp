import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'worker_profile.dart';
import 'worker_reviews_screen.dart';

class WorkerChatScreen extends StatefulWidget {
  final String? chatId;
  final String otherUserUid;
  final String otherUserName;
  final String? profession;
  final bool showNav;

  const WorkerChatScreen({
    super.key,
    this.chatId,
    required this.otherUserUid,
    required this.otherUserName,
    this.profession,
    this.showNav = true,
  });

  @override
  State<WorkerChatScreen> createState() => _WorkerChatScreenState();
}

class _WorkerChatScreenState extends State<WorkerChatScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);

  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentChatId;
  String _myRealName = "User";
  Map<String, dynamic>? _fullWorkerData;

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.chatId;
    _fetchMyNameAndSetup();
    _fetchWorkerFullData();
  }

  Future<void> _fetchWorkerFullData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(widget.otherUserUid).get();
      if (doc.exists && mounted) {
        setState(() {
          _fullWorkerData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint("Error fetching worker profile: $e");
    }
  }

  Future<void> _fetchMyNameAndSetup() async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(myUid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('name')) {
        setState(() {
          _myRealName = userDoc.data()!['name'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching name: $e");
    }

    if (_currentChatId == null) {
      final idCandidate = myUid.compareTo(widget.otherUserUid) < 0
          ? "${myUid}_${widget.otherUserUid}"
          : "${widget.otherUserUid}_$myUid";
      setState(() => _currentChatId = idCandidate);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentChatId == null) return;
    _messageController.clear();

    final myUid = _auth.currentUser!.uid;
    final chatRef = _firestore.collection('chats').doc(_currentChatId);

    await chatRef.collection('messages').add({
      'text': text,
      'senderId': myUid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.set({
      'participants': [myUid, widget.otherUserUid],
      'participantNames': {
        myUid: _myRealName,
        widget.otherUserUid: widget.otherUserName,
      },
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _openProfile() {
    String nameToPass = widget.otherUserName;
    String professionToPass = widget.profession ?? "Worker";

    if (_fullWorkerData != null) {
      nameToPass = _fullWorkerData!['name'] ?? nameToPass;
      if (_fullWorkerData!.containsKey('workerDetails')) {
        professionToPass = _fullWorkerData!['workerDetails']['profession'] ?? professionToPass;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerProfileScreen(
          workerUid: widget.otherUserUid,
          name: nameToPass,
          profession: professionToPass,
          rating: "0.0",
          reviews: "0",
          distance: "0.0",
          fromChat: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightSeaGreen,
        title: InkWell(
          onTap: _openProfile,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(widget.otherUserName, style: const TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentChatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_currentChatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: Text("Start a conversation"));
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == myUid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? lightSeaGreen : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          data['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: lightSeaGreen,
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                )
              ],
            ),
          ),
        ],
      ),
      // *** REMOVED BOTTOM NAV AS REQUESTED ***
    );
  }
}