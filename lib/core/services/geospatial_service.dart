import 'package:h3_flutter/h3_flutter.dart';

class GeospatialService {
  late final H3 _h3;

  GeospatialService() {
    _h3 = const H3Factory().load();
  }

  /// Converts a GPS coordinate (latitude, longitude) to an H3 Index string.
  /// [resolution] defines the size of the hexagon.
  /// Default resolution is 9, which represents roughly a neighborhood block.
  String coordinateToH3Index(double latitude, double longitude, {int resolution = 9}) {
    final coord = GeoCoord(lat: latitude, lon: longitude);
    final h3Index = _h3.geoToCell(coord, resolution);
    return h3Index.toRadixString(16);
  }

  /// Gets the polygon boundaries (GeoCoord list) for a specific H3 Index string.
  List<GeoCoord> getH3Boundary(String h3IndexString) {
    final h3Index = BigInt.parse(h3IndexString, radix: 16);
    return _h3.cellToBoundary(h3Index);
  }

  /// Gets the center coordinate for a given H3 Index string.
  GeoCoord getH3Center(String h3IndexString) {
    final h3Index = BigInt.parse(h3IndexString, radix: 16);
    return _h3.cellToGeo(h3Index);
  }
  
  /// Gets the neighboring H3 indices for a given H3 Index within a specific distance (k-ring).
  List<String> getNeighbors(String h3IndexString, {int k = 1}) {
    final h3Index = BigInt.parse(h3IndexString, radix: 16);
    final neighbors = _h3.gridDisk(h3Index, k);
    return neighbors.map((index) => index.toRadixString(16)).toList();
  }
}
