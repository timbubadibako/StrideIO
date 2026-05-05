import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/domain/models/position_sample.dart';
import '../core/domain/repositories/tracking_source.dart';

class FakeLocationConfig {
  final double centerLat;
  final double centerLng;
  final double loopDistanceMeters;
  final int durationSeconds;
  final Duration sampleInterval;
  final double accuracyMeanMeters;
  final double accuracyStdMeters;
  final bool includeJitter;
  final bool loopForever;
  final double? startAngleDeg;
  final bool variablePace;
  final bool simulateDropouts;
  final double dropoutProbability;
  final bool paused;
  final bool showRawPoints;
  final bool showDisplayPoints;
  final bool showSampleRate;
  final bool showLastAccuracy;
  final bool showCumulativeDistance;

  const FakeLocationConfig({
    required this.centerLat,
    required this.centerLng,
    required this.loopDistanceMeters,
    required this.durationSeconds,
    required this.sampleInterval,
    required this.accuracyMeanMeters,
    required this.accuracyStdMeters,
    required this.includeJitter,
    required this.loopForever,
    required this.startAngleDeg,
    required this.variablePace,
    required this.simulateDropouts,
    required this.dropoutProbability,
    required this.paused,
    required this.showRawPoints,
    required this.showDisplayPoints,
    required this.showSampleRate,
    required this.showLastAccuracy,
    required this.showCumulativeDistance,
  });

  const FakeLocationConfig.defaults()
    : centerLat = -6.225014,
      centerLng = 106.827143,
      loopDistanceMeters = 5000,
      durationSeconds = 1800,
      sampleInterval = const Duration(seconds: 1),
      accuracyMeanMeters = 5,
      accuracyStdMeters = 1.5,
      includeJitter = true,
      loopForever = false,
      startAngleDeg = null,
      variablePace = true,
      simulateDropouts = false,
      dropoutProbability = 0.02,
      paused = false,
      showRawPoints = false,
      showDisplayPoints = true,
      showSampleRate = false,
      showLastAccuracy = false,
      showCumulativeDistance = false;

  FakeLocationConfig copyWith({
    double? centerLat,
    double? centerLng,
    double? loopDistanceMeters,
    int? durationSeconds,
    Duration? sampleInterval,
    double? accuracyMeanMeters,
    double? accuracyStdMeters,
    bool? includeJitter,
    bool? loopForever,
    double? startAngleDeg,
    bool? variablePace,
    bool? simulateDropouts,
    double? dropoutProbability,
    bool? paused,
    bool? showRawPoints,
    bool? showDisplayPoints,
    bool? showSampleRate,
    bool? showLastAccuracy,
    bool? showCumulativeDistance,
  }) {
    return FakeLocationConfig(
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      loopDistanceMeters: loopDistanceMeters ?? this.loopDistanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sampleInterval: sampleInterval ?? this.sampleInterval,
      accuracyMeanMeters: accuracyMeanMeters ?? this.accuracyMeanMeters,
      accuracyStdMeters: accuracyStdMeters ?? this.accuracyStdMeters,
      includeJitter: includeJitter ?? this.includeJitter,
      loopForever: loopForever ?? this.loopForever,
      startAngleDeg: startAngleDeg ?? this.startAngleDeg,
      variablePace: variablePace ?? this.variablePace,
      simulateDropouts: simulateDropouts ?? this.simulateDropouts,
      dropoutProbability: dropoutProbability ?? this.dropoutProbability,
      paused: paused ?? this.paused,
      showRawPoints: showRawPoints ?? this.showRawPoints,
      showDisplayPoints: showDisplayPoints ?? this.showDisplayPoints,
      showSampleRate: showSampleRate ?? this.showSampleRate,
      showLastAccuracy: showLastAccuracy ?? this.showLastAccuracy,
      showCumulativeDistance:
          showCumulativeDistance ?? this.showCumulativeDistance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centerLat': centerLat,
      'centerLng': centerLng,
      'loopDistanceMeters': loopDistanceMeters,
      'durationSeconds': durationSeconds,
      'sampleIntervalSeconds': sampleInterval.inSeconds,
      'accuracyMeanMeters': accuracyMeanMeters,
      'accuracyStdMeters': accuracyStdMeters,
      'includeJitter': includeJitter,
      'loopForever': loopForever,
      'startAngleDeg': startAngleDeg,
      'variablePace': variablePace,
      'simulateDropouts': simulateDropouts,
      'dropoutProbability': dropoutProbability,
      'paused': paused,
      'showRawPoints': showRawPoints,
      'showDisplayPoints': showDisplayPoints,
      'showSampleRate': showSampleRate,
      'showLastAccuracy': showLastAccuracy,
      'showCumulativeDistance': showCumulativeDistance,
    };
  }

  factory FakeLocationConfig.fromJson(Map<String, dynamic> json) {
    return FakeLocationConfig(
      centerLat: (json['centerLat'] as num?)?.toDouble() ?? -6.225014,
      centerLng: (json['centerLng'] as num?)?.toDouble() ?? 106.827143,
      loopDistanceMeters:
          (json['loopDistanceMeters'] as num?)?.toDouble() ?? 5000,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 1800,
      sampleInterval: Duration(
        seconds: (json['sampleIntervalSeconds'] as num?)?.toInt() ?? 1,
      ),
      accuracyMeanMeters: (json['accuracyMeanMeters'] as num?)?.toDouble() ?? 5,
      accuracyStdMeters: (json['accuracyStdMeters'] as num?)?.toDouble() ?? 1.5,
      includeJitter: json['includeJitter'] as bool? ?? true,
      loopForever: json['loopForever'] as bool? ?? false,
      startAngleDeg: (json['startAngleDeg'] as num?)?.toDouble(),
      variablePace: json['variablePace'] as bool? ?? true,
      simulateDropouts: json['simulateDropouts'] as bool? ?? false,
      dropoutProbability:
          (json['dropoutProbability'] as num?)?.toDouble() ?? 0.02,
      paused: json['paused'] as bool? ?? false,
      showRawPoints: json['showRawPoints'] as bool? ?? false,
      showDisplayPoints: json['showDisplayPoints'] as bool? ?? true,
      showSampleRate: json['showSampleRate'] as bool? ?? false,
      showLastAccuracy: json['showLastAccuracy'] as bool? ?? false,
      showCumulativeDistance: json['showCumulativeDistance'] as bool? ?? false,
    );
  }

  String get debugLabel {
    return 'center=($centerLat,$centerLng) loop=${loopDistanceMeters.toStringAsFixed(0)}m '
        'duration=${durationSeconds}s interval=${sampleInterval.inSeconds}s';
  }
}

class FakeLocationService implements TrackingSource {
  FakeLocationService({required FakeLocationConfig config, Random? random})
    : _config = config,
      _random = random ?? Random();

  final Random _random;
  FakeLocationConfig _config;

  StreamController<PositionSample>? _controller;
  Timer? _timer;
  bool _isStarted = false;
  bool _isPaused = false;
  int _emittedSamples = 0;
  double _angleRad = 0;

  FakeLocationConfig get config => _config;

  set config(FakeLocationConfig value) {
    _config = value;
  }

  @override
  Future<bool> requestPermission() async => true;

  Stream<PositionSample> start() {
    if (_isStarted && _controller != null) {
      return _controller!.stream;
    }

    _controller = StreamController<PositionSample>.broadcast(
      onCancel: () {
        if (_controller?.hasListener == false) {
          stop();
        }
      },
    );
    _isStarted = true;
    _isPaused = _config.paused;
    _emittedSamples = 0;
    _angleRad = ((_config.startAngleDeg ?? 0) * pi) / 180.0;

    if (kDebugMode) {
      debugPrint('FAKE_LOCATION_ACTIVE ${_config.debugLabel}');
    }

    _timer = Timer.periodic(_config.sampleInterval, (_) => _emitNextSample());
    return _controller!.stream;
  }

  @override
  Stream<PositionSample> watchPosition() => start();

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_controller != null && !_controller!.isClosed) {
      _controller!.close();
    }
    _controller = null;
    _isStarted = false;
    _isPaused = false;
    _emittedSamples = 0;
  }

  void _emitNextSample() {
    final controller = _controller;
    if (controller == null || controller.isClosed) {
      stop();
      return;
    }

    if (_isPaused) {
      return;
    }

    final maxSamples = max(
      1,
      (_config.durationSeconds / _config.sampleInterval.inSeconds).round(),
    );
    if (!_config.loopForever && _emittedSamples >= maxSamples) {
      stop();
      return;
    }

    if (_config.simulateDropouts &&
        _random.nextDouble() < _config.dropoutProbability) {
      _emittedSamples += 1;
      return;
    }

    final baseSpeed = _config.loopDistanceMeters / _config.durationSeconds;
    final paceFactor = _config.variablePace
        ? 1.0 +
              0.16 * sin(_emittedSamples / 11.0) +
              0.08 * sin(_emittedSamples / 4.5)
        : 1.0;
    final speedMps = max(0.4, baseSpeed * paceFactor);
    final intervalSeconds = _config.sampleInterval.inMilliseconds / 1000.0;
    final stepMeters = speedMps * intervalSeconds;
    final radiusMeters = max(1.0, _config.loopDistanceMeters / (2 * pi));
    _angleRad = (_angleRad + stepMeters / radiusMeters) % (2 * pi);

    final xMeters = radiusMeters * cos(_angleRad);
    final yMeters = radiusMeters * sin(_angleRad);

    final jitterX = _config.includeJitter ? _gaussian(_random, 0, 1.2) : 0.0;
    final jitterY = _config.includeJitter ? _gaussian(_random, 0, 1.2) : 0.0;

    final lat = _config.centerLat + _metersToLat(yMeters + jitterY);
    final lng =
        _config.centerLng + _metersToLng(xMeters + jitterX, _config.centerLat);
    final accuracy = max(
      1.0,
      _gaussian(_random, _config.accuracyMeanMeters, _config.accuracyStdMeters),
    );
    final bearing = (_angleRad * 180 / pi + 90) % 360;

    controller.add(
      PositionSample(
        ts: DateTime.now(),
        lat: lat,
        lng: lng,
        accuracyMeters: accuracy,
        speedMps: speedMps,
        bearingDeg: bearing,
      ),
    );
    _emittedSamples += 1;
  }

  double _metersToLat(double meters) => meters / 111320.0;

  double _metersToLng(double meters, double lat) {
    final scale = 111320.0 * cos(lat * pi / 180.0);
    return scale == 0 ? 0 : meters / scale;
  }

  double _gaussian(Random random, double mean, double stdDev) {
    final u1 = max(1e-10, random.nextDouble());
    final u2 = max(1e-10, random.nextDouble());
    final mag = sqrt(-2.0 * log(u1));
    final z0 = mag * cos(2.0 * pi * u2);
    return mean + stdDev * z0;
  }
}
