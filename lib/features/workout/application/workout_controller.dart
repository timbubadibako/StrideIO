import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // For distance calculation
import '../../../core/domain/models/workout_session.dart';
import '../../../core/domain/models/position_sample.dart';
import '../../../core/domain/repositories/tracking_source.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/workout_storage_service.dart';

final trackingSourceProvider = Provider<TrackingSource>((ref) {
  return LocationService();
});

final workoutControllerProvider =
    NotifierProvider<WorkoutController, WorkoutSession>(() {
      return WorkoutController();
    });

class WorkoutController extends Notifier<WorkoutSession> {
  StreamSubscription<PositionSample>? _positionSub;
  Timer? _timer;
  bool _skipNextDistance = false;

  @override
  WorkoutSession build() {
    return WorkoutSession(
      id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'local_user', // dummy
      startedAt: DateTime.now(),
    );
  }

  TrackingSource get _trackingSource => ref.read(trackingSourceProvider);

  List<PositionSample> get route => state.points;

  void start() {
    // Reset state for a fresh workout
    state = WorkoutSession(
      id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'local_user', // dummy
      startedAt: DateTime.now(),
      state: WorkoutState.running,
      points: const [],
      avgPaceSecondsPerKm: null,
    );

    _skipNextDistance = false;
    _startTimer();
    _startPositionSubscription();
  }

  void pause() {
    _timer?.cancel();
    _positionSub?.cancel();
    state = state.copyWith(state: WorkoutState.paused);
  }

  void resume() {
    state = state.copyWith(state: WorkoutState.running);
    _skipNextDistance = state.points.isNotEmpty;
    _startTimer();
    _startPositionSubscription(skipNextDistance: _skipNextDistance);
  }

  Future<void> end() async {
    _timer?.cancel();
    _positionSub?.cancel();
    state = state.copyWith(state: WorkoutState.ended, endedAt: DateTime.now());
    await ref.read(workoutStorageServiceProvider).saveWorkout(state);
  }

  void toggleGhostMode() {
    state = state.copyWith(ghostMode: !state.ghostMode);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.state == WorkoutState.running) {
        state = state.copyWith(durationSeconds: state.durationSeconds + 1);
        _updateDerivedMetrics();
      }
    });
  }

  void _startPositionSubscription({bool skipNextDistance = false}) {
    _positionSub?.cancel();
    _skipNextDistance = skipNextDistance;

    _positionSub = _trackingSource.watchPosition().listen((sample) {
      if (state.state == WorkoutState.running) {
        _processNewPosition(sample);
      }
    });
  }

  void _processNewPosition(PositionSample sample) {
    if (state.state != WorkoutState.running) return;

    final currentPoints = List<PositionSample>.from(state.points);
    double newDistance = state.distanceMeters;

    if (currentPoints.isNotEmpty) {
      if (_skipNextDistance) {
        _skipNextDistance = false;
      } else {
        final last = currentPoints.last;
        final distance = Geolocator.distanceBetween(
          last.lat,
          last.lng,
          sample.lat,
          sample.lng,
        );
        newDistance += distance;
      }
    }

    currentPoints.add(sample);

    state = state.copyWith(points: currentPoints, distanceMeters: newDistance);

    _updateDerivedMetrics();
  }

  void _updateDerivedMetrics() {
    double? pace;
    if (state.distanceMeters > 0) {
      pace = state.durationSeconds / (state.distanceMeters / 1000.0);
    }

    // Very dummy calorie estimate: ~1 kcal per kg per km. Assuming 70kg.
    double calories = 70.0 * (state.distanceMeters / 1000.0);

    state = state.copyWith(
      avgPaceSecondsPerKm: pace,
      caloriesEstimate: calories,
    );
  }
}
