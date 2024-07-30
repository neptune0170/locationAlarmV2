import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationalarm/data/data_providers/location_api_provider.dart';
import 'package:locationalarm/core/utils/location_utils.dart';

class TrackUtils {
  final LocationApiProvider _locationApiProvider = LocationApiProvider();
  final LocationUtils _locationUtils = LocationUtils();

  Future<Position?> getCurrentLocation() async {
    return await _locationUtils.getCurrentLocation();
  }

  Future<List<dynamic>> getSuggestions(String query) async {
    return await _locationApiProvider.getSuggestions(query);
  }

  Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    return await _locationApiProvider.getLatLngFromPlaceId(placeId);
  }

  double calculateDistance(LatLng start, LatLng end) {
    return _locationUtils.calculateDistance(start, end) / 1000;
  }

  int calculateDriveTime(double distance) {
    return (distance / 50 * 60).toInt(); // Assuming average speed 50km/h
  }
}
