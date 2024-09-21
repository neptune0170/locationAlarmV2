import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/preferences/user_preferences.dart';

class AotTrackingPage extends StatefulWidget {
  const AotTrackingPage({super.key});

  @override
  State<AotTrackingPage> createState() => _AotTrackingPageState();
}

class _AotTrackingPageState extends State<AotTrackingPage> {
  late GoogleMapController mapController;
  final LatLng _initialPosition =
      const LatLng(37.7749, -122.4194); // Default position: San Francisco
  final Set<Marker> _markers = {}; // Markers for users
  late WebSocketChannel _channel;
  late Timer _timer;

  // Controllers for user input
  final TextEditingController _groupIdController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Fetch token from shared preferences
  Future<String?> _getToken() async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return null;
    }

    String token = sessionData['token'];
    if (token != null) {
      print('Retrieved token: $token');
    } else {
      print('Token not found');
    }
    return token;
  }

  // Connect to WebSocket and send data
  Future<void> _connectWebSocket(
      String groupId, String userId, String username) async {
    String? token = await _getToken();

    if (token == null) {
      // If token is null, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found!')),
      );
      return;
    }

    // WebSocket URL with dynamic token
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/events/tracking?token=$token'),
    );

    // Listen for incoming messages from the WebSocket
    _channel.stream.listen((message) {
      _handleIncomingMessage(message);
    });

    // Periodically send location updates
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      String latitude = '${position.latitude}';
      String longitude = '${position.longitude}';

      // Prepare the message with 5 parameters and send it
      Map<String, dynamic> message = {
        'groupId': groupId,
        'userId': userId,
        'username': username,
        'latitude': latitude,
        'longitude': longitude,
      };

      _channel.sink.add(jsonEncode(message));
    });
  }

  void _handleIncomingMessage(String message) {
    // Parse the incoming message (coordinates from the group members)
    Map<String, dynamic> coordinatesMap = jsonDecode(message);

    // Update markers for each user in the group
    Set<Marker> newMarkers = {};
    coordinatesMap.forEach((userId, userDetails) {
      LatLng userPosition = LatLng(double.parse(userDetails['latitude']),
          double.parse(userDetails['longitude']));

      // Add a marker for each user
      newMarkers.add(Marker(
        markerId: MarkerId(userId),
        position: userPosition,
        infoWindow: InfoWindow(
            title: userDetails['username'], snippet: 'User ID: $userId'),
      ));
    });

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    _channel.sink.close();
    _timer.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Start tracking after the user provides the required details
  void _startTracking() {
    String groupId = _groupIdController.text;
    String userId = _userIdController.text;
    String username = _usernameController.text;

    if (groupId.isNotEmpty && userId.isNotEmpty && username.isNotEmpty) {
      _connectWebSocket(groupId, userId, username);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all required details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12.0,
            ),
            markers: _markers, // Display markers on the map
            mapType: MapType.normal,
            myLocationEnabled: true, // Show current user location
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: _groupIdController,
                  decoration: InputDecoration(labelText: 'Group ID'),
                ),
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(labelText: 'User ID'),
                ),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startTracking,
                  child: Text('Start Tracking'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: FloatingActionButton(
              onPressed: _addEvent, // Call _addEvent method here
              backgroundColor: Color.fromARGB(255, 0, 0, 0), // Grey color
              child: const Icon(Icons.more_vert_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addEvent() {
    Navigator.pushNamed(context, '/groupEvent');
  }
}
