import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationApiProvider {
  final String apiKey = 'AIzaSyAeLI09lwxkb-j_c5I4QEJJuOr-JPgQIw4';

  // Existing getSuggestions method (Unchanged)
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

  // New method to fetch suggestions with coordinates
  Future<List<Map<String, dynamic>>> getSuggestionsWithCoordinates(
      String query) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final predictions = result['predictions'] ?? [];

      List<Map<String, dynamic>> suggestionsWithCoordinates = [];

      // Iterate over each prediction and fetch the corresponding lat/lng
      for (var prediction in predictions) {
        final placeId = prediction['place_id'];
        final placeName = prediction['description'];

        // Fetch lat/lng using the Place Details API
        final latLng = await getLatLngFromPlaceId(placeId);

        if (latLng != null) {
          suggestionsWithCoordinates.add({
            'placeName': placeName,
            'lat': latLng.latitude,
            'lng': latLng.longitude,
          });
        }
      }

      return suggestionsWithCoordinates;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  // Helper method to fetch coordinates for a given place ID
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

  // Existing method to get driving time (unchanged)
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
