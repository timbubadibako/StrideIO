import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/state/ui_load_state.dart';
import '../../../../ui/state/ui_demo_state_providers.dart';
import '../../../map/presentation/widgets/stride_map_view.dart';
import '../../application/workout_controller.dart';

class PostRunSummaryScreen extends ConsumerWidget {
  const PostRunSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(postRunUiStateProvider);
    final workout = ref.read(workoutControllerProvider);
    final isLoading = uiState == UiLoadState.loading;

    // Formatting
    final distKm = (workout.distanceMeters / 1000).toStringAsFixed(2);
    final minutes = (workout.durationSeconds / 60).floor();
    final seconds = workout.durationSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final paceStr = workout.avgPaceSecondsPerKm != null
        ? '${(workout.avgPaceSecondsPerKm! / 60).floor().toString().padLeft(2, '0')}:${(workout.avgPaceSecondsPerKm! % 60).floor().toString().padLeft(2, '0')}'
        : '--:--';

    return Skeletonizer(
      enabled: isLoading,
      effect: ShimmerEffect(
        baseColor: AppTheme.surfaceHighlight,
        highlightColor: AppTheme.neonCyan.withOpacity(0.1),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHighlight.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ),
                    Text(
                      'MISSION COMPLETE',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppTheme.neonCyan,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: AppTheme.neonCyan.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(width: 40), // Spacer
                  ],
                ),
                const SizedBox(height: 24),

                // Map View Hero Section
                Container(
                  height: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.neonCyan.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withOpacity(0.15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const StrideMapView(),
                ),
                const SizedBox(height: 24),

                // Stats Bento Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Distance',
                        value: distKm,
                        unit: 'km',
                        icon: Icons.route,
                        color: AppTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Time',
                        value: timeStr,
                        unit: '',
                        icon: Icons.timer,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Avg Pace',
                        value: paceStr,
                        unit: '/km',
                        icon: Icons.speed,
                        color: AppTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Calories',
                        value: workout.caloriesEstimate.toStringAsFixed(0),
                        unit: 'kcal',
                        icon: Icons.local_fire_department,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Faction Points Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FACTION POINTS',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+500',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: Colors.amber,
                                  shadows: [
                                    Shadow(
                                      color: Colors.amber.withOpacity(0.5),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                          ),
                        ],
                      ),
                      const Icon(Icons.stars, color: Colors.amber, size: 48),
                    ],
                  ),
                ),

                const Spacer(),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share, color: AppTheme.deepDark),
                        label: const Text(
                          'SHARE TO STRAVA',
                          style: TextStyle(
                            color: AppTheme.deepDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonCyan,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                        icon: const Icon(
                          Icons.workspace_premium,
                          color: AppTheme.neonCyan,
                        ),
                        label: const Text(
                          'VIEW DOMINATION',
                          style: TextStyle(
                            color: AppTheme.neonCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.neonCyan.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHighlight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: color,
                  shadows: [
                    Shadow(color: color.withOpacity(0.4), blurRadius: 12),
                  ],
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(color: Colors.white70)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
