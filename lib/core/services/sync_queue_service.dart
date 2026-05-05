import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/workout_session.dart';
import '../../dev/dev_providers.dart';
import 'supabase_logger.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService(ref);
});

class SyncQueueService {
  final Ref _ref;
  static const String _boxName = 'sync_queue';

  SyncQueueService(this._ref);

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box<dynamic> get _box => Hive.box(_boxName);

  Future<void> enqueueWorkoutSync(WorkoutSession workout) async {
    // We store the payload that needs to be synced
    await _box.put(workout.id, {
      'id': workout.id,
      'type': 'workout_upload',
      'status': 'pending',
      'attempts': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'payload': {
        'id': workout.id,
        'startedAt': workout.startedAt.toIso8601String(),
        'endedAt': workout.endedAt?.toIso8601String(),
        'durationSeconds': workout.durationSeconds,
        'distanceMeters': workout.distanceMeters,
        'avgPaceSecondsPerKm': workout.avgPaceSecondsPerKm,
        'caloriesEstimate': workout.caloriesEstimate,
        'ghostMode': workout.ghostMode,
        'source': workout.source,
        'title': workout.title,
        'notes': workout.notes,
        // Polyline to be generated and stored here later
      }
    });
  }

  List<Map<String, dynamic>> getPendingSyncTasks() {
    return _box.values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['status'] == 'pending')
        .toList();
  }

  Future<void> markSyncTaskCompleted(String id) async {
    final task = _box.get(id);
    if (task != null) {
      final updatedTask = Map<String, dynamic>.from(task);
      updatedTask['status'] = 'completed';
      updatedTask['updatedAt'] = DateTime.now().toIso8601String();
      await _box.put(id, updatedTask);
    }
  }

  Future<void> processQueue() async {
    final tasks = getPendingSyncTasks();
    if (tasks.isEmpty) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final logEnabled = _ref.read(supabaseDevLogEnabledProvider);

    for (final task in tasks) {
      final payload = Map<String, dynamic>.from(task['payload']);
      // Map payload to Supabase schema format
      final supabasePayload = {
        'id': payload['id'],
        'user_id': user.id,
        'title': payload['title'],
        'notes': payload['notes'],
        'started_at': payload['startedAt'],
        'ended_at': payload['endedAt'],
        'duration_s': payload['durationSeconds'],
        'distance_m': payload['distanceMeters'],
        'avg_pace_spk': payload['avgPaceSecondsPerKm'],
        'calories': payload['caloriesEstimate'],
        'ghost_mode': payload['ghostMode'],
        'source': payload['source'],
      };

      try {
        await supabase.from('workouts').upsert(supabasePayload);
        await markSyncTaskCompleted(task['id']);
        SupabaseLogger.log(logEnabled, 'Sync Workout ${payload['id']}');
      } catch (e) {
        SupabaseLogger.log(logEnabled, 'Sync Workout ${payload['id']}', success: false, error: e.toString());
        // Increment attempts
        final updatedTask = Map<String, dynamic>.from(task);
        updatedTask['attempts'] = (updatedTask['attempts'] ?? 0) + 1;
        await _box.put(task['id'], updatedTask);
      }
    }
  }
}
