import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/presence_provider.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPublicPresenceEnabled = ref.watch(presenceOptInProvider);
    final presenceLines = ref.watch(presenceLinesProvider);

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'SOCIAL GRID',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.neonCyan,
                      shadows: [
                        Shadow(
                          color: AppTheme.neonCyan.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Public presence and local party preview.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    context,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRESENCE',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isPublicPresenceEnabled ? 'VISIBLE' : 'HIDDEN',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: isPublicPresenceEnabled
                                          ? Colors.greenAccent
                                          : Colors.white54,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPublicPresenceEnabled
                                    ? 'Your coarse presence is being published to Supabase.'
                                    : 'Turn on public presence to sync a coarse line to Supabase.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Switch(
                          value: isPublicPresenceEnabled,
                          onChanged: (_) =>
                              ref.read(presenceOptInProvider.notifier).toggle(),
                          activeColor: AppTheme.neonCyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.radar,
                                  color: AppTheme.neonCyan,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PRESENCE PREVIEW',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                            _buildStatusChip(
                              context,
                              '${presenceLines.length} LINES',
                              presenceLines.isEmpty
                                  ? Colors.white54
                                  : AppTheme.secondary,
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                        if (!isPublicPresenceEnabled)
                          const Text(
                            'Enable presence to see public previews here.',
                            style: TextStyle(color: Colors.white54),
                          )
                        else if (presenceLines.isEmpty)
                          const Text(
                            'No public presence detected yet.',
                            style: TextStyle(color: Colors.white54),
                          )
                        else
                          Column(
                            children: [
                              for (final line in presenceLines)
                                _buildPresenceCard(
                                  context,
                                  userId: line.userId,
                                  routePoints: line.route.length,
                                  color: AppTheme.neonCyan,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PARTY PREVIEW',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                        const Text(
                          'Party join/create flows are still pending backend wiring. This screen now focuses on presence and social sync state.',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: null,
                                child: const Text('CREATE PARTY'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white54,
                                  side: const BorderSide(color: Colors.white24),
                                ),
                                child: const Text('JOIN BY CODE'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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

  Widget _buildPresenceCard(
    BuildContext context, {
    required String userId,
    required int routePoints,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(Icons.person, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userId,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$routePoints route points shared',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildStatusChip(context, 'LIVE', color),
          ],
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
