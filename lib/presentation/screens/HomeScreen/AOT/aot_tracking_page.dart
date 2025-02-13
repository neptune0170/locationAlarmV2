import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/preferences/user_preferences.dart';

class AotTrackingPage extends StatefulWidget {
  final String eventId;
  final String name;
  final String email;

  const AotTrackingPage(this.eventId, this.name, this.email, {super.key});

  @override
  State<AotTrackingPage> createState() => _AotTrackingPageState();
}

class _AotTrackingPageState extends State<AotTrackingPage> {
  late GoogleMapController mapController;
  final LatLng _initialPosition =
      const LatLng(37.7749, -122.4194); // San Francisco
  final Map<String, Marker> _userMarkers = {}; // Store markers by userId
  final Set<Polyline> _polylines = {}; // Holds the polylines for routes
  LatLng? _destinationPosition; // Holds the destination position
  LatLng? _myPosition; // Holds the user's current position
  WebSocketChannel? _channel; // Nullable to handle disconnection cases
  late Timer _timer;
  String googleApiKey =
      'AIzaSyAeLI09lwxkb-j_c5I4QEJJuOr-JPgQIw4'; // Replace with your Google API key

  @override
  void initState() {
    super.initState();
    _startTracking(); // Start tracking on widget creation
    _loadDestinationFromPreferences(); // Load the destination from shared preferences
  }

  // Fetch token from shared preferences
  Future<String?> _getToken() async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    return sessionData?['token'];
  }

  // Fetch destination location from SharedPreferences and display it on the map
  Future<void> _loadDestinationFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locationName = prefs.getString('destinationLocationName');
    String? latitude = prefs.getString('destinationLatitude');
    String? longitude = prefs.getString('destinationLongitude');

    if (locationName != null && latitude != null && longitude != null) {
      _destinationPosition =
          LatLng(double.parse(latitude), double.parse(longitude));
      setState(() {
        // Add destination marker to _userMarkers to ensure it's always visible
        _userMarkers['destination'] = Marker(
          markerId: MarkerId('destination'),
          position: _destinationPosition!,
          infoWindow: InfoWindow(title: locationName, snippet: 'Destination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          zIndex: 2.0, // Ensure destination marker is above polyline
        );
      });
    }
  }

  // Connect to WebSocket and send location updates periodically (every 5 seconds)
  Future<void> _connectWebSocket() async {
    String? token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found!')),
      );
      return;
    }

    _channel = WebSocketChannel.connect(
      Uri.parse(
          'wss://locationalarm-v2-0-0.onrender.com/events/tracking?token=$token'),
    );

    _channel!.stream.listen(
      (message) => _handleIncomingMessage(message),
      onDone: () => print('WebSocket connection closed'),
      onError: (error) => print('WebSocket error: $error'),
    );

    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _myPosition = LatLng(position.latitude, position.longitude);

      if (_channel != null && _channel!.sink != null) {
        try {
          Map<String, dynamic> message = {
            'groupId': widget.eventId,
            'userId': widget.email,
            'username': widget.name,
            'latitude': _myPosition!.latitude.toString(),
            'longitude': _myPosition!.longitude.toString(),
          };
          _channel!.sink.add(jsonEncode(message));
        } catch (e) {
          print('Error sending data: $e');
        }
      }

      _drawRouteUsingDirectionsAPI(
        _myPosition!,
        _destinationPosition!,
        'my_path',
        Colors.green,
        showEstimatedTime: true,
        isMyPosition: true,
      );
    });
  }

  // Draw the route using the Google Directions API
  Future<void> _drawRouteUsingDirectionsAPI(
      LatLng start, LatLng end, String polylineId, Color color,
      {bool showEstimatedTime = false,
      bool isMyPosition = false,
      String? userId}) async {
    if (start != null && end != null) {
      String url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${start.latitude},${start.longitude}'
          '&destination=${end.latitude},${end.longitude}'
          '&key=$googleApiKey';

      var response = await http.get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        List<dynamic> routes = data['routes'];
        if (routes.isNotEmpty) {
          String polylinePoints = routes[0]['overview_polyline']['points'];
          List<LatLng> polylineCoordinates = _decodePolyline(polylinePoints);

          setState(() {
            _polylines.removeWhere(
                (polyline) => polyline.polylineId == PolylineId(polylineId));
            _polylines.add(
              Polyline(
                polylineId: PolylineId(polylineId),
                points: polylineCoordinates,
                color: color,
                width: 5,
                zIndex: 1,
              ),
            );
          });

          if (showEstimatedTime) {
            String estimatedTime = routes[0]['legs'][0]['duration']['text'];
            if (isMyPosition) {
              _showEstimatedTimeInInfoWindow(estimatedTime);
            } else if (userId != null) {
              _showEstimatedTimeForOtherUsers(estimatedTime, userId);
            }
          }
        }
      } else {
        print('Error fetching route: ${data['status']}');
      }
    }
  }

  void _showEstimatedTimeInInfoWindow(String estimatedTime) {
    if (_myPosition != null) {
      setState(() {
        _userMarkers['my_position'] = Marker(
          markerId: MarkerId('my_position'),
          position: _myPosition!,
          infoWindow: InfoWindow(
            title: 'My Location',
            snippet: 'Estimated time to destination: $estimatedTime',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          zIndex: 3.0, // Ensure this marker is visible above polylines
        );
      });
    }
  }

  void _showEstimatedTimeForOtherUsers(String estimatedTime, String userId) {
    setState(() {
      if (_userMarkers.containsKey(userId)) {
        Marker existingMarker = _userMarkers[userId]!;
        _userMarkers[userId] = existingMarker.copyWith(
          infoWindowParam: InfoWindow(
            title: existingMarker.infoWindow.title,
            snippet: 'Estimated time to destination: $estimatedTime',
          ),
        );
      }
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  // Handle incoming WebSocket message and update markers for users
  void _handleIncomingMessage(String message) {
    try {
      Map<String, dynamic> coordinatesMap = jsonDecode(message);

      coordinatesMap.forEach((userId, userDetails) {
        String? latitude = userDetails['latitude']?.toString();
        String? longitude = userDetails['longitude']?.toString();
        String? username = userDetails['username']?.toString();

        if (userId != widget.email &&
            latitude != null &&
            longitude != null &&
            username != null) {
          LatLng userPosition =
              LatLng(double.parse(latitude), double.parse(longitude));

          // Update or add the red marker for the user
          setState(() {
            _userMarkers[userId] = Marker(
              markerId: MarkerId(userId),
              position: userPosition,
              infoWindow:
                  InfoWindow(title: username, snippet: 'User ID: $userId'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              zIndex: 3.0, // Ensure red markers are above polylines
            );
          });

          if (_destinationPosition != null) {
            _drawRouteUsingDirectionsAPI(userPosition, _destinationPosition!,
                'path_$userId', Colors.blue,
                showEstimatedTime: true, isMyPosition: false, userId: userId);
          }
        }
      });

      // Re-add the destination marker to ensure it's always rendered
      if (_destinationPosition != null &&
          !_userMarkers.containsKey('destination')) {
        _userMarkers['destination'] = Marker(
          markerId: MarkerId('destination'),
          position: _destinationPosition!,
          infoWindow:
              InfoWindow(title: 'Destination', snippet: 'Final Destination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          zIndex: 2.0, // Ensure destination marker is above polyline
        );
      }
    } catch (e) {
      print('Error processing WebSocket message: $e');
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    if (_channel != null) {
      _channel!.sink.close();
    }
    _timer.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _startTracking() {
    _connectWebSocket();
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
            markers:
                Set<Marker>.of(_userMarkers.values), // Pass markers from map
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: FloatingActionButton(
              onPressed: _addEvent,
              backgroundColor: Colors.black,
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
