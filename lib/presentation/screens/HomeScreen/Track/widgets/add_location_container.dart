import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../backgroundService/ForegroundServiceProvider.dart';
import '../../../../../data/data_providers/address_api_provider.dart';
import '../../../../state_management/providers/circle_style_provider.dart';
import '../../../../state_management/providers/radius_provider.dart';
import '../../../../state_management/providers/location_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/track_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
      ongoing: true, // 🔒 Keeps the notification persistent
      autoCancel:
          false, // 🔒 Prevents notification from being dismissed by swipe
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

    await flutterLocalNotificationsPlugin.show(
      0,
      alarmNote != null && alarmNote.isNotEmpty
          ? "$alarmName : $alarmNote"
          : "$alarmName",
      status,
      notificationDetails,
      payload: 'details',
    );

    print("📩 Notification Sent Successfully!");
  }

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

    print('✅ Alarm successfully saved in SharedPreferences! ' +
        alarmList.toString());

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
    //  await _startForegroundServiceWithNotification();

    final foregroundServiceProvider = ForegroundServiceProvider();
    await foregroundServiceProvider.startForegroundService();
  }

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
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.7, // Adjust width dynamically
                      child: Text(
                        widget.title ?? 'Location',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines:
                            1, // Ensure text does not wrap to the next line
                        overflow: TextOverflow
                            .ellipsis, // Show "..." if text is too long
                      ),
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
                    title: Text('On Entry',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    value: true,
                    groupValue: circleStyleProvider.isOnEntry,
                    onChanged: (value) {
                      Provider.of<CircleStyleProvider>(context, listen: false)
                          .setIsOnEntry(value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text('On Exit',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    value: false,
                    groupValue: circleStyleProvider.isOnEntry,
                    onChanged: (value) {
                      Provider.of<CircleStyleProvider>(context, listen: false)
                          .setIsOnEntry(value!);
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
