import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../social/application/presence_provider.dart';

class TopTelemetryBar extends ConsumerWidget {
  const TopTelemetryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPresenceOn = ref.watch(presenceOptInProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Bar Scrim - Solid black (fully closes map)
        Container(
          color: AppTheme.deepDark,
          height: MediaQuery.of(context).padding.top,
        ),

        // TopAppBar - Header (no extra padding, status bar scrim handles top)
        SafeArea(
          bottom: false,
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.32),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.neonCyan.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.location_on,
                          color: AppTheme.neonCyan,
                        ),
                        onPressed: () {},
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      Text(
                        'STRIDEIO',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.neonCyan,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isPresenceOn ? Icons.visibility : Icons.visibility_off,
                              color: isPresenceOn ? AppTheme.neonCyan : Colors.white54,
                            ),
                            tooltip: 'Toggle Presence',
                            onPressed: () {
                              ref.read(presenceOptInProvider.notifier).toggle();
                            },
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.leaderboard,
                              color: AppTheme.neonCyan,
                            ),
                            onPressed: () {},
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Telemetry Panel - Compact 3-row HUD layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.18),
                  const Color(0xFF1F1F23).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ROW 1: Region + GPS Status Badge
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppTheme.neonCyan, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'KUNINGAN, W-JAVA',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonCyan.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.neonCyan.withOpacity(0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync,
                            size: 9,
                            color: AppTheme.neonCyan,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'SYNC: JUST NOW',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 7,
                                  color: AppTheme.neonCyan,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.15,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonCyan.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.neonCyan.withOpacity(0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 9,
                            color: AppTheme.neonCyan,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'GPS LOCKED',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 7,
                                  color: AppTheme.neonCyan,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.15,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ROW 2: Level + XP Progress Bar + XP Label
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Level display
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LVL',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontSize: 8,
                                color: Colors.white60,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '42',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontSize: 18,
                                color: AppTheme.neonCyan,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // XP Progress Bar (left-to-right fill)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2.5),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 0.5,
                              ),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.68,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.neonCyan,
                                  borderRadius: BorderRadius.circular(2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.neonCyan.withOpacity(0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '34K / 50K XP',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 8,
                                  color: Colors.white70,
                                  letterSpacing: 0.15,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ROW 3: Zone Control (Faction Territory)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZONE CONTROL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 7,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Your faction segment (cyan)
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.neonCyan,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  bottomLeft: Radius.circular(3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.neonCyan.withOpacity(0.3),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Neutral segment (gray)
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          // Rival segment (secondary color)
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.4),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
