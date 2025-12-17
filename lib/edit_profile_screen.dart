import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final bool isWorker;

  const ProfileScreen({super.key, this.isWorker = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFE0F7F5);
  static const String dummyPassword = '1234';

  bool _isEditing = false;

  // Common fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Worker only fields
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial data based on user type
    if (widget.isWorker) {
      _nameController.text = 'Ahmad Khan';
      _emailController.text = 'ahmad@example.com';
      _phoneController.text = '+92 300 7654321';
      _addressController.text = 'Johar Town, Lahore';
      _cityController.text = 'Lahore';
      _professionController.text = 'Plumber';
      _experienceController.text = '5 years';
      _workingHoursController.text = '9 AM - 6 PM';
      _bioController.text = 'Professional plumber with 5 years of experience.';
    } else {
      _nameController.text = 'Ahmed Hassan';
      _emailController.text = 'ahmed@example.com';
      _phoneController.text = '+92 300 1234567';
      _addressController.text = 'Model Town, Lahore';
      _cityController.text = 'Lahore';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    _workingHoursController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showPasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password (1234)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: lightSeaGreen),
            onPressed: () {
              if (passwordController.text == dummyPassword) {
                Navigator.pop(context);
                setState(() => _isEditing = true);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect password!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: lightSeaGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: lightSeaGreen,
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 50, color: lightSeaGreen),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isWorker ? 'Worker Profile' : 'User Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isWorker) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(127 reviews)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                  ),

                  // Worker only fields
                  if (widget.isWorker) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _professionController,
                      label: 'Profession',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Experience',
                      icon: Icons.timeline_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _workingHoursController,
                      label: 'Working Hours',
                      icon: Icons.access_time_outlined,
                    ),
                  ],

                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city_outlined,
                  ),

                  // Worker bio field
                  if (widget.isWorker) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      icon: Icons.info_outline,
                      maxLines: 3,
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing ? Colors.green : lightSeaGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isEditing ? _saveProfile : _showPasswordDialog,
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Edit Profile',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => setState(() => _isEditing = false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: lightSeaGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightSeaGreen, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}