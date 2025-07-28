// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../core/preferences/user_preferences.dart';
// import '../Track/widgets/address_box.dart';
// // Import the AddressBox widget

// class AotTrackingPage extends StatefulWidget {
//   final String eventId;
//   final String name;
//   final String email;

//   const AotTrackingPage(this.eventId, this.name, this.email, {super.key});

//   @override
//   State<AotTrackingPage> createState() => _AotTrackingPageState();
// }

// class _AotTrackingPageState extends State<AotTrackingPage> {
//   late GoogleMapController mapController;
//   final LatLng _initialPosition =
//       const LatLng(37.7749, -122.4194); // San Francisco
//   final Map<String, Marker> _userMarkers = {}; // Store markers by userId
//   final Set<Polyline> _polylines = {}; // Holds the polylines for routes
//   LatLng? _destinationPosition; // Holds the destination position
//   LatLng? _myPosition; // Holds the user's current position
//   WebSocketChannel? _channel; // Nullable to handle disconnection cases
//   late Timer _timer;
//   String googleApiKey =
//       'Your API KEY" // Replace with your Google API key

//   // Track address box data for each user marker
//   final Map<String, Map<String, dynamic>> _addressBoxData = {};

//   // Add a stream to listen to map movements
//   final StreamController<LatLng> _mapMovementStream =
//       StreamController<LatLng>.broadcast();

//   @override
//   void initState() {
//     super.initState();
//     _startTracking(); // Start tracking on widget creation
//     _loadDestinationFromPreferences(); // Load the destination from shared preferences
//   }

//   // Fetch token from shared preferences
//   Future<String?> _getToken() async {
//     Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
//     return sessionData?['token'];
//   }

//   // Fetch destination location from SharedPreferences and display it on the map
//   Future<void> _loadDestinationFromPreferences() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? locationName = prefs.getString('destinationLocationName');
//     String? latitude = prefs.getString('destinationLatitude');
//     String? longitude = prefs.getString('destinationLongitude');

//     if (locationName != null && latitude != null && longitude != null) {
//       _destinationPosition =
//           LatLng(double.parse(latitude), double.parse(longitude));
//       setState(() {
//         // Add destination marker to _userMarkers to ensure it's always visible
//         _userMarkers['destination'] = Marker(
//           markerId: MarkerId('destination'),
//           position: _destinationPosition!,
//           icon:
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
//           zIndex: 2.0, // Ensure destination marker is above polyline
//         );
//       });
//     }
//   }

//   // Connect to WebSocket and send location updates periodically (every 5 seconds)
//   Future<void> _connectWebSocket() async {
//     String? token = await _getToken();
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Authentication token not found!')),
//       );
//       return;
//     }

//     _channel = WebSocketChannel.connect(
//       Uri.parse(
//           'wss://locationalarm-v2-0-0.onrender.com/events/tracking?token=$token'),
//     );

//     _channel!.stream.listen(
//       (message) => _handleIncomingMessage(message),
//       onDone: () => print('WebSocket connection closed'),
//       onError: (error) => print('WebSocket error: $error'),
//     );

//     _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.best);
//       _myPosition = LatLng(position.latitude, position.longitude);

//       if (_channel != null && _channel!.sink != null) {
//         try {
//           Map<String, dynamic> message = {
//             'groupId': widget.eventId,
//             'userId': widget.email,
//             'username': widget.name,
//             'latitude': _myPosition!.latitude.toString(),
//             'longitude': _myPosition!.longitude.toString(),
//           };

//           print(" ==================" + message.toString());
//           _channel!.sink.add(jsonEncode(message));
//         } catch (e) {
//           print('Error sending data: $e');
//         }
//       }

//       _drawRouteUsingDirectionsAPI(
//         _myPosition!,
//         _destinationPosition!,
//         'my_path',
//         Colors.green,
//         showEstimatedTime: true,
//         isMyPosition: true,
//       );
//     });
//   }

//   // Draw the route using the Google Directions API
//   Future<void> _drawRouteUsingDirectionsAPI(
//       LatLng start, LatLng end, String polylineId, Color color,
//       {bool showEstimatedTime = false,
//       bool isMyPosition = false,
//       String? userId}) async {
//     if (start != null && end != null) {
//       String url = 'https://maps.googleapis.com/maps/api/directions/json'
//           '?origin=${start.latitude},${start.longitude}'
//           '&destination=${end.latitude},${end.longitude}'
//           '&key=$googleApiKey';

//       var response = await http.get(Uri.parse(url));
//       Map<String, dynamic> data = jsonDecode(response.body);

//       if (data['status'] == 'OK') {
//         List<dynamic> routes = data['routes'];
//         if (routes.isNotEmpty) {
//           String polylinePoints = routes[0]['overview_polyline']['points'];
//           List<LatLng> polylineCoordinates = _decodePolyline(polylinePoints);

//           setState(() {
//             _polylines.removeWhere(
//                 (polyline) => polyline.polylineId == PolylineId(polylineId));
//             _polylines.add(
//               Polyline(
//                 polylineId: PolylineId(polylineId),
//                 points: polylineCoordinates,
//                 color: color,
//                 width: 5,
//                 zIndex: 1,
//               ),
//             );
//           });

//           if (showEstimatedTime) {
//             String estimatedTime = routes[0]['legs'][0]['duration']['text'];
//             if (isMyPosition) {
//               _updateAddressBox(widget.email, start, estimatedTime);
//             } else if (userId != null) {
//               _updateAddressBox(userId, start, estimatedTime);
//             }
//           }
//         }
//       } else {
//         print('Error fetching route: ${data['status']}');
//       }
//     }
//   }

//   // Update the address box for a specific user marker
//   void _updateAddressBox(
//       String userId, LatLng position, String estimatedTime) async {
//     final String address = await _getAddressFromLatLng(position);
//     setState(() {
//       _addressBoxData[userId] = {
//         'position': position,
//         'address': address,
//         'driveTime': int.tryParse(estimatedTime.split(' ')[0]),
//       };
//     });
//   }

//   // Fetch address from latitude and longitude
//   Future<String> _getAddressFromLatLng(LatLng position) async {
//     final String url =
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey';
//     final response = await http.get(Uri.parse(url));
//     final data = jsonDecode(response.body);

//     if (data['status'] == 'OK') {
//       return data['results'][0]['formatted_address'];
//     } else {
//       return 'Unknown Address';
//     }
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> polyline = [];
//     int index = 0;
//     int len = encoded.length;
//     int lat = 0;
//     int lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;

//       polyline.add(LatLng(lat / 1E5, lng / 1E5));
//     }

//     return polyline;
//   }

//   Future<Offset?> _latLngToScreenCoordinates(LatLng latLng) async {
//     if (mapController == null) {
//       print("Map controller is null.");
//       return null;
//     }
//     try {
//       final ScreenCoordinate screenCoordinate =
//           await mapController!.getScreenCoordinate(latLng);
//       print(
//           "\\\\\\\\\\\\\\\\/////////////////////////Screen Coordinates for LatLng ($latLng): (${screenCoordinate.x}, ${screenCoordinate.y})");
//       return Offset(
//           screenCoordinate.x.toDouble(), screenCoordinate.y.toDouble());
//     } catch (e) {
//       print("Error converting LatLng to screen coordinates: $e");
//       return null;
//     }
//   }

//   // Handle incoming WebSocket message and update markers for users
//   void _handleIncomingMessage(String message) {
//     try {
//       Map<String, dynamic> coordinatesMap = jsonDecode(message);

//       coordinatesMap.forEach((userId, userDetails) {
//         String? latitude = userDetails['latitude']?.toString();
//         String? longitude = userDetails['longitude']?.toString();
//         String? username = userDetails['username']?.toString();

//         if (userId != widget.email &&
//             latitude != null &&
//             longitude != null &&
//             username != null) {
//           LatLng userPosition =
//               LatLng(double.parse(latitude), double.parse(longitude));

//           // Update or add the red marker for the user
//           setState(() {
//             _userMarkers[userId] = Marker(
//               markerId: MarkerId(userId),
//               position: userPosition,
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueRed),
//               zIndex: 3.0, // Ensure red markers are above polylines
//             );
//           });

//           if (_destinationPosition != null) {
//             _drawRouteUsingDirectionsAPI(userPosition, _destinationPosition!,
//                 'path_$userId', Colors.blue,
//                 showEstimatedTime: true, isMyPosition: false, userId: userId);
//           }
//         }
//       });

//       // Re-add the destination marker to ensure it's always rendered
//       if (_destinationPosition != null &&
//           !_userMarkers.containsKey('destination')) {
//         _userMarkers['destination'] = Marker(
//           markerId: MarkerId('destination'),
//           position: _destinationPosition!,
//           icon:
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
//           zIndex: 2.0, // Ensure destination marker is above polyline
//         );
//       }
//     } catch (e) {
//       print('Error processing WebSocket message: $e');
//     }
//   }

//   @override
//   void dispose() {
//     mapController.dispose();
//     if (_channel != null) {
//       _channel!.sink.close();
//     }
//     _mapMovementStream.close();
//     _timer.cancel();
//     super.dispose();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   void _startTracking() {
//     _connectWebSocket();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pixelRatio = MediaQuery.of(context).devicePixelRatio;
//     print("Device Pixel Ratio: $pixelRatio");

//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _initialPosition,
//               zoom: 12.0,
//             ),
//             markers: Set<Marker>.of(_userMarkers.values),
//             polylines: _polylines,
//             mapType: MapType.normal,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             onCameraMove: (CameraPosition position) {
//               // Emit the new camera position to the stream
//               _mapMovementStream.add(position.target);
//             },
//           ),
//           // Add address boxes for each user marker
//           ..._addressBoxData.entries.map((entry) {
//             final userId = entry.key;
//             final data = entry.value;
//             final position = data['position'] as LatLng;
//             final address = data['address'] as String;
//             final driveTime = data['driveTime'] as int?;

//             return StreamBuilder<LatLng>(
//               stream: _mapMovementStream.stream,
//               builder: (context, snapshot) {
//                 return FutureBuilder<Offset?>(
//                   future: _latLngToScreenCoordinates(position),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Container(); // Return an empty container while waiting
//                     }
//                     if (snapshot.hasError) {
//                       return Container();
//                     }
//                     if (snapshot.hasData && snapshot.data != null) {
//                       final offset = snapshot.data!;
//                       final left =
//                           offset.dx / pixelRatio - 105; // Center horizontally
//                       final top = offset.dy / pixelRatio -
//                           120; // Position above the marker

//                       return Positioned(
//                         left: left,
//                         top: top,
//                         child: AddressBox(
//                           title: "Yash",
//                           driveTime: driveTime,
//                           distance: 23,
//                         ),
//                       );
//                     } else {
//                       return Container(); // Return an empty container if no data
//                     }
//                   },
//                 );
//               },
//             );
//           }).toList(),
//           Positioned(
//             bottom: 20,
//             right: 60,
//             child: FloatingActionButton(
//               onPressed: _addEvent,
//               backgroundColor: Colors.black,
//               child: const Icon(Icons.more_vert_rounded, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addEvent() {
//     Navigator.pushNamed(context, '/groupEvent');
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../backgroundService/LocationSharingServiceProvider.dart';
import '../../../../core/preferences/user_preferences.dart';
import '../Track/widgets/address_box.dart';

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
  String googleApiKey = 'Your API KEY';
  // Replace with your Google API key
  bool _isBackgroundLocationSharingActive = false;

  // Track address box data for each user marker
  final Map<String, Map<String, dynamic>> _addressBoxData = {};

  // Add a stream to listen to map movements
  final StreamController<LatLng> _mapMovementStream =
      StreamController<LatLng>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkBackgroundServiceStatus();
    _startTracking(); // Start tracking on widget creation
    _loadDestinationFromPreferences(); // Load the destination from shared preferences
  }

  // Check if the background service is running
  Future<void> _checkBackgroundServiceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBackgroundLocationSharingActive =
          prefs.getBool('background_location_active') ?? false;
    });
  }

  // Toggle background location sharing
  Future<void> _toggleBackgroundLocationSharing() async {
    final serviceProvider =
        Provider.of<LocationSharingServiceProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isBackgroundLocationSharingActive = !_isBackgroundLocationSharingActive;
    });

    // Save the status to shared preferences
    await prefs.setBool(
        'background_location_active', _isBackgroundLocationSharingActive);

    if (_isBackgroundLocationSharingActive) {
      // Save current event details for background service to use
      await prefs.setString('active_event_id', widget.eventId);
      await prefs.setString('active_user_name', widget.name);
      await prefs.setString('active_user_email', widget.email);

      // Start the background service
      await serviceProvider.startForegroundService();
    } else {
      // Stop the background service
      await serviceProvider.stopForegroundService();
    }
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
          markerId: const MarkerId('destination'),
          position: _destinationPosition!,
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
        const SnackBar(content: Text('Authentication token not found!')),
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

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
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

          print(" ==================" + message.toString());
          _channel!.sink.add(jsonEncode(message));
        } catch (e) {
          print('Error sending data: $e');
        }
      }

      if (_destinationPosition != null) {
        _drawRouteUsingDirectionsAPI(
          _myPosition!,
          _destinationPosition!,
          'my_path',
          Colors.green,
          showEstimatedTime: true,
          isMyPosition: true,
        );
      }
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
              _updateAddressBox(widget.email, start, estimatedTime);
            } else if (userId != null) {
              _updateAddressBox(userId, start, estimatedTime);
            }
          }
        }
      } else {
        print('Error fetching route: ${data['status']}');
      }
    }
  }

  // Update the address box for a specific user marker
  void _updateAddressBox(
      String userId, LatLng position, String estimatedTime) async {
    final String address = await _getAddressFromLatLng(position);
    setState(() {
      _addressBoxData[userId] = {
        'position': position,
        'address': address,
        'driveTime': int.tryParse(estimatedTime.split(' ')[0]),
      };
    });
  }

  // Fetch address from latitude and longitude
  Future<String> _getAddressFromLatLng(LatLng position) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      return data['results'][0]['formatted_address'];
    } else {
      return 'Unknown Address';
    }
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

  Future<Offset?> _latLngToScreenCoordinates(LatLng latLng) async {
    if (mapController == null) {
      print("Map controller is null.");
      return null;
    }
    try {
      final ScreenCoordinate screenCoordinate =
          await mapController.getScreenCoordinate(latLng);
      print(
          "\\\\\\\\\\\\\\\\/////////////////////////Screen Coordinates for LatLng ($latLng): (${screenCoordinate.x}, ${screenCoordinate.y})");
      return Offset(
          screenCoordinate.x.toDouble(), screenCoordinate.y.toDouble());
    } catch (e) {
      print("Error converting LatLng to screen coordinates: $e");
      return null;
    }
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
          markerId: const MarkerId('destination'),
          position: _destinationPosition!,
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
    _mapMovementStream.close();
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
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    print("Device Pixel Ratio: $pixelRatio");

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12.0,
            ),
            markers: Set<Marker>.of(_userMarkers.values),
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: (CameraPosition position) {
              // Emit the new camera position to the stream
              _mapMovementStream.add(position.target);
            },
          ),

          // Location Sharing Button - Top Left Corner
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _toggleBackgroundLocationSharing,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _isBackgroundLocationSharingActive
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Location Sharing",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Add address boxes for each user marker
          ..._addressBoxData.entries.map((entry) {
            final userId = entry.key;
            final data = entry.value;
            final position = data['position'] as LatLng;
            final address = data['address'] as String;
            final driveTime = data['driveTime'] as int?;

            return StreamBuilder<LatLng>(
              stream: _mapMovementStream.stream,
              builder: (context, snapshot) {
                return FutureBuilder<Offset?>(
                  future: _latLngToScreenCoordinates(position),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(); // Return an empty container while waiting
                    }
                    if (snapshot.hasError) {
                      return Container();
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final offset = snapshot.data!;
                      final left =
                          offset.dx / pixelRatio - 105; // Center horizontally
                      final top = offset.dy / pixelRatio -
                          120; // Position above the marker

                      return Positioned(
                        left: left,
                        top: top,
                        child: AddressBox(
                          title: "Yash",
                          driveTime: driveTime,
                          distance: 23,
                        ),
                      );
                    } else {
                      return Container(); // Return an empty container if no data
                    }
                  },
                );
              },
            );
          }).toList(),

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
