import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/utils/track_utils.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/widgets/add_location_container.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/widgets/address_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/data_providers/address_api_provider.dart';
import '../../../state_management/providers/circle_style_provider.dart';
import '../../../state_management/providers/radius_provider.dart';
import '../../../state_management/providers/location_provider.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TrackUtils _trackUtils = TrackUtils();
  final AddressApiProvider _addressApiProvider =
      AddressApiProvider(); // Initialize AddressApiProvider

  List<dynamic> _suggestions = [];
  Position? _currentPosition;
  Marker? _selectedMarker;
  LatLng? _selectedPosition;
  String? _selectedTitle;
  double? _selectedDistance;
  int? _selectedDriveTime;
  bool _showSuggestions = false;
  bool _isAddingLocation = false;
  bool _isDisposed = false; // Flag to check if the widget is disposed

  Set<Marker> _markers = {}; // Store all markers
  Set<Circle> _circles = {}; // Store all circles

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _getCurrentLocation();
    _fetchAndDisplayLocations(); // Fetch and display locations on page load

    // Listen to RadiusProvider changes
    Provider.of<RadiusProvider>(context, listen: false).addListener(() {
      if (_selectedPosition != null) {
        _updateMap(_selectedPosition!, _selectedTitle ?? '');
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true when the widget is disposed
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showSuggestions = _searchController.text.isNotEmpty;
    });
    if (_searchController.text.isNotEmpty) {
      _getSuggestions(_searchController.text);
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _onSearchFocusChanged() {
    setState(() {
      _showSuggestions =
          _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
    });
  }

  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   _currentPosition = await Geolocator.getCurrentPosition();

  //   if (!_isDisposed) {
  //     // Check if the widget is disposed before calling setState
  //     setState(() {});
  //   }

  //   if (_currentPosition != null && !_isDisposed) {
  //     LatLng currentLatLng =
  //         LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

  //     // Add a marker for the current location
  //     setState(() {
  //       _markers.add(
  //         Marker(
  //           markerId: MarkerId('current-location'),
  //           position: currentLatLng,
  //           infoWindow: InfoWindow(title: 'Current Location'),
  //           icon:
  //               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         ),
  //       );
  //     });

  //     // Animate the camera to the current location
  //     mapController.animateCamera(
  //       CameraUpdate.newLatLngZoom(currentLatLng, 14),
  //     );
  //   }
  // }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();

    if (!_isDisposed) {
      setState(() {});
    }

    if (_currentPosition != null && !_isDisposed) {
      LatLng currentLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      // Animate the camera to the current location
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 14),
      );
    }
  }

  Future<void> _fetchAndDisplayLocations() async {
    final locations = await _addressApiProvider.getAddresses();
    if (locations != null && !_isDisposed) {
      Set<Marker> markers = locations.map((location) {
        return Marker(
          markerId: MarkerId(location['id'].toString()),
          position: LatLng(location['latitude'], location['longitude']),
          infoWindow: InfoWindow(
            title: location['alarmName'],
            snippet: location['note'],
          ),
        );
      }).toSet();

      Set<Circle> circles = locations.map((location) {
        bool isOnEntry = location['alarmRings'] == 1;
        return Circle(
          circleId: CircleId(location['id'].toString()),
          center: LatLng(location['latitude'], location['longitude']),
          radius: location['radius'] * 1000, // Radius in meters
          fillColor: isOnEntry
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5),
          strokeColor: isOnEntry ? Colors.black : Colors.white,
          strokeWidth: 2,
        );
      }).toSet();

      setState(() {
        _markers = _markers.union(markers);
        _circles = circles;
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    final suggestions = await _trackUtils.getSuggestions(query);
    if (!_isDisposed) {
      // Ensure widget is not disposed before calling setState
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  void _updateMap(LatLng position, String title) {
    if (_isDisposed) return; // Prevent updates if the widget is disposed
    mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
    setState(() {
      _selectedPosition = position;
      _selectedTitle = title;
      _selectedMarker = Marker(
        markerId: MarkerId('selected-location'),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      double radius =
          Provider.of<RadiusProvider>(context, listen: false).radius;
      bool isOnEntry =
          Provider.of<CircleStyleProvider>(context, listen: false).isOnEntry;

      _circles = {
        Circle(
          circleId: CircleId('selected-circle'),
          center: _selectedPosition!,
          radius: radius * 1000, // Use the provider's radius
          fillColor: isOnEntry
              ? Colors.black.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
          strokeColor: isOnEntry ? Colors.white : Colors.black,
          strokeWidth: 2,
        ),
      };

      _calculateDistanceAndTime();
      _showSuggestions = false;
    });

    Provider.of<LocationProvider>(context, listen: false)
      ..setLatitude(position.latitude)
      ..setLongitude(position.longitude);
  }

  Future<void> _calculateDistanceAndTime() async {
    if (_selectedPosition != null && _currentPosition != null && !_isDisposed) {
      final distance = _trackUtils.calculateDistance(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _selectedPosition!,
      );
      final driveTime = _trackUtils.calculateDriveTime(distance);
      setState(() {
        _selectedDistance = distance;
        _selectedDriveTime = driveTime;
      });
    }
  }

  Future<void> printAllCoordinates() async {
    print("------------------------------------------------------------------");
    try {
      // Retrieve shared preferences instance
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Retrieve the list of alarms from SharedPreferences
      List<String> alarmList = prefs.getStringList('alarms') ?? [];

      // Check if the list is empty
      if (alarmList.isEmpty) {
        print('No alarms found in SharedPreferences.');
        return;
      }

      // Iterate through each alarm and print its coordinates
      for (String alarmJson in alarmList) {
        Map<String, dynamic> alarm = jsonDecode(alarmJson);
        double latitude = alarm['latitude'];
        double longitude = alarm['longitude'];
        print('Alarm Location - Latitude: $latitude, Longitude: $longitude');
      }
    } catch (e) {
      print('Error while printing coordinates: $e');
    }
    print("------------------------------------------------------------------");
  }

  Future<void> _refreshCircles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmList = prefs.getStringList('alarms') ?? [];

    Set<Circle> updatedCircles = alarmList.map((alarmJson) {
      Map<String, dynamic> alarm = jsonDecode(alarmJson);
      return Circle(
        circleId: CircleId(alarm['alarm_name']),
        center: LatLng(alarm['latitude'], alarm['longitude']),
        radius: alarm['radius'] * 1000,
        fillColor: Colors.black.withOpacity(0.5),
        strokeColor: Colors.white,
        strokeWidth: 2,
      );
    }).toSet();

    setState(() {
      _circles = updatedCircles;
    });
  }

  void _toggleAddLocation() {
    if (_isDisposed) return;
    printAllCoordinates();
    setState(() {
      _isAddingLocation = !_isAddingLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241, 244, 249, 1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                color: Colors.white,
                child: Consumer2<RadiusProvider, CircleStyleProvider>(
                  builder:
                      (context, radiusProvider, circleStyleProvider, child) {
                    // return GoogleMap(
                    //   onMapCreated: (controller) {
                    //     mapController = controller;
                    //   },
                    //   initialCameraPosition: CameraPosition(
                    //     target: _currentPosition != null
                    //         ? LatLng(_currentPosition!.latitude,
                    //             _currentPosition!.longitude)
                    //         : LatLng(0,
                    //             0), // Default to (0, 0) if location is not available yet
                    //     zoom: 14,
                    //   ),
                    //   markers: _markers.union(
                    //     _selectedMarker != null ? {_selectedMarker!} : {},
                    //   ), // Combine markers from database and selected marker
                    //   circles: _circles, // Display all circles on the map
                    //   onCameraMove: (CameraPosition position) {
                    //     if (_selectedPosition != null) {
                    //       setState(() {
                    //         // To force rebuild and reposition the address box
                    //       });
                    //     }
                    //   },
                    // );
                    return GoogleMap(
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude)
                            : LatLng(0,
                                0), // Default to (0, 0) if location is not available yet
                        zoom: 14,
                      ),
                      markers: _markers.union(
                        _selectedMarker != null ? {_selectedMarker!} : {},
                      ), // Combine markers from database and selected marker
                      circles: _circles, // Display all circles on the map
                      myLocationEnabled: true, // Enables the blue location dot
                      myLocationButtonEnabled:
                          true, // Enables the default location button
                      onCameraMove: (CameraPosition position) {
                        if (_selectedPosition != null) {
                          setState(() {
                            // To force rebuild and reposition the address box
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          if (_selectedPosition != null)
            FutureBuilder<ScreenCoordinate>(
              future: mapController.getScreenCoordinate(_selectedPosition!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final screenPosition = snapshot.data!;
                  final pixelRatio = MediaQuery.of(context).devicePixelRatio;

                  return Positioned(
                    left: screenPosition.x / pixelRatio - 100,
                    top: screenPosition.y / pixelRatio - 120,
                    child: AddressBox(
                      title: _selectedTitle,
                      distance: _selectedDistance,
                      driveTime: _selectedDriveTime,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.asset(
                          'assets/images/maps.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _suggestions = [];
                                    _showSuggestions = false;
                                  });
                                },
                              ),
                            )
                          : null,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      setState(() {
                        _showSuggestions = true;
                      });
                    },
                  ),
                ),
                if (_showSuggestions && _suggestions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(left: 65, right: 10),
                        child: Divider(
                          height: .5,
                          thickness: .5,
                          color: Colors.grey,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        final placeId = suggestion['place_id'];

                        return FutureBuilder<LatLng?>(
                          future: _trackUtils.getLatLngFromPlaceId(placeId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final distance = _currentPosition != null
                                  ? _trackUtils.calculateDistance(
                                      LatLng(_currentPosition!.latitude,
                                          _currentPosition!.longitude),
                                      snapshot.data!,
                                    )
                                  : null;

                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[200],
                                      radius: 15,
                                      child: Icon(Icons.location_on,
                                          color: Colors.black, size: 20),
                                    ),
                                    SizedBox(height: 4),
                                    distance != null
                                        ? Text(
                                            distance > 1000
                                                ? ''
                                                : '${distance.toStringAsFixed(1)} km',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : SizedBox(
                                            height: 10,
                                          ),
                                  ],
                                ),
                                title: Text(
                                  suggestion['structured_formatting']
                                          ['main_text'] ??
                                      '',
                                  style: TextStyle(color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  suggestion['structured_formatting']
                                          ['secondary_text'] ??
                                      '',
                                  style: TextStyle(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(3.14159),
                                  child: Icon(Icons.arrow_outward_rounded),
                                ),
                                onTap: () {
                                  _updateMap(
                                    snapshot.data!,
                                    suggestion['structured_formatting']
                                            ['main_text'] ??
                                        '',
                                  );
                                  _searchController.text =
                                      suggestion['description'] ?? '';
                                  _searchFocusNode.unfocus();
                                  setState(() {
                                    _suggestions = [];
                                    _showSuggestions = false;
                                  });
                                },
                              );
                            } else {
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[200],
                                      radius: 15,
                                      child: Icon(Icons.location_on,
                                          color: Colors.black, size: 20),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '- km',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  suggestion['structured_formatting']
                                          ['main_text'] ??
                                      '',
                                  style: TextStyle(color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  suggestion['structured_formatting']
                                          ['secondary_text'] ??
                                      '',
                                  style: TextStyle(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(3.14159),
                                  child: Icon(Icons.arrow_outward_rounded),
                                ),
                                onTap: () {
                                  _searchController.text =
                                      suggestion['structured_formatting']
                                              ['main_text'] ??
                                          '';
                                  _searchFocusNode.unfocus();
                                  setState(() {
                                    _suggestions = [];
                                    _showSuggestions = false;
                                  });
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedPosition != null)
            Positioned(
              bottom: 20,
              left: (MediaQuery.of(context).size.width - 150) / 2,
              child: Container(
                width: 150,
                child: ElevatedButton(
                  onPressed: _toggleAddLocation,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 10,
                  ),
                  child: Text(
                    _isAddingLocation ? 'Cancel' : '+ Add location',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (_isAddingLocation)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AddLocationContainer(
                title: _selectedTitle,
                distance: _selectedDistance,
                driveTime: _selectedDriveTime,
                onSave: _toggleAddLocation,
              ),
            ),
        ],
      ),
    );
  }
}
