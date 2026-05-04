import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/workout_storage_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.read(workoutStorageServiceProvider).getAllWorkouts();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'WORKOUT HISTORY',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.neonCyan,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Past runs and saved sessions are kept locally for offline access.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: workouts.isEmpty
                    ? Center(
                        child: Text(
                          'No workouts yet. Start a run to populate history.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: workouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final workout = workouts[workouts.length - 1 - index];
                          final startedAt = DateTime.parse(
                            workout['startedAt'] as String,
                          );
                          final endedAt = workout['endedAt'] != null
                              ? DateTime.parse(workout['endedAt'] as String)
                              : null;
                          final distanceKm =
                              ((workout['distanceMeters'] as num).toDouble() /
                                      1000.0)
                                  .toStringAsFixed(2);
                          final durationSeconds =
                              (workout['durationSeconds'] as num).toInt();
                          final minutes = (durationSeconds / 60).floor();
                          final seconds = durationSeconds % 60;
                          final paceSec = workout['avgPaceSecondsPerKm'] != null
                              ? (workout['avgPaceSecondsPerKm'] as num)
                                    .toDouble()
                              : 0.0;
                          final pace = paceSec > 0
                              ? '${(paceSec / 60).floor().toString().padLeft(2, '0')}:${(paceSec % 60).floor().toString().padLeft(2, '0')}'
                              : '--:--';

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  startedAt
                                      .toLocal()
                                      .toString()
                                      .split('.')
                                      .first,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _historyStat(
                                      context,
                                      'Dist',
                                      '$distanceKm km',
                                    ),
                                    const SizedBox(width: 12),
                                    _historyStat(
                                      context,
                                      'Time',
                                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                                    ),
                                    const SizedBox(width: 12),
                                    _historyStat(context, 'Pace', pace),
                                  ],
                                ),
                                if (endedAt != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Ended ${endedAt.toLocal().hour.toString().padLeft(2, '0')}:${endedAt.toLocal().minute.toString().padLeft(2, '0')}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.white54),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyStat(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.neonCyan,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
