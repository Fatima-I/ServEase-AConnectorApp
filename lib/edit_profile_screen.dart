import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final bool isWorker;

  const ProfileScreen({super.key, this.isWorker = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFE0F7F5);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  bool _isLoading = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Worker fields
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';

          if (widget.isWorker) {
            Map<String, dynamic> wDetails = data['workerDetails'] ?? {};
            _professionController.text = wDetails['profession'] ?? '';
            _experienceController.text = wDetails['experience'] ?? '';
            _addressController.text = wDetails['address'] ?? '';
            _cityController.text = wDetails['city'] ?? '';
            _bioController.text = wDetails['bio'] ?? '';
          } else {
            // If user stores address in root or specific userDetails
            _addressController.text = data['address'] ?? '';
            _cityController.text = data['city'] ?? '';
          }
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> updates = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    if (widget.isWorker) {
      updates['workerDetails.profession'] = _professionController.text.trim();
      updates['workerDetails.experience'] = _experienceController.text.trim();
      updates['workerDetails.address'] = _addressController.text.trim();
      updates['workerDetails.city'] = _cityController.text.trim();
      updates['workerDetails.bio'] = _bioController.text.trim();
    } else {
      updates['address'] = _addressController.text.trim();
      updates['city'] = _cityController.text.trim();
    }

    try {
      await _firestore.collection('users').doc(user.uid).update(updates);
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!'), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: lightSeaGreen,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar and header
            const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: lightSeaGreen)),
            const SizedBox(height: 20),

            _buildTextField(_nameController, 'Full Name', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Phone', Icons.phone),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Address', Icons.location_on),
            const SizedBox(height: 16),
            _buildTextField(_cityController, 'City', Icons.location_city),

            if (widget.isWorker) ...[
              const SizedBox(height: 16),
              _buildTextField(_professionController, 'Profession', Icons.work),
              const SizedBox(height: 16),
              _buildTextField(_experienceController, 'Experience', Icons.timeline),
              const SizedBox(height: 16),
              _buildTextField(_bioController, 'Bio', Icons.info, maxLines: 3),
            ],

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _isEditing ? Colors.green : lightSeaGreen),
                onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
                child: Text(_isEditing ? 'Save Changes' : 'Edit Profile', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: lightSeaGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}