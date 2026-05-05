import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final String? factionId;
  final int level;
  final int xp;
  final String? bio;
  final bool publicProfile;
  final bool ghostMode;
  final bool isFallback;

  UserProfile({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.factionId,
    this.level = 1,
    this.xp = 0,
    this.bio,
    this.publicProfile = false,
    this.ghostMode = false,
    this.isFallback = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      factionId: json['faction_id']?.toString(),
      level: _asInt(json['level'], 1),
      xp: _asInt(json['xp'], 0),
      bio: json['bio']?.toString(),
      publicProfile: json['public_profile'] as bool? ?? false,
      ghostMode: json['ghost_mode'] as bool? ?? false,
      isFallback: false,
    );
  }

  factory UserProfile.fromAuthUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email?.trim();
    final fallbackName = _firstNonEmpty([
      metadata['display_name']?.toString(),
      metadata['username']?.toString(),
      email != null && email.contains('@') ? email.split('@').first : null,
      'Agent',
    ]);

    return UserProfile(
      userId: user.id,
      displayName: fallbackName,
      avatarUrl: metadata['avatar_url']?.toString(),
      factionId: metadata['faction_id']?.toString(),
      level: _asInt(metadata['level'], 1),
      xp: _asInt(metadata['xp'], 0),
      bio: _firstNonEmpty([
        metadata['bio']?.toString(),
        email != null ? 'Supabase user: $email' : 'Supabase user',
      ]),
      publicProfile: metadata['public_profile'] as bool? ?? false,
      ghostMode: metadata['ghost_mode'] as bool? ?? false,
      isFallback: true,
    );
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  UserProfile copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? factionId,
    int? level,
    int? xp,
    String? bio,
    bool? publicProfile,
    bool? ghostMode,
    bool? isFallback,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      factionId: factionId ?? this.factionId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      bio: bio ?? this.bio,
      publicProfile: publicProfile ?? this.publicProfile,
      ghostMode: ghostMode ?? this.ghostMode,
      isFallback: isFallback ?? this.isFallback,
    );
  }

  String get displayNameOrFallback {
    final value = displayName?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return 'Agent';
  }

  String get bioOrPlaceholder {
    final value = bio?.trim();
    return (value != null && value.isNotEmpty) ? value : 'Bio belum diisi';
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'faction_id': factionId,
      'level': level,
      'xp': xp,
      'bio': bio,
      'public_profile': publicProfile,
      'ghost_mode': ghostMode,
    };
  }
}
