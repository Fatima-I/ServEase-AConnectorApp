import 'package:flutter/material.dart';
import 'marketplace_screen.dart';
import 'worker_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralInfoScreen extends StatefulWidget {
  const GeneralInfoScreen({super.key});

  @override
  State<GeneralInfoScreen> createState() => _GeneralInfoScreenState();
}

class _GeneralInfoScreenState extends State<GeneralInfoScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFE0F7F5);

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _startTime;
  String? _endTime;
  String? _workingHoursError;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  List<String> _skills = [];

  final List<String> professions = [
    'Plumber',
    'Electrician',
    'Tutor',
    'Tailor',
    'Painter',
    'Carpenter',
    'Cleaner',
    'Others'
  ];
  String _selectedProfession = 'Plumber';

  String _gender = 'Male';
  bool? _isWorker; // null = not selected yet

  // Firestore field-specific errors
  String? _emailError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  /// ---------------- FIREBASE SAVE FUNCTION ----------------
  Future<void> _saveToFirebase() async {
    setState(() {
      _emailError = null;
      _phoneError = null;
      _workingHoursError = null;
    });

    // Check if working hours are selected for workers
    if (_isWorker! && (_startTime == null || _endTime == null)) {
      setState(() => _workingHoursError = 'Please select working hours');
      return;
    }

    // Check if email or phone already exists
    final emailQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: _emailController.text.trim())
        .get();
    if (emailQuery.docs.isNotEmpty) {
      setState(() => _emailError = 'Email is already in use');
      return;
    }

    final phoneQuery = await _firestore
        .collection('users')
        .where('phone', isEqualTo: _phoneController.text.trim())
        .get();
    if (phoneQuery.docs.isNotEmpty) {
      setState(() => _phoneError = 'Phone number is already in use');
      return;
    }

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      Map<String, dynamic> data = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": _passwordController.text.trim(), // <-- saved password
        "gender": _gender,
        "role": _isWorker! ? "worker" : "user",
        "createdAt": FieldValue.serverTimestamp(),
      };

      if (_isWorker!) {
        data["workerDetails"] = {
          "profession": _selectedProfession,
          "skills": _skills,
          "experience": _experienceController.text.trim(),
          "workingHours": "$_startTime - $_endTime",
          "address": _addressController.text.trim(),
          "city": _cityController.text.trim(),
          "bio": _bioController.text.trim(),
        };
      }

      await _firestore.collection("users").doc(uid).set(data);

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification email sent. Please verify before login."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkerFeedScreen(isWorker: _isWorker!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Password must be at least 6 characters.';
      } else {
        message = e.message ?? 'An error occurred.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /// ---------------- TEXTFIELD BUILDER ----------------
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? errorText,
    Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
      validator: validator ??
              (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: lightSeaGreen),
        labelText: label,
        hintText: 'Enter $label',
        labelStyle: const TextStyle(color: Colors.black54),
        errorText: errorText,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightSeaGreen, width: 1.5),
        ),
      ),
    );
  }

  /// ---------------- FORM ----------------
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: lightSeaGreen),
                onPressed: () => setState(() => _isWorker = null),
              ),
              Text(
                _isWorker! ? "Worker Registration" : "User Registration",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: "Full Name",
            controller: _nameController,
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Full Name';
              }
              // Remove extra spaces and count letters only
              final nameWithoutSpaces = value.trim().replaceAll(' ', '');
              final letterCount = nameWithoutSpaces.length;

              if (letterCount < 4) {
                return 'Name must be at least 4 letters';
              }
              if (letterCount > 20) {
                return 'Name must not exceed 20 letters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Email",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            errorText: _emailError,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter Email';
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
              if (!emailRegex.hasMatch(value))
                return 'Email must be in format: example@gmail.com';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Phone Number",
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            icon: Icons.phone_outlined,
            errorText: _phoneError,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter Phone Number';
              final phoneRegex = RegExp(r'^03\d{9}$');
              if (!phoneRegex.hasMatch(value))
                return 'Please enter valid 11-digit number starting with 03';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Password",
            controller: _passwordController,
            icon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter Password';
              if (value.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Gender dropdown
          Row(
            children: [
              const Icon(Icons.wc, color: lightSeaGreen),
              const SizedBox(width: 12),
              const Text("Gender: ", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 20),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: lightSeaGreen),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: _gender,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: lightSeaGreen, fontSize: 16),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
              ),
            ],
          ),
          if (_isWorker!) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.work_outline, color: lightSeaGreen),
                const SizedBox(width: 12),
                const Text("Profession: ", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 20),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: lightSeaGreen),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: _selectedProfession,
                      dropdownColor: Colors.white,
                      style:
                      const TextStyle(color: lightSeaGreen, fontSize: 16),
                      items: professions
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedProfession = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Skills:"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.grey.shade100,
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ..._skills.map((skill) => Chip(
                        label: Text(skill,
                            style: const TextStyle(color: lightSeaGreen)),
                        backgroundColor: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onDeleted: () {
                          setState(() {
                            _skills.remove(skill);
                          });
                        },
                      )),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _skillController,
                          decoration: const InputDecoration(
                            hintText: 'Add skill',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onFieldSubmitted: (value) {
                            if (value.trim().isEmpty) return;
                            setState(() {
                              _skills.add(value.trim());
                              _skillController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Experience",
              controller: _experienceController,
              icon: Icons.timeline_outlined,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: lightSeaGreen),
                    const SizedBox(width: 12),
                    const Text("Working Hours: ", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: _workingHoursError != null ? Colors.red : lightSeaGreen),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("Start Time"),
                            value: _startTime,
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            style: const TextStyle(color: lightSeaGreen, fontSize: 16),
                            items: [
                              '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM',
                              '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM',
                              '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM',
                              '7 PM', '8 PM', '9 PM', '10 PM', '11 PM', '12 AM'
                            ].map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                            onChanged: (value) => setState(() {
                              _startTime = value;
                              _workingHoursError = null;
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text("to", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: _workingHoursError != null ? Colors.red : lightSeaGreen),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("End Time"),
                            value: _endTime,
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            style: const TextStyle(color: lightSeaGreen, fontSize: 16),
                            items: [
                              '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM',
                              '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM',
                              '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM',
                              '7 PM', '8 PM', '9 PM', '10 PM', '11 PM', '12 AM'
                            ].map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                            onChanged: (value) => setState(() {
                              _endTime = value;
                              _workingHoursError = null;
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_workingHoursError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _workingHoursError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Address",
              controller: _addressController,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "City",
              controller: _cityController,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Bio",
              controller: _bioController,
              icon: Icons.info_outline,
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightSeaGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _saveToFirebase();
              }
            },
            label: const Text(
              "Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- ACCOUNT TYPE SELECTION ----------------
  Widget _buildAccountTypeSelection() {
    return Column(
      children: [
        const Icon(Icons.account_circle, size: 90, color: lightSeaGreen),
        const SizedBox(height: 20),
        const Text(
          "Choose Account Type",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        const Text(
          "Are you registering as a User or a Worker?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: lightSeaGreen,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => setState(() => _isWorker = false),
          label: const Text("Register as User",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.handyman_rounded, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => setState(() => _isWorker = true),
          label: const Text("Register as Worker",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: lightSeaGreen),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _isWorker == null
                        ? _buildAccountTypeSelection()
                        : _buildForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}