import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/models/user_profile.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../dev/dev_providers.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../application/integration_connections_provider.dart';
import '../../application/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final displayNameController = TextEditingController(
      text: profile.displayName ?? '',
    );
    final bioController = TextEditingController(text: profile.bio ?? '');
    final avatarController = TextEditingController(
      text: profile.avatarUrl ?? '',
    );
    var publicProfile = profile.publicProfile;
    var ghostMode = profile.ghostMode;

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceHighlight,
              title: const Text(
                'EDIT PROFILE',
                style: TextStyle(color: AppTheme.neonCyan),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: displayNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.neonCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.neonCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: avatarController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.neonCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: publicProfile,
                      onChanged: (value) => setDialogState(() {
                        publicProfile = value;
                      }),
                      title: const Text(
                        'Public profile',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Visible to other users',
                        style: TextStyle(color: Colors.white54),
                      ),
                      activeColor: AppTheme.neonCyan,
                    ),
                    SwitchListTile.adaptive(
                      value: ghostMode,
                      onChanged: (value) => setDialogState(() {
                        ghostMode = value;
                      }),
                      title: const Text(
                        'Ghost mode',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Hide live activity markers',
                        style: TextStyle(color: Colors.white54),
                      ),
                      activeColor: AppTheme.secondary,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(color: AppTheme.deepDark),
                  ),
                ),
              ],
            );
          },
        ),
      );

      if (shouldSave != true) {
        return;
      }

      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            displayName: displayNameController.text.trim().isEmpty
                ? profile.displayNameOrFallback
                : displayNameController.text.trim(),
            bio: bioController.text.trim().isEmpty
                ? null
                : bioController.text.trim(),
            avatarUrl: avatarController.text.trim().isEmpty
                ? null
                : avatarController.text.trim(),
            publicProfile: publicProfile,
            ghostMode: ghostMode,
          );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated from Supabase.'),
          backgroundColor: AppTheme.neonCyan,
        ),
      );
    } finally {
      displayNameController.dispose();
      bioController.dispose();
      avatarController.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMenuVisible = ref.watch(devMenuVisibleProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final integrationStates = ref.watch(integrationConnectionsProvider);
    final authUser = ref.read(authControllerProvider).currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: CyberGridPainter()),
            ),
          ),
          SafeArea(
            child: profileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.neonCyan),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
              data: (profile) {
                final effectiveProfile =
                    profile ??
                    (authUser != null
                        ? UserProfile.fromAuthUser(authUser)
                        : null);

                if (effectiveProfile == null) {
                  return Center(
                    child: Text(
                      'Silakan login dulu untuk melihat profile.',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildGlassCard(
                        context,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.neonCyan,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: AppTheme.surfaceHighlight,
                                backgroundImage:
                                    _isNetworkImage(effectiveProfile.avatarUrl)
                                    ? NetworkImage(
                                        effectiveProfile.avatarUrl!.trim(),
                                      )
                                    : null,
                                child:
                                    !_isNetworkImage(effectiveProfile.avatarUrl)
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              effectiveProfile.displayNameOrFallback
                                  .toUpperCase(),
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(color: Colors.white, fontSize: 32),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              effectiveProfile.bioOrPlaceholder.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(letterSpacing: 2),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildStatusChip(
                                  context,
                                  effectiveProfile.publicProfile
                                      ? 'PUBLIC'
                                      : 'PRIVATE',
                                  effectiveProfile.publicProfile
                                      ? AppTheme.secondary
                                      : Colors.white54,
                                ),
                                _buildStatusChip(
                                  context,
                                  effectiveProfile.ghostMode ? 'GHOST' : 'LIVE',
                                  effectiveProfile.ghostMode
                                      ? AppTheme.error
                                      : AppTheme.neonCyan,
                                ),
                                _buildStatusChip(
                                  context,
                                  effectiveProfile.isFallback
                                      ? 'LOCAL'
                                      : 'SYNCED',
                                  effectiveProfile.isFallback
                                      ? Colors.orangeAccent
                                      : AppTheme.secondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _showEditProfileDialog(
                                      context,
                                      ref,
                                      effectiveProfile,
                                    ),
                                    child: const Text('EDIT PROFILE'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await ref
                                          .read(authControllerProvider)
                                          .signOut();
                                      if (!context.mounted) return;
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.error,
                                      side: const BorderSide(
                                        color: AppTheme.error,
                                      ),
                                    ),
                                    child: const Text('SIGN OUT'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ACCOUNT STATUS',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppTheme.neonCyan,
                                        fontSize: 16,
                                      ),
                                ),
                                _buildStatusChip(
                                  context,
                                  effectiveProfile.isFallback
                                      ? 'LOCAL'
                                      : 'SYNCED',
                                  effectiveProfile.isFallback
                                      ? Colors.orangeAccent
                                      : AppTheme.secondary,
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildServiceIcon(
                                  context,
                                  Icons.monitor_heart,
                                  'Health',
                                  integrationStates['health'] ?? false,
                                  Colors.green,
                                ),
                                _buildServiceIcon(
                                  context,
                                  Icons.directions_bike,
                                  'Strava',
                                  integrationStates['strava'] ?? false,
                                  const Color(0xFFFC4C02),
                                ),
                                _buildServiceIcon(
                                  context,
                                  Icons.watch,
                                  'Garmin',
                                  integrationStates['garmin'] ?? false,
                                  const Color(0xFF007CC3),
                                ),
                                _buildServiceIcon(
                                  context,
                                  Icons.link,
                                  'Other',
                                  integrationStates['other'] ?? false,
                                  Colors.purpleAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'Indicators show which connectors are enabled. Manage them later in settings or connector screens.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white54),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'DANGER ZONE',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppTheme.error,
                                        fontSize: 16,
                                      ),
                                ),
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppTheme.error,
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10),
                            _buildDangerAction(
                              context,
                              icon: Icons.lock_reset,
                              title: 'Reset password',
                              subtitle: 'Send a recovery link to your email.',
                              color: AppTheme.neonCyan,
                              onPressed: () async {
                                final email = authUser?.email;
                                if (email == null || email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No email available for password reset.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                await ref
                                    .read(authControllerProvider)
                                    .resetPasswordForEmail(email);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset link sent.'),
                                    backgroundColor: AppTheme.neonCyan,
                                  ),
                                );
                              },
                            ),
                            _buildDangerAction(
                              context,
                              icon: Icons.logout,
                              title: 'Logout',
                              subtitle: 'End this session on this device.',
                              color: AppTheme.error,
                              onPressed: () async {
                                await ref
                                    .read(authControllerProvider)
                                    .signOut();
                                if (!context.mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                            _buildDangerAction(
                              context,
                              icon: Icons.delete_forever,
                              title: 'Delete account',
                              subtitle:
                                  'Requires backend auth admin flow. Disabled for now.',
                              color: Colors.white38,
                              onPressed: null,
                            ),
                          ],
                        ),
                      ),
                      if (devMenuVisible) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onLongPress: () =>
                              Navigator.pushNamed(context, '/dev'),
                          child: Center(
                            child: Text(
                              'v1.0.0',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white38,
                                    letterSpacing: 1.4,
                                  ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isNetworkImage(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(text);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHighlight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceIcon(
    BuildContext context,
    IconData icon,
    String label,
    bool isConnected,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isConnected ? Colors.greenAccent : Colors.white24,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.background, width: 1.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildDangerAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: onPressed == null
                              ? Colors.white54
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  onPressed == null ? Icons.lock_outline : Icons.chevron_right,
                  color: Colors.white30,
                ),
              ],
            ),
          ),
        ),
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
