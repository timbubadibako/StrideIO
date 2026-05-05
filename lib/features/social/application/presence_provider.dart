import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../dev/dev_providers.dart';
import 'package:latlong2/latlong.dart';

const String kPresenceOptInKey = 'social.presenceOptIn';

class PresenceOptInNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool(kPresenceOptInKey) ??
        false;
  }

  Future<void> toggle() async {
    final newValue = !state;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(kPresenceOptInKey, newValue);
    await _syncToSupabase(newValue);
    state = newValue;
  }

  Future<void> _syncToSupabase(bool publicEnabled) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profileResponse = await supabase
          .from('user_profiles')
          .select('ghost_mode')
          .eq('user_id', user.id)
          .maybeSingle();

      await supabase.from('presence').upsert({
        'user_id': user.id,
        'public_enabled': publicEnabled,
        'ghost_mode': profileResponse?['ghost_mode'] as bool? ?? false,
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Keep local preference even if Supabase sync fails.
    }
  }
}

final presenceOptInProvider = NotifierProvider<PresenceOptInNotifier, bool>(
  PresenceOptInNotifier.new,
);

class PresenceData {
  final String userId;
  final List<LatLng> route;

  PresenceData({required this.userId, required this.route});
}

class PresenceLinesNotifier extends Notifier<List<PresenceData>> {
  @override
  List<PresenceData> build() {
    final optedIn = ref.watch(presenceOptInProvider);
    if (!optedIn) return [];

    // Mock data for other users' presence lines
    return [
      PresenceData(
        userId: 'user_123',
        route: [
          const LatLng(-6.224014, 106.826143),
          const LatLng(-6.223014, 106.827143),
          const LatLng(-6.222014, 106.828143),
        ],
      ),
      PresenceData(
        userId: 'user_456',
        route: [
          const LatLng(-6.226014, 106.825143),
          const LatLng(-6.227014, 106.824143),
        ],
      ),
    ];
  }
}

final presenceLinesProvider =
    NotifierProvider<PresenceLinesNotifier, List<PresenceData>>(
      PresenceLinesNotifier.new,
    );
