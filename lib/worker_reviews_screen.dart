import 'dart:convert'; // Added for Cloudinary
import 'package:http/http.dart' as http; // Added for Cloudinary
import 'dart:io';
import 'dart:typed_data'; // Needed for universal Image bytes
import 'package:flutter/foundation.dart'; // To check kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'worker_profile.dart';
import 'user_worker_chat_screen.dart';

class WorkerReviewsScreen extends StatefulWidget {
  final String workerUid;
  final String name;
  final String profession;
  final String rating;
  final String reviews;
  final String distance;
  final bool fromChat;

  const WorkerReviewsScreen({
    super.key,
    required this.workerUid,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviews,
    required this.distance,
    this.fromChat = false,
  });

  @override
  State<WorkerReviewsScreen> createState() => _WorkerReviewsScreenState();
}

class _WorkerReviewsScreenState extends State<WorkerReviewsScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  final TextEditingController _textCtrl = TextEditingController();
  double _rating = 5.0;

  // --- FILL THESE FROM YOUR CLOUDINARY DASHBOARD ---
  final String cloudName = "dvpgherxw";
  final String uploadPreset = "servease";

  // --- Universal Image Variables ---
  Uint8List? _selectedImageBytes; // Stores image in memory for universal compatibility
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50, // Compress to ensure success
      maxWidth: 800,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Works for both Camera and Gallery
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  // --- Cloudinary Upload Logic (Bypasses Firebase Storage Credit Card) ---
  Future<String?> _uploadToCloudinary(Uint8List bytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'review_upload.jpg'));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        return json['secure_url']; // This is the public URL to store in Firestore
      } else {
        debugPrint("Cloudinary Error: $responseData");
        return null;
      }
    } catch (e) {
      debugPrint("Upload Exception: $e");
      return null;
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: lightSeaGreen),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: lightSeaGreen),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _post() async {
    if (_textCtrl.text.trim().isEmpty) return;
    if (_isUploading) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to review")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      if (_selectedImageBytes != null) {
        // Upload to Cloudinary instead of Firebase Storage
        imageUrl = await _uploadToCloudinary(_selectedImageBytes!);

        if (imageUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to upload image to Cloudinary")));
          }
          setState(() => _isUploading = false);
          return;
        }
      }

      final workerRef = FirebaseFirestore.instance.collection('users').doc(widget.workerUid);
      String myName = "User";
      final myDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (myDoc.exists) myName = myDoc['name'] ?? "User";

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
          'text': _textCtrl.text.trim(),
          'rating': _rating,
          'reviewerId': user.uid,
          'reviewerName': myName,
          'timestamp': FieldValue.serverTimestamp(),
          if (imageUrl != null) 'imageUrl': imageUrl,
        });
      });

      _textCtrl.clear();
      setState(() {
        _rating = 5.0;
        _selectedImageBytes = null;
        _isUploading = false;
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review Posted!")));

    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerProfileScreen(
          workerUid: widget.workerUid,
          name: widget.name,
          profession: widget.profession,
          rating: widget.rating,
          reviews: widget.reviews,
          distance: widget.distance,
          fromChat: widget.fromChat,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isMe = user?.uid == widget.workerUid;
    int currentIndex = widget.fromChat ? 1 : 2;

    return Scaffold(
      appBar: AppBar(title: const Text("Reviews"), backgroundColor: lightSeaGreen),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.workerUid).collection('reviews').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data?.docs ?? [];
          bool hasReviewed = docs.any((doc) => doc['reviewerId'] == user?.uid);

          return Column(
            children: [
              if (!isMe && !hasReviewed)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text("Rate: "),
                        Expanded(child: Slider(value: _rating, min: 1, max: 5, divisions: 4, label: "$_rating", activeColor: lightSeaGreen, onChanged: (v) => setState(() => _rating = v))),
                        Text("$_rating", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]),

                      // --- Preview Area (Using memory bytes) ---
                      if (_selectedImageBytes != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_selectedImageBytes!, width: 80, height: 80, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImageBytes = null),
                                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        ),

                      Row(children: [
                        Expanded(child: TextField(controller: _textCtrl, decoration: const InputDecoration(hintText: "Write a review..."))),
                        const SizedBox(width: 8),

                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: lightSeaGreen),
                          onPressed: _showPickerOptions,
                        ),

                        ElevatedButton(
                          onPressed: _isUploading ? null : _post,
                          style: ElevatedButton.styleFrom(backgroundColor: lightSeaGreen),
                          child: _isUploading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Post", style: TextStyle(color: Colors.white)),
                        ),
                      ]),
                    ],
                  ),
                )
              else if (!isMe && hasReviewed)
                Container(padding: const EdgeInsets.all(12), color: Colors.grey[100], child: const Text("You have already reviewed this worker.", style: TextStyle(color: Colors.grey))),

              Expanded(
                child: docs.isEmpty ? const Center(child: Text("No reviews yet.")) : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String? reviewImage = data['imageUrl'];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(backgroundColor: lightSeaGreen.withOpacity(0.2), child: const Icon(Icons.person, color: lightSeaGreen)),
                              title: Text(data['reviewerName'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(" ${data['rating']}")],),
                            ),
                            Text(data['text'] ?? "", style: const TextStyle(fontSize: 15)),

                            if (reviewImage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    reviewImage,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(height: 150, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator()));
                                    },
                                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: isMe ? null : BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: lightSeaGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (widget.fromChat) {
            if (index == 0) _navigateToProfile();
          } else {
            if (index == 0) _navigateToProfile();
            if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerChatScreen(otherUserUid: widget.workerUid, otherUserName: widget.name, profession: widget.profession)));
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          if (!widget.fromChat) const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          const BottomNavigationBarItem(icon: Icon(Icons.reviews_outlined), label: "Reviews"),
        ],
      ),
    );
  }
}