import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/workout_controller.dart';
import '../../../../core/domain/models/workout_session.dart';
import '../../../map/presentation/widgets/stride_map_view.dart';
import 'post_run_summary_screen.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutControllerProvider);
    final workoutController = ref.read(workoutControllerProvider.notifier);

    // Format time (mm:ss)
    final minutes = (workout.durationSeconds / 60).floor();
    final seconds = workout.durationSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Format pace (mm:ss /km)
    final paceStr = workout.avgPaceSecondsPerKm != null
        ? '${(workout.avgPaceSecondsPerKm! / 60).floor().toString().padLeft(2, '0')}:${(workout.avgPaceSecondsPerKm! % 60).floor().toString().padLeft(2, '0')}'
        : '--:--';

    // Format distance (km)
    final distKm = (workout.distanceMeters / 1000).toStringAsFixed(2);

    // Heart rate (Mock for now)
    final bpm = workout.state == WorkoutState.running ? '164' : '---';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Map Layer
          Positioned.fill(child: const StrideMapView()),

          // Gradient Overlay to make text readable (subtle, not transparent)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background.withOpacity(0.95),
                    AppTheme.background.withOpacity(0.85),
                    AppTheme.background.withOpacity(0.98),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Header - Icon + Text LEFT, Avatars RIGHT
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.directions_run,
                            color: AppTheme.neonCyan,
                            size: 20,
                            shadows: [
                              Shadow(
                                color: AppTheme.neonCyan.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SYNC ACTIVE',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppTheme.neonCyan,
                                  fontSize: 14,
                                  letterSpacing: 0.1,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.neonCyan.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        height: 32,
                        child: Stack(
                          children: [
                            // Avatar 1
                            Positioned(
                              left: 0,
                              child: _buildAvatar(Colors.blue),
                            ),
                            // Avatar 2 (overlapped by -8)
                            Positioned(
                              left: 24,
                              child: _buildAvatar(AppTheme.error),
                            ),
                            // +2 indicator
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.surfaceHighlight,
                                  border: Border.all(
                                    color: AppTheme.background,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '+2',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Mini Route Map Preview (live tracking)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.neonCyan.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonCyan.withOpacity(0.1),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Map Layer
                                const StrideMapView(),

                                // Overlay gradient
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppTheme.background.withOpacity(0.15),
                                      ],
                                    ),
                                  ),
                                ),

                                // Distance display - bottom left
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        distKm,
                                        style: const TextStyle(
                                          fontFamily: 'Space Grotesk',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF00F5FF),
                                        ),
                                      ),
                                      const Text(
                                        'km covered',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white60,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // LIVE indicator - top right
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonCyan.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.neonCyan.withOpacity(
                                          0.3,
                                        ),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF00F5FF),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF00F5FF),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Telemetry Bento Grid
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: _buildGlassPanel(
                                  context,
                                  'Dist',
                                  distKm,
                                  'km',
                                  Icons.route,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: _buildGlassPanel(
                                  context,
                                  'Pace',
                                  paceStr,
                                  '/km',
                                  Icons.speed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: _buildGlassPanel(
                                  context,
                                  'Time',
                                  timeStr,
                                  '',
                                  Icons.timer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: _buildGlassPanel(
                                  context,
                                  'BPM',
                                  bpm,
                                  '',
                                  Icons.favorite,
                                  isAlert: true,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Territory Acquired Widget
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighlight.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              left: BorderSide(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TERRITORY ACQUIRED',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: AppTheme.secondary,
                                              shadows: [
                                                Shadow(
                                                  color: AppTheme.secondary
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                      ),
                                      Text(
                                        'Sectors claimed this session',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '03',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(color: AppTheme.secondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: 0.75,
                                backgroundColor: AppTheme.surfaceHighlight,
                                color: AppTheme.secondary,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 120), // Padding for footer
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Footer Controls
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppTheme.background,
              AppTheme.background.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ghost Mode Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_off,
                    color: AppTheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GHOST MODE',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: workout.ghostMode,
                    onChanged: (val) {
                      workoutController.toggleGhostMode();
                    },
                    activeColor: AppTheme.secondary,
                    activeTrackColor: AppTheme.surfaceHighlight,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (workout.state == WorkoutState.running) {
                        workoutController.pause();
                      } else if (workout.state == WorkoutState.paused) {
                        workoutController.resume();
                      }
                    },
                    icon: Icon(
                      workout.state == WorkoutState.running
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      workout.state == WorkoutState.running
                          ? 'PAUSE'
                          : 'RESUME',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      backgroundColor: AppTheme.surfaceHighlight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await workoutController.end();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostRunSummaryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.stop_circle,
                      color: AppTheme.deepDark,
                    ),
                    label: const Text(
                      'END RUN',
                      style: TextStyle(
                        color: AppTheme.deepDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.neonCyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppTheme.background, width: 2),
      ),
      child: const Icon(Icons.person, size: 20, color: Colors.white),
    );
  }

  Widget _buildGlassPanel(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon, {
    bool isAlert = false,
  }) {
    print('DEBUG: Panel=$title, Value=$value, Unit=$unit');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHighlight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: AppTheme.neonCyan.withOpacity(0.1), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppTheme.neonCyan),
                  const SizedBox(width: 6),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (isAlert)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.error,
                  ),
                ),
            ],
          ),

          // Value + Unit (ALWAYS VISIBLE)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isEmpty ? '00.00' : value,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00F5FF), // Hardcode cyan
                    fontSize: 32,
                    height: 1.0,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
