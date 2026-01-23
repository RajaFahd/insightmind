import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'screening_screen.dart';
import 'emotional_detector_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainTabs extends StatefulWidget {
  static const routeName = '/main';
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => MainTabsState();
}

class MainTabsState extends State<MainTabs> {
  int _index = 0;
  final GlobalKey<_HomeScreenState> _homeKey = GlobalKey<_HomeScreenState>();

  void _onTap(int idx) {
    setState(() => _index = idx);
    // Refresh home when switching to home tab
    if (idx == 0) {
      _refreshHome();
    }
  }

  void _goToScreening() {
    setState(() => _index = 1);
  }

  void _refreshHome() {
    // Trigger refresh on HomeScreen
    _homeKey.currentState?.loadAllData();
  }

  // Public method to refresh home from other screens
  void refreshHomeData() {
    _refreshHome();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        key: _homeKey,
        onTabSelected: (i) {
          if (i == 1) _goToScreening();
        },
      ),
      const ScreeningScreen(),
      const EmotionalDetectorScreen(),
      const HistoryScreen(),
      ProfileScreen(onProfileUpdated: _refreshHome),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: AppBottomNavBar(currentIndex: _index, onTap: _onTap),
      ),
    );
  }
}

// Make _HomeScreenState accessible
typedef _HomeScreenState = HomeScreenState;
