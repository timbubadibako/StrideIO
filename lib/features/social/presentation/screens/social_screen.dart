import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Cyber Grid Background
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
                    'PARTY HUB',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.neonCyan,
                      shadows: [
                        Shadow(color: AppTheme.neonCyan.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with nearby operatives and dominate the grid.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Sync Code Card
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        Text('SYNC CODE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),
                        Container(
                          width: 150,
                          height: 150,
                          color: Colors.white, // Dummy QR
                          child: const Icon(Icons.qr_code_2, size: 100, color: Colors.black),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('SCAN TO JOIN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Local Lobby
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
                                const Icon(Icons.radar, color: AppTheme.neonCyan),
                                const SizedBox(width: 8),
                                Text('LOCAL LOBBY', style: Theme.of(context).textTheme.labelLarge),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.neonCyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '3 ONLINE',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: AppTheme.neonCyan),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                        _buildLobbyUser(context, 'Valkyrie_99', 'Level 42 • Vector', Colors.blue),
                        const SizedBox(height: 8),
                        _buildLobbyUser(context, 'Kael_Striker', 'Level 38 • Crimson', AppTheme.error),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Faction Leaderboard
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: AppTheme.secondary),
                            const SizedBox(width: 8),
                            Text('FACTION RANKS', style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: _buildRankItem(context, 'Neon_Ghost', '12,450', 1, AppTheme.neonCyan)),
                            Expanded(child: _buildRankItem(context, 'Xeno_Blaze', '11,200', 2, AppTheme.error)),
                            Expanded(child: _buildRankItem(context, 'Aura_Volt', '10,850', 3, AppTheme.secondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // padding for bottom nav
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
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLobbyUser(BuildContext context, String name, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.surfaceHighlight,
            child: Icon(Icons.person, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.neonCyan,
              side: const BorderSide(color: AppTheme.neonCyan),
            ),
            child: const Text('JOIN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(BuildContext context, String name, String score, int rank, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topLeft,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.surface,
              child: Icon(Icons.person, color: color, size: 28),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight,
                shape: BoxShape.circle,
                border: Border.all(color: color),
              ),
              child: Text('#$rank', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
        Text('$score PTS', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
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
