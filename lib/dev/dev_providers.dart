import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/domain/models/position_sample.dart';
import '../core/domain/repositories/tracking_source.dart';
import '../core/services/location_service.dart';
import 'fake_location_service.dart';

enum AppMode { dev, prod }

const String kUseFakeLocationPrefKey = 'dev.useFakeLocation';
const String kFakeLocationConfigPrefKey = 'dev.fakeLocationConfig';

const bool kAllowDevMenuInRelease = bool.fromEnvironment(
  'STRIDEIO_ALLOW_DEV_MENU',
  defaultValue: false,
);
const bool kAllowFakeGpsInRelease = bool.fromEnvironment(
  'STRIDEIO_ALLOW_FAKE_GPS',
  defaultValue: false,
);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final appModeProvider = Provider<AppMode>((ref) {
  if (kReleaseMode && !kAllowDevMenuInRelease && !kAllowFakeGpsInRelease) {
    return AppMode.prod;
  }

  if (kDebugMode || kAllowDevMenuInRelease || kAllowFakeGpsInRelease) {
    return AppMode.dev;
  }

  return AppMode.prod;
});

final devMenuVisibleProvider = Provider<bool>((ref) {
  return ref.watch(appModeProvider) == AppMode.dev;
});

class SupabaseDevLogEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool value) => state = value;
}

final supabaseDevLogEnabledProvider = NotifierProvider<SupabaseDevLogEnabledNotifier, bool>(() {
  return SupabaseDevLogEnabledNotifier();
});

class UseFakeLocationPrefNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref
            .read(sharedPreferencesProvider)
            .getBool(kUseFakeLocationPrefKey) ??
        false;
  }

  Future<void> setEnabled(bool enabled) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(kUseFakeLocationPrefKey, enabled);
    state = enabled;
  }
}

final useFakeLocationPrefProvider =
    NotifierProvider<UseFakeLocationPrefNotifier, bool>(
      UseFakeLocationPrefNotifier.new,
    );

class DevFakeLocationConfigNotifier extends Notifier<FakeLocationConfig> {
  @override
  FakeLocationConfig build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(kFakeLocationConfigPrefKey);
    if (raw == null || raw.isEmpty) {
      return const FakeLocationConfig.defaults();
    }

    try {
      return FakeLocationConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const FakeLocationConfig.defaults();
    }
  }

  Future<void> update(FakeLocationConfig config) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(kFakeLocationConfigPrefKey, jsonEncode(config.toJson()));
    state = config;
  }

  Future<void> applyPreset(FakeLocationConfig config) async {
    await update(config);
  }

  Future<void> setField({
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
    bool? showRawPoints,
    bool? showDisplayPoints,
    bool? showSampleRate,
    bool? showLastAccuracy,
    bool? showCumulativeDistance,
  }) async {
    await update(
      state.copyWith(
        centerLat: centerLat,
        centerLng: centerLng,
        loopDistanceMeters: loopDistanceMeters,
        durationSeconds: durationSeconds,
        sampleInterval: sampleInterval,
        accuracyMeanMeters: accuracyMeanMeters,
        accuracyStdMeters: accuracyStdMeters,
        includeJitter: includeJitter,
        loopForever: loopForever,
        startAngleDeg: startAngleDeg,
        variablePace: variablePace,
        simulateDropouts: simulateDropouts,
        dropoutProbability: dropoutProbability,
        showRawPoints: showRawPoints,
        showDisplayPoints: showDisplayPoints,
        showSampleRate: showSampleRate,
        showLastAccuracy: showLastAccuracy,
        showCumulativeDistance: showCumulativeDistance,
      ),
    );
  }
}

final devFakeLocationConfigProvider =
    NotifierProvider<DevFakeLocationConfigNotifier, FakeLocationConfig>(
      DevFakeLocationConfigNotifier.new,
    );

final fakeLocationActiveProvider = Provider<bool>((ref) {
  return ref.watch(appModeProvider) == AppMode.dev &&
      ref.watch(useFakeLocationPrefProvider);
});

final trackingSourceProvider = Provider<TrackingSource>((ref) {
  final appMode = ref.watch(appModeProvider);
  final useFake = ref.watch(useFakeLocationPrefProvider);

  if (appMode == AppMode.dev && useFake) {
    final fake = FakeLocationService(
      config: ref.watch(devFakeLocationConfigProvider),
    );
    ref.onDispose(fake.stop);
    return fake;
  }

  return LocationService();
});

final locationStreamProvider = StreamProvider.autoDispose<PositionSample>((
  ref,
) {
  return ref.watch(trackingSourceProvider).watchPosition();
});
