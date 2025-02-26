import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationalarm/data/data_providers/location_api_provider.dart';
import 'package:locationalarm/core/utils/location_utils.dart';

class TrackUtils {
  final LocationApiProvider _locationApiProvider = LocationApiProvider();
  final LocationUtils _locationUtils = LocationUtils();
  static AudioPlayer _audioPlayer = AudioPlayer(); // Static instance
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

  double calculateDistanceBwPoints(double x1, double y1, double x2, double y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  void checkIfEnteredCircle(double destinationX, double destinationY,
      double currentX, double currentY, double radius) {
    double distance = calculateDistanceBwPoints(
        destinationX, destinationY, currentX, currentY);

    if (distance <= radius) {
      print('Entered the circle [][][][][][][][][]');
    }
  }

  /// ✅ **Function to play alarm**
  static Future<void> playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource("audio/alarm_audio.mp3"));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      print("🔊 Alarm started!");
    } catch (e) {
      print("❌ Failed to play alarm: $e");
    }
  }

  /// ✅ **Function to stop alarm**
  static Future<void> stopAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.stop();
      await _audioPlayer.dispose();

      // Reinitialize AudioPlayer instance
      _audioPlayer = AudioPlayer(); // Release resources

      print("🔇 Alarm stopped!");
    } catch (e) {
      print("❌ Failed to stop alarm: $e");
    }
  }
}
