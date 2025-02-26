import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../data/data_providers/address_api_provider.dart';
import '../presentation/screens/HomeScreen/Track/utils/track_utils.dart';

class ForegroundServiceProvider with ChangeNotifier {
  Future<void> startForegroundService() async {
    try {
      print("==========================================Print 1 ");
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground_service_channel',
          channelName: 'Foreground Service',
          channelDescription:
              'This notification appears when the service is running.',
          channelImportance: NotificationChannelImportance.DEFAULT,
          priority: NotificationPriority.DEFAULT,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
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

      await FlutterForegroundTask.startService(
        notificationTitle: 'Tracking Alarm',
        notificationText: 'Tracking location for alarm: ',
      );

      Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        print("Fetching Location...");
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> alarmList = prefs.getStringList('alarms') ?? [];

          if (alarmList.isEmpty) {
            print("🛑 No alarms found! Stopping Foreground Service...");
            timer.cancel(); // Stop the periodic timer
            await stopForegroundService(); // Call the stop method
            return; // Exit early
          }
          bool isInsideAnyCircle = false;
          bool isOutsideAnyCircle = false;
          String? matchedAlarm;
          String? alarmName;
          String? alarmNote;

          for (String alarmJson in alarmList) {
            Map<String, dynamic> alarm = jsonDecode(alarmJson);
            double circleLat = alarm['latitude'];
            double circleLong = alarm['longitude'];
            double radius = alarm['radius'];
            String alarmId = alarm['alarmId'];
            alarmName = alarm['alarm_name'];
            alarmNote = alarm['note'];
            bool alarm_rings_on_entry = alarm['alarm_rings_on_entry'];

            if (_isInsideCircle(position.latitude, position.longitude,
                    circleLat, circleLong, radius) &&
                alarm_rings_on_entry) {
              isInsideAnyCircle = true;
              matchedAlarm = alarmJson;
              break;
            }
            if (!_isInsideCircle(position.latitude, position.longitude,
                    circleLat, circleLong, radius) &&
                !alarm_rings_on_entry) {
              isOutsideAnyCircle = true;
              matchedAlarm = alarmJson;
            }
          }
          print("==========================================Print 3 ");

          String? status;
          if (isOutsideAnyCircle || isInsideAnyCircle) {
            TrackUtils.playAlarm();
            status = isInsideAnyCircle
                ? "You are near the Destination!"
                : "You have Exited the location!";

            _showGeofenceNotification(alarmName!, alarmNote!, status);

            if (matchedAlarm != null) {
              Map<String, dynamic> matchedAlarmData = jsonDecode(matchedAlarm);
              String alarmId = matchedAlarmData['alarmId'];
              alarmList.remove(matchedAlarm);
              await prefs.setStringList('alarms', alarmList);

              final addressApiProvider = AddressApiProvider();
              addressApiProvider.deleteAddress(alarmId);
            }
          } else {
            FlutterForegroundTask.updateService(
              notificationTitle: 'Tracking Alarm',
              notificationText:
                  'Lat: ${position.latitude}, Lon: ${position.longitude}',
            );
          }
        } catch (e) {
          print('Failed to fetch location: $e');
        }
      });
      print("==========================================Print 4 ");

      print('Foreground service started successfully.');
    } catch (e) {
      print('Error starting foreground service: $e');
    }
  }

  Future<void> stopForegroundService() async {
    await FlutterForegroundTask.stopService();
  }

  Future<void> _showGeofenceNotification(
      String alarmName, String alarmNote, String status) async {
    print("📢 Showing Geofence Notification...");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      channelDescription: 'Notifies when entering a geofence',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'Stop',
          'Stop',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      0,
      alarmNote.isNotEmpty ? "$alarmName : $alarmNote" : "$alarmName",
      status,
      notificationDetails,
      payload: 'details',
    );

    print("📩 Notification Sent Successfully!");
  }

  bool _isInsideCircle(double currentLat, double currentLong, double circleLat,
      double circleLong, double radiusInMeters) {
    const double earthRadius = 6371000;

    double dLat = _degreesToRadians(circleLat - currentLat);
    double dLong = _degreesToRadians(circleLong - currentLong);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(currentLat)) *
            cos(_degreesToRadians(circleLat)) *
            sin(dLong / 2) *
            sin(dLong / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance <= (radiusInMeters * 1000);
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
