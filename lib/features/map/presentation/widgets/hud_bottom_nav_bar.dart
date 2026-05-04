import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HudBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HudBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<HudBottomNavBar> createState() => _HudBottomNavBarState();
}

class _HudBottomNavBarState extends State<HudBottomNavBar> {
  final List<({String label, IconData icon, String tooltip})> _navItems = [
    (label: 'Map', icon: Icons.explore, tooltip: 'Map View'),
    (label: 'History', icon: Icons.history, tooltip: 'Workout History'),
    (label: 'Social', icon: Icons.groups, tooltip: 'Social'),
    (label: 'Profile', icon: Icons.person, tooltip: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withOpacity(0.25),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.25),
              AppTheme.neonCyan.withOpacity(0.03),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _navItems.length,
                    (index) => _buildNavItem(context, index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final isActive = widget.currentIndex == index;
    final item = _navItems[index];

    return Tooltip(
      message: item.tooltip,
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active state: smaller pill background + brighter icon
              if (isActive)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppTheme.neonCyan, size: 26),
                )
              else
                Icon(item.icon, color: Colors.white.withOpacity(0.6), size: 26),

              const SizedBox(height: 3),

              // Label always visible (stable spacing)
              if (isActive)
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 8,
                    color: AppTheme.neonCyan,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                )
              else
                // Invisible spacer when inactive (maintains consistent height)
                SizedBox(height: 10, child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
