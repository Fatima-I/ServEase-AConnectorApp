import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_all_chats_list_screen.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'worker_profile.dart';
import 'worker_reviews_screen.dart';
import 'worker_view_review.dart';

class WorkerFeedScreen extends StatefulWidget {
  final bool isWorker;

  const WorkerFeedScreen({super.key, this.isWorker = true});

  @override
  State<WorkerFeedScreen> createState() => _WorkerFeedScreenState();
}

class _WorkerFeedScreenState extends State<WorkerFeedScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  static const Color bgColor = Color(0xFFE0F7F5);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Filter values
  double _selectedRating = 0.0;
  double _selectedDistance = 10.0;

  final List<String> _categories = [
    'All', 'Plumber', 'Electrician', 'Tutor', 'Tailor',
    'Painter', 'Cleaner', 'Carpenter', 'Others'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: lightSeaGreen, size: 28),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Expanded(
                    child: Text(
                      widget.isWorker ? 'Browse Workers' : 'Find Workers',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: lightSeaGreen, size: 28),
                    onPressed: _showFilters,
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or profession...',
                  prefixIcon: const Icon(Icons.search, color: lightSeaGreen),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: bgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Category Tabs
            Container(
              color: Colors.white,
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? lightSeaGreen : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Worker List (Connected to Firebase)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'worker')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildNoDataView();
                    }

                    // CLIENT SIDE FILTERING (To match your old logic)
                    final filteredWorkers = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final workerDetails = data['workerDetails'] ?? {};

                      String name = (data['name'] ?? '').toString();
                      String profession = (workerDetails['profession'] ?? '').toString();
                      double rating = (workerDetails['rating'] ?? 0.0).toDouble();
                      // Mock distance since we don't have GPS yet
                      double distance = 5.0;

                      final matchesCategory = _selectedCategory == 'All' ||
                          profession == _selectedCategory;

                      final matchesSearch = _searchQuery.isEmpty ||
                          profession.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          name.toLowerCase().contains(_searchQuery.toLowerCase());

                      final matchesRating = rating >= _selectedRating;
                      final matchesDistance = distance <= _selectedDistance;

                      return matchesCategory && matchesSearch && matchesRating && matchesDistance;
                    }).toList();

                    if (filteredWorkers.isEmpty) {
                      return _buildNoDataView();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredWorkers.length,
                      itemBuilder: (context, index) {
                        final doc = filteredWorkers[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final workerDetails = data['workerDetails'] ?? {};

                        String name = data['name'] ?? 'Unknown';
                        String profession = workerDetails['profession'] ?? 'Worker';
                        String rating = (workerDetails['rating'] ?? 0.0).toStringAsFixed(1);
                        String reviews = (workerDetails['reviewCount'] ?? 0).toString();
                        String distance = "5.0"; // Fixed for now

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: lightSeaGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person, size: 35, color: lightSeaGreen),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profession,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$rating ($reviews)',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$distance km',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lightSeaGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // Navigating with REAL UID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkerProfileScreen(
                                      workerUid: doc.id,
                                      name: name,
                                      profession: profession,
                                      rating: rating,
                                      reviews: reviews,
                                      distance: distance,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'View',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No workers found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Filters bottom sheet
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedRating = 0.0;
                        _selectedDistance = 10.0;
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: lightSeaGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Minimum Rating',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Slider(
                value: _selectedRating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                activeColor: lightSeaGreen,
                label: _selectedRating == 0.0
                    ? 'Any'
                    : '${_selectedRating.toStringAsFixed(1)}+',
                onChanged: (value) {
                  setModalState(() => _selectedRating = value);
                },
              ),
              const SizedBox(height: 10),
              const Text('Maximum Distance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Slider(
                value: _selectedDistance,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                activeColor: lightSeaGreen,
                label: '${_selectedDistance.toStringAsFixed(0)} km',
                onChanged: (value) {
                  setModalState(() => _selectedDistance = value);
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightSeaGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Apply Filters',
                    style:
                    TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer
  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest';

    return Drawer(
      child: Container(
        color: bgColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: lightSeaGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.isWorker ? Icons.handyman_rounded : Icons.person,
                      size: 40,
                      color: lightSeaGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome!',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.shop, 'Marketplace',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            if (widget.isWorker) ...[
              _drawerItem(
                Icons.person,
                'My Profile',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfileScreen(
                        workerUid: user!.uid,
                        name: 'Me',
                        profession: 'Worker',
                        rating: '0',
                        reviews: '0',
                        distance: '0',
                      ),
                    ),
                  );
                },
              ),
              _drawerItem(
                Icons.star_rate,
                'My Reviews',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkerViewScreen(),
                    ),
                  );
                },
              ),
            ],

            _drawerItem(
              Icons.edit,
              'Edit Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(isWorker: widget.isWorker)),
                );
              },
            ),

            _drawerItem(Icons.chat, 'Chats',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserChatListScreen()),
                );
              },
            ),
            const Divider(),
            _drawerItem(Icons.info_outline, 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            const Divider(),
            _drawerItem(
              Icons.logout,
              'Logout',
              color: Colors.red,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? lightSeaGreen),
      title: Text(title, style: TextStyle(fontSize: 16, color: color ?? Colors.black87)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}