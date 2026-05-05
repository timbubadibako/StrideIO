import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/workout_storage_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceHighlight,
          title: const Text('Clear history?'),
          content: const Text(
            'This will remove all locally saved workout sessions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(workoutStorageServiceProvider).clearAllWorkouts();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.read(workoutStorageServiceProvider).getAllWorkouts();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Cyber Grid Background (matching social/profile)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: CyberGridPainter()),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'WORKOUT HISTORY',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.neonCyan,
                                letterSpacing: 2.0,
                              ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: workouts.isEmpty ? null : _clearHistory,
                        icon: const Icon(Icons.delete_sweep, size: 18),
                        label: const Text('CLEAR'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.secondary,
                        ),
                      ),
                    ],
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final workout =
                                  workouts[workouts.length - 1 - index];
                              final startedAt = DateTime.parse(
                                workout['startedAt'] as String,
                              );
                              final endedAt = workout['endedAt'] != null
                                  ? DateTime.parse(workout['endedAt'] as String)
                                  : null;
                              final distanceKm =
                                  ((workout['distanceMeters'] as num)
                                              .toDouble() /
                                          1000.0)
                                      .toStringAsFixed(2);
                              final durationSeconds =
                                  (workout['durationSeconds'] as num).toInt();
                              final minutes = (durationSeconds / 60).floor();
                              final seconds = durationSeconds % 60;
                              final paceSec =
                                  workout['avgPaceSecondsPerKm'] != null
                                  ? (workout['avgPaceSecondsPerKm'] as num)
                                        .toDouble()
                                  : 0.0;
                              final pace = paceSec > 0
                                  ? '${(paceSec / 60).floor().toString().padLeft(2, '0')}:${(paceSec % 60).floor().toString().padLeft(2, '0')}'
                                  : '--:--';

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 12,
                                    sigmaY: 12,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceHighlight
                                          .withOpacity(0.68),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.35),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          startedAt
                                              .toLocal()
                                              .toString()
                                              .split('.')
                                              .first,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.white54,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan
      ..strokeWidth = 1.0;

    const double spacing = 32.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
