import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/zone_model.dart';

class OverpassService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';
  static const double _searchRadiusMeters = 2000; // 2km

  /// Fetch all nearby POIs using a single optimized Overpass query
  Future<List<ZoneModel>> fetchNearbyPOIs(double lat, double lon) async {
    print('OverpassService: Preparing combined query for $lat, $lon');
    final query = '''
[out:json][timeout:30];
(
  node["shop"~"supermarket|mall|convenience|department_store"](around:$_searchRadiusMeters,$lat,$lon);
  way["shop"~"supermarket|mall|convenience|department_store"](around:$_searchRadiusMeters,$lat,$lon);
  node["amenity"~"restaurant|fast_food|cafe"](around:$_searchRadiusMeters,$lat,$lon);
  way["amenity"~"restaurant|fast_food|cafe"](around:$_searchRadiusMeters,$lat,$lon);
);
out center;
''';

    try {
      print('OverpassService: Executing HTTP POST...');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        print('OverpassService: Received ${elements.length} elements from API.');

        return elements.map((element) {
          final lat = element['lat'] ?? element['center']?['lat'];
          final lon = element['lon'] ?? element['center']?['lon'];
          if (lat == null || lon == null) return null;

          final tags = element['tags'] ?? {};
          // Determine type from tags for correct emoji mapping
          String type = 'unknown';
          if (tags.containsKey('shop')) {
            type = tags['shop'];
          } else if (tags.containsKey('amenity')) {
            type = tags['amenity'];
          }

          return ZoneModel.fromJson(
            {
              'id': element['id'],
              'lat': lat,
              'lon': lon,
              'tags': tags,
            },
            type,
          );
        }).whereType<ZoneModel>().toList();
      } else {
        print('OverpassService: API error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('OverpassService: Exception during fetch: $e');
      return [];
    }
  }

  // Legacy single-fetch methods refactored to use the combined logic if needed, 
  // but we prefer fetchNearbyPOIs now.
  Future<List<ZoneModel>> fetchSupermarkets(double lat, double lon) async => fetchNearbyPOIs(lat, lon);
  Future<List<ZoneModel>> fetchMalls(double lat, double lon) async => fetchNearbyPOIs(lat, lon);
  Future<List<ZoneModel>> fetchRestaurants(double lat, double lon) async => fetchNearbyPOIs(lat, lon);
  Future<List<ZoneModel>> fetchFastFood(double lat, double lon) async => fetchNearbyPOIs(lat, lon);
  Future<List<ZoneModel>> fetchConvenienceStores(double lat, double lon) async => fetchNearbyPOIs(lat, lon);
  Future<List<ZoneModel>> fetchDepartmentStores(double lat, double lon) async => fetchNearbyPOIs(lat, lon);
  Future<List<ZoneModel>> fetchCafes(double lat, double lon) async => fetchNearbyPOIs(lat, lon);

  /// Execute Overpass query (Legacy helper)
  Future<List<ZoneModel>> _executeQuery(String query, String type) async {
    return fetchNearbyPOIs(0, 0); // Not used anymore but kept to avoid broken references
  }

  /// Build Overpass QL query (Legacy helper)
  String _buildOverpassQuery(String filter, double lat, double lon) {
    return ''; // Not used
  }
}
