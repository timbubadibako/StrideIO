import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../map/presentation/screens/map_dashboard_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../map/presentation/widgets/hud_bottom_nav_bar.dart';
import '../../../map/presentation/widgets/circular_start_button.dart';
import '../../../workout/presentation/screens/active_workout_screen.dart';
import '../../../workout/application/workout_controller.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapDashboardScreen(),
    const HistoryScreen(),
    const SocialScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _startWorkout() async {
    ref.read(workoutControllerProvider.notifier).start();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Map content (IndexedStack)
          IndexedStack(index: _currentIndex, children: _screens),

          // Circular START button - positioned above nav with 16dp gap
          // Only visible on Map tab (index 0)
          Positioned(
            bottom: 72, // 56 (nav height) + 16 (gap)
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CircularStartButton(
                onPressed: _startWorkout,
                isVisible: _currentIndex == 0,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HudBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
