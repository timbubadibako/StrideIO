import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/stride_map_view.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/top_telemetry_bar.dart';
import '../../application/scanning_state_provider.dart';
import '../../application/location_permission_provider.dart';

class MapDashboardScreen extends ConsumerStatefulWidget {
  const MapDashboardScreen({super.key});

  @override
  ConsumerState<MapDashboardScreen> createState() => _MapDashboardScreenState();
}

class _MapDashboardScreenState extends ConsumerState<MapDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // LAYER 0: Map Background
          const Positioned.fill(child: StrideMapView()),

          // LAYER 0.5: Depth Effects (Vignette + Overlays)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  // Radial vignette (corners darkened)
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.35),
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Top gradient overlay
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Bottom gradient overlay
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LAYER 1: Top Shell (TopAppBar & Telemetry) - Edge-to-edge
          Positioned(top: 0, left: 0, right: 0, child: const TopTelemetryBar()),

          // LAYER 2: Central User Icon (Conqueror) - Scanning Widget
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _HexagonOverlayPainter(
                          color: AppTheme.neonCyan.withOpacity(0.1),
                        ),
                      ),
                    ),
                    _ScanningIndicator(),
                  ],
                ),
                const SizedBox(height: 8),
                _ScanningLabel(),
              ],
            ),
          ),

          // LAYER 3: Permissions CTA
          const _PermissionCtaOverlay(),
        ],
      ),
    );
  }
}

class _HexagonOverlayPainter extends CustomPainter {
  final Color color;

  _HexagonOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final double strokeWidth = 1.2;
    final radius = min(size.width, size.height) / 2 - strokeWidth;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Scanning indicator with state-based animation
class _ScanningIndicator extends ConsumerStatefulWidget {
  const _ScanningIndicator();

  @override
  ConsumerState<_ScanningIndicator> createState() => _ScanningIndicatorState();
}

class _ScanningIndicatorState extends ConsumerState<_ScanningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanningStateProvider);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring (animation depends on state)
            if (scanState.isAnimating)
              Container(
                width: 82 + (82 * _animationController.value * 0.6),
                height: 82 + (82 * _animationController.value * 0.6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonCyan.withOpacity(
                      0.5 * (1.0 - _animationController.value),
                    ),
                    width: 1.6,
                  ),
                ),
              ),
            // Static border ring (when locked)
            if (!scanState.isAnimating)
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonCyan.withOpacity(0.36),
                    width: 1.6,
                  ),
                ),
              ),
            // Core circle with fire icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.96),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.neonCyan, width: 1.2),
                boxShadow: [
                  // Strong glow only for primary scanning core
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(0.7),
                    blurRadius: 18,
                  ),
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(0.2),
                    blurRadius: 6,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: AppTheme.neonCyan,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Scanning label with state-based microcopy
class _ScanningLabel extends ConsumerWidget {
  const _ScanningLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanningStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHighlight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.neonCyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonCyan.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            scanState.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Permission CTA overlay
class _PermissionCtaOverlay extends ConsumerWidget {
  const _PermissionCtaOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionProvider);

    if (permissionState == null || permissionState == true) {
      return const SizedBox.shrink(); // Hide if loading or granted
    }

    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceHighlight.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.error.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.2),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off, color: AppTheme.error),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPS Signal Lost',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enable location to track your run and claim sectors.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(locationPermissionProvider.notifier).requestPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('ENABLE'),
            ),
          ],
        ),
      ),
    );
  }
}
