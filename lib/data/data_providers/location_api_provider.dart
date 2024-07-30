// location_api_provider.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationApiProvider {
  final String apiKey = 'AIzaSyAeLI09lwxkb-j_c5I4QEJJuOr-JPgQIw4';

  Future<List<dynamic>> getSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['predictions'] ?? [];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey'));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final location = result['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      return null;
    }
  }

  Future<String> getDrivingTime(
      double startLat, double startLng, double endLat, double endLng) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$apiKey'));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final duration = result['routes'][0]['legs'][0]['duration']['text'];
      return duration;
    } else {
      throw Exception('Failed to load driving time');
    }
  }
}
