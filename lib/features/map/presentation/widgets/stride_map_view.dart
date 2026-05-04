import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/geospatial_service.dart';
import '../../../workout/application/workout_controller.dart';
import 'map_route_line_layer_controller.dart';

class StrideMapView extends ConsumerStatefulWidget {
  const StrideMapView({super.key});

  @override
  ConsumerState<StrideMapView> createState() => _StrideMapViewState();
}

class _StrideMapViewState extends ConsumerState<StrideMapView> {
  final GeospatialService _geoService = GeospatialService();
  MapLibreMapController? mapController;
  late final MapRouteLineLayerController _routeLayerController;

  // Kuningan Coordinate
  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(-6.225014, 106.827143),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _routeLayerController = MapRouteLineLayerController();
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _routeLayerController.setMapController(controller);
    _locateUser();
  }

  Future<void> _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16.0,
        ),
      );
    }
  }

  void _onStyleLoadedCallback() async {
    _generateGrid();
    await _routeLayerController.initialize();

    final route = ref.read(workoutControllerProvider.notifier).route;
    final routePoints = route
        .map((point) => latlong.LatLng(point.lat, point.lng))
        .toList();
    await _routeLayerController.updateRoute(routePoints);
    if (routePoints.isNotEmpty) {
      await _routeLayerController.updateCurrentPosition(routePoints.last);
    }
  }

  void _generateGrid() {
    if (mapController == null) return;

    // Generate the center hex and its neighbors (k-ring 2)
    final centerH3 = _geoService.coordinateToH3Index(
      _initialCamera.target.latitude,
      _initialCamera.target.longitude,
      resolution: 9,
    );
    final neighbors = _geoService.getNeighbors(centerH3, k: 3);

    int i = 0;
    for (String hex in neighbors) {
      final boundary = _geoService.getH3Boundary(hex);
      final points = boundary
          .map((coord) => LatLng(coord.lat, coord.lon))
          .toList();

      // Assign dummy faction colors
      Color factionColor;
      if (i == 0) {
        factionColor = AppTheme.neonCyan; // Current location claimed by player
      } else if (i % 4 == 0) {
        factionColor = AppTheme.neonCyan; // Player's faction
      } else if (i % 7 == 0) {
        factionColor = AppTheme.error; // Rival faction
      } else if (i % 11 == 0) {
        factionColor = AppTheme.secondary; // Third faction
      } else {
        factionColor = Colors.transparent; // Unclaimed
      }

      // MapLibre expects hex colors like #FF0000
      String hexColor = factionColor == Colors.transparent
          ? '#ffffff'
          : '#${factionColor.value.toRadixString(16).substring(2, 8)}';

      double opacity = factionColor == Colors.transparent ? 0.02 : 0.08;

      mapController!.addFill(
        FillOptions(
          geometry: [points],
          fillColor: hexColor,
          fillOpacity: opacity,
          fillOutlineColor: hexColor,
        ),
      );
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to workout changes to draw the polyline and current location marker
    ref.listen(workoutControllerProvider, (previous, next) {
      final route = next.points
          .map((p) => latlong.LatLng(p.lat, p.lng))
          .toList();
      if (route.isNotEmpty) {
        _routeLayerController.updateRoute(route);
        _routeLayerController.updateCurrentPosition(route.last);
      }
    });

    return MapLibreMap(
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoadedCallback,
      initialCameraPosition: _initialCamera,
      // Using CartoDB Dark Matter style, which perfectly matches our Cyberpunk aesthetic
      styleString:
          'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json',
      myLocationEnabled: true,
      compassEnabled: false,
      myLocationRenderMode: MyLocationRenderMode.compass,
    );
  }
}
