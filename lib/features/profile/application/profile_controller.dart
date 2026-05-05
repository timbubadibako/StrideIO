import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/domain/models/user_profile.dart';
import '../../../core/services/supabase_logger.dart';
import '../../../dev/dev_providers.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(() {
      return ProfileController();
    });

class ProfileController extends AsyncNotifier<UserProfile?> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool get _logEnabled => ref.read(supabaseDevLogEnabledProvider);

  @override
  Future<UserProfile?> build() async {
    return _fetchProfile();
  }

  Future<UserProfile?> _fetchProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        SupabaseLogger.log(_logEnabled, 'Fetch Profile');
        return UserProfile.fromJson(response);
      } else {
        SupabaseLogger.log(_logEnabled, 'Profile Not Found, Creating Default');
        return await _createDefaultProfile(user);
      }
    } catch (e) {
      SupabaseLogger.log(
        _logEnabled,
        'Fetch Profile',
        success: false,
        error: e.toString(),
      );
      return UserProfile.fromAuthUser(user);
    }
  }

  Future<UserProfile?> _createDefaultProfile(User user) async {
    try {
      final defaultName =
          user.userMetadata?['display_name']?.toString().trim().isNotEmpty ==
              true
          ? user.userMetadata!['display_name'].toString().trim()
          : 'Dummy ${user.id.substring(0, 4)}';

      final newProfile = {
        'user_id': user.id,
        'display_name': defaultName,
        'level': 1,
        'xp': 0,
        'bio': user.userMetadata?['bio']?.toString(),
        'avatar_url': user.userMetadata?['avatar_url']?.toString(),
      };

      final response = await _supabase
          .from('user_profiles')
          .upsert(newProfile, onConflict: 'user_id')
          .select()
          .single();
      SupabaseLogger.log(_logEnabled, 'Create Default Profile');
      return UserProfile.fromJson(response);
    } catch (e) {
      SupabaseLogger.log(
        _logEnabled,
        'Create Default Profile',
        success: false,
        error: e.toString(),
      );
      return UserProfile.fromAuthUser(user);
    }
  }

  Future<void> updateDisplayName(String newName) async {
    await updateProfile(displayName: newName);
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? publicProfile,
    bool? ghostMode,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final currentProfile = state.value;
      final baseProfile = currentProfile ?? UserProfile.fromAuthUser(user);
      final updatedProfile = baseProfile.copyWith(
        displayName: displayName ?? baseProfile.displayName,
        bio: bio ?? baseProfile.bio,
        avatarUrl: avatarUrl ?? baseProfile.avatarUrl,
        publicProfile: publicProfile ?? baseProfile.publicProfile,
        ghostMode: ghostMode ?? baseProfile.ghostMode,
      );

      final payload = <String, dynamic>{
        'user_id': user.id,
        'display_name': updatedProfile.displayName,
        'bio': updatedProfile.bio,
        'avatar_url': updatedProfile.avatarUrl,
        'public_profile': updatedProfile.publicProfile,
        'ghost_mode': updatedProfile.ghostMode,
      };

      final response = await _supabase
          .from('user_profiles')
          .upsert(payload, onConflict: 'user_id')
          .select()
          .single();

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': updatedProfile.displayName,
            'bio': updatedProfile.bio,
            'avatar_url': updatedProfile.avatarUrl,
          },
        ),
      );

      SupabaseLogger.log(_logEnabled, 'Update Profile');
      state = AsyncData(UserProfile.fromJson(response));
    } catch (e) {
      SupabaseLogger.log(
        _logEnabled,
        'Update Profile',
        success: false,
        error: e.toString(),
      );

      final user = _supabase.auth.currentUser;
      if (user != null) {
        final currentProfile = state.value;
        final fallbackProfile =
            (currentProfile ?? UserProfile.fromAuthUser(user)).copyWith(
              displayName: displayName ?? currentProfile?.displayName,
              bio: bio ?? currentProfile?.bio,
              avatarUrl: avatarUrl ?? currentProfile?.avatarUrl,
              publicProfile: publicProfile ?? currentProfile?.publicProfile,
              ghostMode: ghostMode ?? currentProfile?.ghostMode,
              isFallback: true,
            );
        state = AsyncData(fallbackProfile);
      }
    }
  }
}
