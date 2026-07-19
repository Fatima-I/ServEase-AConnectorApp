import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'get_started_screen.dart';
import 'worker_profile.dart'; // Import to view profiles

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const GetStartedScreen()), (route) => false);
  }

  void _deleteUser(String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ban User?"),
        content: Text("Are you sure you want to permanently remove $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async { Navigator.pop(ctx); await FirebaseFirestore.instance.collection('users').doc(uid).delete(); }, child: const Text("Ban", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: lightSeaGreen,
        actions: [IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout, color: Colors.white))],
        bottom: TabBar(controller: _tabController, indicatorColor: Colors.white, tabs: const [Tab(text: "Users"), Tab(text: "Workers")]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildList('user'), _buildList('worker')],
      ),
    );
  }

  Widget _buildList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: role).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No $role found."));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            String id = doc.id;
            String name = data['name'] ?? 'Unknown';
            bool isApproved = data['isApproved'] ?? true;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: (role == 'worker' && !isApproved) ? Colors.orange.shade50 : Colors.white,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfileScreen(
                        workerUid: id,
                        name: name,
                        profession: role == 'worker' ? (data['workerDetails']?['profession'] ?? 'Worker') : 'User Account',
                        rating: role == 'worker' ? (data['workerDetails']?['rating']?.toString() ?? '0.0') : 'N/A',
                        reviews: role == 'worker' ? (data['workerDetails']?['reviewCount']?.toString() ?? '0') : 'N/A',
                        distance: '0.0',
                        isAdminViewingUser: role == 'user', // Passing flag to identify account type
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                    backgroundColor: role == 'worker' ? (isApproved ? Colors.green : Colors.orange) : lightSeaGreen,
                    child: Icon(role == 'worker' ? Icons.handyman : Icons.person, color: Colors.white)
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(role == 'user' ? "Registered User" : (isApproved ? "Approved Account" : "PENDING APPROVAL")),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (role == 'worker' && !isApproved)
                      IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () async { await FirebaseFirestore.instance.collection('users').doc(id).update({'isApproved': true}); }
                      ),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(id, name)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}