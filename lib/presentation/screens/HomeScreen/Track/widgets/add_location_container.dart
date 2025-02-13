import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../data/data_providers/address_api_provider.dart';
import '../../../../state_management/providers/circle_style_provider.dart';
import '../../../../state_management/providers/radius_provider.dart';
import '../../../../state_management/providers/location_provider.dart';

class AddLocationContainer extends StatefulWidget {
  final String? title;
  final double? distance;
  final int? driveTime;
  final VoidCallback onSave;

  const AddLocationContainer({
    Key? key,
    this.title,
    this.distance,
    this.driveTime,
    required this.onSave,
  }) : super(key: key);

  @override
  _AddLocationContainerState createState() => _AddLocationContainerState();
}

final AudioPlayer _audioPlayer = AudioPlayer();

class _AddLocationContainerState extends State<AddLocationContainer> {
  final TextEditingController _alarmNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alarmNameController.text = widget.title ?? '';
  }

  String generateRandomId(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> _saveAddress() async {
    final radiusProvider = Provider.of<RadiusProvider>(context, listen: false);
    final circleStyleProvider =
        Provider.of<CircleStyleProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    final alarmName = _alarmNameController.text;
    final note = _noteController.text;
    final radius = radiusProvider.radius;
    final alarmRings = circleStyleProvider.isOnEntry;
    final latitude = locationProvider.latitude;
    final longitude = locationProvider.longitude;
    final alarmId = generateRandomId(20);

    Map<String, dynamic> alarm = {
      'alarm_name': alarmName,
      'note': note,
      'radius': radius,
      'alarm_rings_on_entry': alarmRings,
      'latitude': latitude,
      'longitude': longitude,
      'alarmId': alarmId
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmList = prefs.getStringList('alarms') ?? [];

    alarmList.add(jsonEncode(alarm));

    await prefs.setStringList('alarms', alarmList);

    print('✅ Alarm successfully saved in SharedPreferences!');

    widget.onSave();
    _loadAlarms();

    final addressApiProvider = AddressApiProvider();

    bool success = await addressApiProvider.saveAddress(
        alarmName: alarmName,
        note: note,
        radius: radius,
        alarmRings: alarmRings,
        latitude: latitude,
        longitude: longitude,
        alarmId: alarmId);

    if (success) {
      // Handle success, e.g., show a success message
      print('Address saved successfully');
    } else {
      // Handle failure, e.g., show an error message
      print('Failed to save address');
    }

    widget.onSave();
    // Start the foreground service

    print("After Save -Foregrond service ");
    await _startForegroundServiceWithNotification();
  }

  Future<void> _startForegroundServiceWithNotification() async {
    try {
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

      await FlutterForegroundTask.startService(
        notificationTitle: 'Tracking Alarm',
        notificationText: 'Tracking location for alarm: ',
      );

      Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
        print("Hello");
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> alarmList = prefs.getStringList('alarms') ?? [];
          bool isInsideAnyCircle = false;
          String? matchedAlarm;

          for (String alarmJson in alarmList) {
            Map<String, dynamic> alarm = jsonDecode(alarmJson);
            double circleLat = alarm['latitude'];
            double circleLong = alarm['longitude'];
            double radius = alarm['radius'];
            String alarmId = alarm['alarmId'];

            if (_isInsideCircle(
              position.latitude,
              position.longitude,
              circleLat,
              circleLong,
              radius,
            )) {
              isInsideAnyCircle = true;
              matchedAlarm = alarmJson;
              break;
            }
          }

          if (isInsideAnyCircle) {
            _playAlarm();

            // Delay notification by 1-2 seconds
            await Future.delayed(const Duration(seconds: 2));

            // Show notification
            FlutterForegroundTask.updateService(
              notificationTitle: 'Inside Circle',
              notificationText: 'You have arrived at a predefined location!',
            );

            print('You have arrived at a predefined location!');

            // Remove the matched alarm from SharedPreferences
            if (matchedAlarm != null) {
              print("MatchedAlarm ==========================================" +
                  matchedAlarm);

              Map<String, dynamic> matchedAlarmData = jsonDecode(matchedAlarm);
              String alarmId = matchedAlarmData['alarmId'];
              alarmList.remove(matchedAlarm);
              await prefs.setStringList('alarms', alarmList);
              print('Removed matched alarm: $matchedAlarm');
              // Extract the alarm ID from JSON to delete from the server
              // Ensure ID exists

              // Delete the alarm from the server
              final addressApiProvider = AddressApiProvider();

              print("][][][][]][][][][][][][][][][][][][][][] " + alarmId);
              addressApiProvider.deleteAddress(alarmId);
            }

            // Notify TrackPage to refresh circles
            Navigator.of(context)
                .pop(); // Or use another mechanism to refresh the UI
          } else {
            // Update the notification with the current location
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

      print('Foreground service started successfully.');
    } catch (e) {
      print('Error starting foreground service: $e');
    }
  }

  Future<void> _playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource("audio/alarm_audio.mp3"));
      _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the alarm
      print("🔊 Alarm started!");
    } catch (e) {
      print("❌ Failed to play alarm: $e");
    }
  }

// ✅ Function to stop alarm sound
  Future<void> _stopAlarm() async {
    try {
      await _audioPlayer.stop();
      print("🔇 Alarm stopped!");
    } catch (e) {
      print("❌ Failed to stop alarm: $e");
    }
  }

// Helper method to check if a point is inside a circle
  bool _isInsideCircle(
    double currentLat,
    double currentLong,
    double circleLat,
    double circleLong,
    double radiusInMeters,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    // Round values to avoid precision issues
    currentLat = double.parse(currentLat.toStringAsFixed(6));
    currentLong = double.parse(currentLong.toStringAsFixed(6));
    circleLat = double.parse(circleLat.toStringAsFixed(6));
    circleLong = double.parse(circleLong.toStringAsFixed(6));

    double dLat = _degreesToRadians(circleLat - currentLat);
    double dLong = _degreesToRadians(circleLong - currentLong);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(currentLat)) *
            cos(_degreesToRadians(circleLat)) *
            sin(dLong / 2) *
            sin(dLong / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance <= (radiusInMeters * 1000); //In KM
  }

// Helper method to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Future<void> _loadAlarms() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Retrieve the list of alarms from SharedPreferences
  //   List<String> alarmList = prefs.getStringList('alarms') ?? [];
  //   // Retrieve the list of alarms from SharedPreferences
  //   // Print the total number of alarms
  //   print('Total Alarms: ${alarmList.length}');

  //   // Convert each JSON string back into a Map object
  //   List<Map<String, dynamic>> alarms = alarmList.map((alarmJson) {
  //     return jsonDecode(alarmJson) as Map<String, dynamic>;
  //   }).toList();

  //   // Now you can use the `alarms` list in your app
  //   for (var alarm in alarms) {
  //     print(
  //         'Loaded Alarm: ${alarm['alarm_name']}, ${alarm['note']}, ${alarm['radius']}, ${alarm['latitude']}, ${alarm['longitude']}');
  //   }
  // }

  Future<void> _loadAlarms() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmList = prefs.getStringList('alarms') ?? [];

    print('Total Alarms: ${alarmList.length}');
    for (String alarmJson in alarmList) {
      Map<String, dynamic> alarm = jsonDecode(alarmJson);
      print(
          'Alarm Data -> Name: ${alarm['alarm_name']}, Lat: ${alarm['latitude']}, Long: ${alarm['longitude']}, Radius: ${alarm['radius']}');
    }
  }

  Future<void> _restartForegroundService() async {
    await FlutterForegroundTask.stopService();
    await Future.delayed(Duration(seconds: 2)); // Wait to ensure service stops
    await _startForegroundServiceWithNotification();
  }

  @override
  Widget build(BuildContext context) {
    final circleStyleProvider = Provider.of<CircleStyleProvider>(context);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and radius display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? 'Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.distance?.toStringAsFixed(1) ?? '0'} km, ${widget.driveTime ?? 0} mins Drive',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                // Radius display
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${Provider.of<RadiusProvider>(context).radius.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Alarm Rings'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title:
                        Text('On entry', style: TextStyle(color: Colors.grey)),
                    value: true,
                    groupValue: circleStyleProvider.isOnEntry,
                    onChanged: (value) {
                      circleStyleProvider.setIsOnEntry(value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title:
                        Text('On Exit', style: TextStyle(color: Colors.grey)),
                    value: false,
                    groupValue: circleStyleProvider.isOnEntry,
                    onChanged: (value) {
                      circleStyleProvider.setIsOnEntry(value!);
                    },
                  ),
                ),
              ],
            ),
            Text('Radius'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey,
                thumbColor: Colors.black,
                overlayColor: Colors.black.withOpacity(0.2),
              ),
              child: Slider(
                value: Provider.of<RadiusProvider>(context).radius,
                min: 0.0,
                max: 10.0,
                divisions: 100,
                label:
                    '${Provider.of<RadiusProvider>(context).radius.toStringAsFixed(1)} km',
                onChanged: (value) {
                  Provider.of<RadiusProvider>(context, listen: false)
                      .setRadius(value);
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarm Name',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextField(
                  controller: _alarmNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal, // Normal font weight
                  ),
                ),
              ],
            ),
            Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Note',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal, // Normal font weight
                  ),
                ),
              ],
            ),
            Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _alarmNameController.clear();
                      _noteController.clear();
                      widget.onSave();
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
