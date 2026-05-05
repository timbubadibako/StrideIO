import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/state/ui_load_state.dart';
import '../../../../ui/state/ui_demo_state_providers.dart';
import '../../../map/presentation/widgets/stride_map_view.dart';
import '../../application/workout_controller.dart';
import '../../../social/presentation/screens/social_share_overlay.dart';
import '../../../social/presentation/widgets/static_carto_map.dart';
import '../../../social/presentation/widgets/route_line_painter.dart';
import 'dart:math' as math;

class PostRunSummaryScreen extends ConsumerWidget {
  const PostRunSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(postRunUiStateProvider);
    final workout = ref.read(workoutControllerProvider);
    final isLoading = uiState == UiLoadState.loading;

    // Formatting
    final distKm = (workout.distanceMeters / 1000).toStringAsFixed(2);
    final minutes = (workout.durationSeconds / 60).floor();
    final seconds = workout.durationSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final paceStr = workout.avgPaceSecondsPerKm != null
        ? '${(workout.avgPaceSecondsPerKm! / 60).floor().toString().padLeft(2, '0')}:${(workout.avgPaceSecondsPerKm! % 60).floor().toString().padLeft(2, '0')}'
        : '--:--';
    final heroCameraLat = workout.points.isNotEmpty
        ? workout.points.last.lat
        : -6.225014;
    final heroCameraLng = workout.points.isNotEmpty
        ? workout.points.last.lng
        : 106.827143;

    // Calculate Bounding Box and padded dimensions for map
    double minLat = heroCameraLat;
    double maxLat = heroCameraLat;
    double minLng = heroCameraLng;
    double maxLng = heroCameraLng;
    if (workout.points.isNotEmpty) {
      minLat = workout.points.first.lat;
      maxLat = workout.points.first.lat;
      minLng = workout.points.first.lng;
      maxLng = workout.points.first.lng;
      for (var p in workout.points) {
        if (p.lat < minLat) minLat = p.lat;
        if (p.lat > maxLat) maxLat = p.lat;
        if (p.lng < minLng) minLng = p.lng;
        if (p.lng > maxLng) maxLng = p.lng;
      }
    }
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    int zoom = 15;
    double _lng2pixel(double lon, int z) => ((lon + 180.0) / 360.0 * math.pow(2, z) * 256.0);
    double _lat2pixel(double lat, int z) {
      final latRad = lat * math.pi / 180.0;
      return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * math.pow(2, z) * 256.0);
    }
    
    double minX = _lng2pixel(minLng, zoom);
    double maxX = _lng2pixel(maxLng, zoom);
    double minY = _lat2pixel(maxLat, zoom);
    double maxY = _lat2pixel(minLat, zoom);

    double routeWidth = maxX - minX;
    double routeHeight = maxY - minY;

    double paddedWidth = math.max(routeWidth + 80, 200.0);
    double paddedHeight = math.max(routeHeight + 80, 200.0);

    return Skeletonizer(
      enabled: isLoading,
      effect: ShimmerEffect(
        baseColor: AppTheme.surfaceHighlight,
        highlightColor: AppTheme.neonCyan.withOpacity(0.1),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // Cyber Grid Background (matching social/profile)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: CyberGridPainter()),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight.withOpacity(0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Text(
                          'MISSION COMPLETE',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppTheme.neonCyan,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.neonCyan.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Map View Hero Section
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.neonCyan.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonCyan.withOpacity(0.15),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Base dark background
                            Container(color: const Color(0xFF070B11)),
                            
                            // Auto-scaling custom map and route
                            FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: paddedWidth,
                                height: paddedHeight,
                                child: Stack(
                                  children: [
                                    StaticCartoMap(
                                      centerLat: centerLat,
                                      centerLng: centerLng,
                                      zoom: zoom,
                                      isLightMode: false,
                                    ),
                                    CustomPaint(
                                      painter: RouteLinePainter(
                                        points: workout.points,
                                        drawGrid: false,
                                        isLightMode: false,
                                        zoom: zoom,
                                      ),
                                      child: Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Premium Vignette Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 0.85,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF070B11).withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Inner shadow/border for depth
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.neonCyan.withOpacity(0.15)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceHighlight.withOpacity(
                                    0.72,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.neonCyan.withOpacity(0.18),
                                  ),
                                ),
                                child: Text(
                                  '${heroCameraLat.toStringAsFixed(5)}, ${heroCameraLng.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Bento Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Distance',
                            value: distKm,
                            unit: 'km',
                            icon: Icons.route,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Time',
                            value: timeStr,
                            unit: '',
                            icon: Icons.timer,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Avg Pace',
                            value: paceStr,
                            unit: '/km',
                            icon: Icons.speed,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Calories',
                            value: workout.caloriesEstimate.toStringAsFixed(0),
                            unit: 'kcal',
                            icon: Icons.local_fire_department,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Faction Points Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHighlight.withOpacity(0.78),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.06),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'FACTION POINTS',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '+500',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Colors.amber,
                                      shadows: [
                                        Shadow(
                                          color: Colors.amber.withOpacity(0.5),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 48,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (context, animation, secondaryAnimation) => const SocialGridShareOverlay(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.share,
                              color: AppTheme.deepDark,
                            ),
                            label: const Text(
                              'SHARE',
                              style: TextStyle(
                                color: AppTheme.deepDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonCyan,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            ),
                            icon: const Icon(
                              Icons.workspace_premium,
                              color: AppTheme.neonCyan,
                            ),
                            label: const Text(
                              'VIEW DOMINATION',
                              style: TextStyle(
                                color: AppTheme.neonCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppTheme.neonCyan.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceHighlight.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.08), blurRadius: 14),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            maxLines: 1,
                            softWrap: false,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: color,
                                  shadows: [
                                    Shadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                          ),
                          if (unit.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              unit,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cyber Grid Background Painter
class ShareTemplateBottomSheet extends StatefulWidget {
  final dynamic workout;

  const ShareTemplateBottomSheet({required this.workout, super.key});

  @override
  State<ShareTemplateBottomSheet> createState() => _ShareTemplateBottomSheetState();
}

class _ShareTemplateBottomSheetState extends State<ShareTemplateBottomSheet> {
  int selectedTemplateIndex = 0;
  int selectedFontIndex = 0;
  int selectedColorIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.78);

  static const List<String> templateNames = [
    'TEMPLATE 1',
    'TEMPLATE 2',
    'TEMPLATE 3',
    'TEMPLATE 4',
    'TEMPLATE 5',
    'TEMPLATE 6',
    'TEMPLATE 7',
    'CUSTOM',
  ];

  static const List<String> fontNames = [
    'Roboto',
    'Courier',
    'SansSerif',
    'Serif',
  ];

  static const List<Color> colorOptions = [
    AppTheme.neonCyan,
    AppTheme.secondary,
    Colors.amber,
    Colors.pinkAccent,
  ];

  void _shareSelectedTemplate() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${templateNames[selectedTemplateIndex]} as PNG',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = colorOptions[selectedColorIndex];
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF07111C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose a share template',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick one of the ready templates or customize a look with your own font and color.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: templateNames.length,
                  onPageChanged: (index) => setState(() {
                    selectedTemplateIndex = index;
                  }),
                  itemBuilder: (context, index) {
                    final isSelected = selectedTemplateIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.neonCyan
                                : Colors.white.withOpacity(0.08),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.35),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              templateNames[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceHighlight.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    index < 7 ? 'Template ${index + 1}' : 'Custom',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: index < 7
                                          ? AppTheme.neonCyan
                                          : AppTheme.secondary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Preview your result in PNG format before sharing.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(templateNames.length, (index) {
                  final active = index == selectedTemplateIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppTheme.neonCyan : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (selectedTemplateIndex == templateNames.length - 1) ...[
                Text(
                  'Custom template',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(fontNames.length, (index) {
                    final fontName = fontNames[index];
                    final active = selectedFontIndex == index;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < fontNames.length - 1 ? 8 : 0),
                        child: ElevatedButton(
                          onPressed: () => setState(() => selectedFontIndex = index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: active
                                ? AppTheme.neonCyan
                                : Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            fontName,
                            style: TextStyle(
                              color: active ? AppTheme.deepDark : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'Accent color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(colorOptions.length, (index) {
                    final color = colorOptions[index];
                    final active = selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColorIndex = index),
                      child: Container(
                        margin: EdgeInsets.only(right: index < colorOptions.length - 1 ? 10 : 0),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: active
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHighlight.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            previewColor.withOpacity(0.18),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RUN SUMMARY',
                            style: TextStyle(
                              color: previewColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${(widget.workout.distanceMeters / 1000.0).toStringAsFixed(2)} km  •  ${widget.workout.durationSeconds ~/ 60}m',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: fontNames[selectedFontIndex],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Share your victory with a slick template in PNG.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShareActionButton(
                    icon: Icons.download,
                    label: 'Download PNG',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Template PNG downloaded')),
                      );
                    },
                  ),
                  _ShareActionButton(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing to Instagram...')),
                      );
                    },
                  ),
                  _ShareActionButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing to Facebook...')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShareActionButton(
                    icon: Icons.message,
                    label: 'WhatsApp',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing to WhatsApp...')),
                      );
                    },
                  ),
                  _ShareActionButton(
                    icon: Icons.link,
                    label: 'Copy Link',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    },
                  ),
                  _ShareActionButton(
                    icon: Icons.file_download,
                    label: 'PNG',
                    onTap: _shareSelectedTemplate,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ShareActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppTheme.surfaceHighlight.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
              ),
            ],
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

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CyberGridPainter oldDelegate) => false;
}
