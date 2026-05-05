import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/workout_session.dart';

final workoutStorageServiceProvider = Provider<WorkoutStorageService>((ref) {
  return WorkoutStorageService();
});

class WorkoutStorageService {
  static const String _boxName = 'workouts';

  Box<dynamic> get _box => Hive.box(_boxName);

  Future<void> saveWorkout(WorkoutSession workout) async {
    await _box.add({
      'id': workout.id,
      'startedAt': workout.startedAt.toIso8601String(),
      'endedAt': workout.endedAt?.toIso8601String(),
      'state': workout.state.name,
      'durationSeconds': workout.durationSeconds,
      'distanceMeters': workout.distanceMeters,
      'avgPaceSecondsPerKm': workout.avgPaceSecondsPerKm,
      'caloriesEstimate': workout.caloriesEstimate,
      'ghostMode': workout.ghostMode,
      'source': workout.source,
      'points': workout.points.map((point) => point.toJson()).toList(),
    });
  }

  List<Map<String, dynamic>> getAllWorkouts() {
    return _box.values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> clearAllWorkouts() async {
    await _box.clear();
  }
}
