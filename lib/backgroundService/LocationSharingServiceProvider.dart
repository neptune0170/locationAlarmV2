import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/data_providers/address_api_provider.dart';
import '../../../core/preferences/user_preferences.dart';
import '../presentation/screens/HomeScreen/Track/utils/track_utils.dart';

class LocationSharingServiceProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  Timer? _locationUpdateTimer;

  // Fetch token from shared preferences
  Future<String?> _getToken() async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    return sessionData?['token'];
  }

  Future<void> startForegroundService() async {
    try {
      print("==========================================Print 1 ");

      // Initialize foreground task
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'location_sharing_channel',
          channelName: 'Location Sharing',
          channelDescription:
              'This notification appears when location sharing is active.',
          channelImportance: NotificationChannelImportance.DEFAULT,
          priority: NotificationPriority.DEFAULT,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000),
          autoRunOnBoot: false,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );

      print("==========================================Print 2 ");

      // Start the foreground service
      await FlutterForegroundTask.startService(
        notificationTitle: 'Location Sharing Active',
        notificationText: 'Your location is being shared in background',
        callback: _startLocationUpdates,
      );

      print("==========================================Print 3 ");

      // Connect to WebSocket
      await _connectWebSocket();

      print("Foreground service started successfully.");
      notifyListeners();
    } catch (e) {
      print('Error starting foreground service: $e');
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print('Authentication token not found!');
        return;
      }

      // Get event details from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? eventId = prefs.getString('active_event_id');
      String? email = prefs.getString('active_user_email');
      String? name = prefs.getString('active_user_name');

      if (eventId == null || email == null || name == null) {
        print('Event details not found in SharedPreferences');
        return;
      }

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse(
            'wss://locationalarm-v2-0-0.onrender.com/events/tracking?token=$token'),
      );

      // Start location updates
      _locationUpdateTimer =
          Timer.periodic(const Duration(seconds: 5), (timer) async {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        if (_channel != null && _channel!.sink != null) {
          try {
            Map<String, dynamic> message = {
              'groupId': eventId,
              'userId': email,
              'username': name,
              'latitude': position.latitude.toString(),
              'longitude': position.longitude.toString(),
            };

            print("Sending location update to WebSocket: $message");
            _channel!.sink.add(jsonEncode(message));

            // Update the notification with current coordinates
            FlutterForegroundTask.updateService(
              notificationTitle: 'Location Sharing Active',
              notificationText:
                  'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}',
            );
          } catch (e) {
            print('Error sending data to WebSocket: $e');
          }
        }
      });
    } catch (e) {
      print('Error in _connectWebSocket: $e');
    }
  }

  void _startLocationUpdates() {
    // This function will be called by the FlutterForegroundTask
    // Implementation is handled by _connectWebSocket which is called after starting the service
  }

  Future<void> stopForegroundService() async {
    try {
      // Cancel the timer
      _locationUpdateTimer?.cancel();

      // Close WebSocket
      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
      }

      // Stop the foreground service
      await FlutterForegroundTask.stopService();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('background_location_active', false);

      print("Background location sharing stopped");
      notifyListeners();
    } catch (e) {
      print('Error stopping foreground service: $e');
    }
  }

  // Check if location permissions are granted
  Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
