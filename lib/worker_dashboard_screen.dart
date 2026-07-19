import 'package:flutter/material.dart';
import 'marketplace_screen.dart';
import 'user_all_chats_list_screen.dart';
import 'worker_view_review.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  int _currentIndex = 0;

  // Navigator Keys to keep tabs independent and maintain state
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  // Back button handling
  Future<bool> _onWillPop() async {
    final NavigatorState? currentNavigator = _navigatorKeys[_currentIndex]?.currentState;

    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    // Go back to Marketplace tab if on others
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Marketplace
            _buildNavigator(0, const WorkerFeedScreen(isWorker: true)),

            // Tab 1: Chats
            _buildNavigator(1, const UserChatListScreen()),

            // Tab 2: My Reviews
            _buildNavigator(2, const WorkerViewScreen()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: lightSeaGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == _currentIndex) {
              _navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _currentIndex = index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shop_outlined),
              activeIcon: Icon(Icons.shop),
              label: "Marketplace",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              activeIcon: Icon(Icons.star),
              label: "My Reviews",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }
}