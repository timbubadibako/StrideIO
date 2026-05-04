import 'package:latlong2/latlong.dart' as latlong;
import 'package:maplibre_gl/maplibre_gl.dart';

class MapRouteLineLayerController {
  static const String routeSourceId = 'route-source';
  static const String routeGlowLayerId = 'route-glow-layer';
  static const String routeCoreLayerId = 'route-core-layer';
  static const String currentPosSourceId = 'current-pos-source';
  static const String currentPosLayerId = 'current-pos-layer';

  final Duration throttleDuration = const Duration(milliseconds: 800);
  DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastPositionUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  bool _initialized = false;

  MapLibreMapController? _mapController;

  void setMapController(MapLibreMapController controller) {
    _mapController = controller;
  }

  Future<void> initialize() async {
    if (_initialized || _mapController == null) return;
    _initialized = true;

    await _mapController!.addSource(
      routeSourceId,
      GeojsonSourceProperties(data: _emptyRouteGeoJson()),
    );

    await _mapController!.addLineLayer(
      routeSourceId,
      routeGlowLayerId,
      LineLayerProperties(
        lineColor: '#00F5FF',
        lineWidth: 9.0,
        lineOpacity: 0.25,
        lineJoin: 'round',
        lineCap: 'round',
      ),
    );

    await _mapController!.addLineLayer(
      routeSourceId,
      routeCoreLayerId,
      LineLayerProperties(
        lineColor: '#00F5FF',
        lineWidth: 5.0,
        lineOpacity: 0.95,
        lineJoin: 'round',
        lineCap: 'round',
      ),
    );

    await _mapController!.addSource(
      currentPosSourceId,
      GeojsonSourceProperties(data: _emptyPointGeoJson()),
    );

    await _mapController!.addCircleLayer(
      currentPosSourceId,
      currentPosLayerId,
      CircleLayerProperties(
        circleColor: '#00F5FF',
        circleRadius: 8.0,
        circleOpacity: 0.95,
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.0,
      ),
    );
  }

  Future<void> updateRoute(List<latlong.LatLng> route) async {
    if (_mapController == null) return;
    final now = DateTime.now();
    if (now.difference(_lastRouteUpdate) < throttleDuration) return;
    _lastRouteUpdate = now;

    final geoJson = _buildRouteGeoJson(route);
    await _mapController!.setGeoJsonSource(routeSourceId, geoJson);
  }

  Future<void> updateCurrentPosition(latlong.LatLng position) async {
    if (_mapController == null) return;
    final now = DateTime.now();
    if (now.difference(_lastPositionUpdate) < throttleDuration) return;
    _lastPositionUpdate = now;

    final geoJson = _buildPointGeoJson(position);
    await _mapController!.setGeoJsonSource(currentPosSourceId, geoJson);
  }

  Map<String, dynamic> _emptyRouteGeoJson() {
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {'type': 'LineString', 'coordinates': <List<double>>[]},
        },
      ],
    };
  }

  Map<String, dynamic> _buildRouteGeoJson(List<latlong.LatLng> route) {
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'LineString',
            'coordinates': route
                .map((point) => [point.longitude, point.latitude])
                .toList(),
          },
        },
      ],
    };
  }

  Map<String, dynamic> _emptyPointGeoJson() {
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'Point',
            'coordinates': <double>[0.0, 0.0],
          },
        },
      ],
    };
  }

  Map<String, dynamic> _buildPointGeoJson(latlong.LatLng point) {
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'Point',
            'coordinates': [point.longitude, point.latitude],
          },
        },
      ],
    };
  }
}
