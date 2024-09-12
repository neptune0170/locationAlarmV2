import 'dart:math'; // Import for using math functions like min
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../data/data_providers/location_api_provider.dart';

class SetDestinationScreen extends StatefulWidget {
  @override
  _SetDestinationScreenState createState() => _SetDestinationScreenState();
}

class _SetDestinationScreenState extends State<SetDestinationScreen> {
  LatLng? _selectedPosition;
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedPosition = position.target;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      LocationApiProvider locationApiProvider = LocationApiProvider();
      final results = await locationApiProvider.getSuggestions(query);

      setState(() {
        _suggestions = results.where((result) {
          final mainText = result['structured_formatting']?['main_text'];
          final secondaryText =
              result['structured_formatting']?['secondary_text'];
          final placeId = result['place_id'];
          return mainText != null &&
              mainText.isNotEmpty &&
              secondaryText != null &&
              secondaryText.isNotEmpty &&
              placeId != null &&
              placeId.isNotEmpty;
        }).toList();
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _selectSuggestion(String placeId) async {
    LocationApiProvider locationApiProvider = LocationApiProvider();
    LatLng? selectedLatLng =
        await locationApiProvider.getLatLngFromPlaceId(placeId);

    if (selectedLatLng != null) {
      setState(() {
        _selectedPosition = selectedLatLng;
        mapController.animateCamera(CameraUpdate.newLatLng(selectedLatLng));

        // Update the search field with the selected suggestion
        final selectedSuggestion = _suggestions.firstWhere(
            (suggestion) => suggestion['place_id'] == placeId,
            orElse: () => null);

        if (selectedSuggestion != null) {
          _searchController.text =
              selectedSuggestion['structured_formatting']['main_text'] ?? '';
        }

        _suggestions = [];
      });
    }
  }

  double _calculateDistance(LatLng latLng) {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          latLng.latitude,
          latLng.longitude,
        ) /
        1000; // Convert to kilometers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps widget
          _selectedPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition!,
                    zoom: 14.0,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                ),
          // Draggable pin icon
          Align(
            alignment: Alignment.center, // Pin placed in the center
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 35.0), // Adjust padding if necessary
              child: Icon(Icons.location_pin, size: 50, color: Colors.red),
            ),
          ),
          // Search suggestions box behind the white box
          Positioned(
            top: 170, // Adjusted top to make it behind white box
            left: 20,
            right: 20,
            child: _suggestions.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: min(
                          3, _suggestions.length), // Only show up to 3 items
                      separatorBuilder: (context, index) => Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                        indent: 65, // To indent the divider for spacing
                        endIndent: 10, // Adjust spacing from the right
                      ),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        final placeId = suggestion['place_id'] ?? '';
                        final mainText = suggestion['structured_formatting']
                                ?['main_text'] ??
                            '';
                        final secondaryText =
                            suggestion['structured_formatting']
                                    ?['secondary_text'] ??
                                '';

                        LatLng suggestionLatLng;
                        if (suggestion['geometry'] != null &&
                            suggestion['geometry']['location'] != null) {
                          suggestionLatLng = LatLng(
                            suggestion['geometry']['location']['lat'],
                            suggestion['geometry']['location']['lng'],
                          );
                        } else {
                          suggestionLatLng =
                              LatLng(0.0, 0.0); // Default to (0.0, 0.0)
                        }

                        final distance = _calculateDistance(suggestionLatLng);

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16), // Reduced vertical padding
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                radius: 15,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              if (distance != null)
                                Text(
                                  '${distance.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            mainText,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            secondaryText,
                            maxLines: 1, // Limit secondaryText to one line
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis for overflow
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: Icon(Icons.arrow_outward_rounded),
                          ),
                          onTap: () {
                            _selectSuggestion(placeId);
                          },
                        );
                      },
                    ),
                  )
                : Container(),
          ),
          // White box containing search bar and header on top
          Positioned(
            top: 50, // Positioned above the search suggestions
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(15), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding:
                  EdgeInsets.all(15), // Padding inside the white background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Back button
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Set your destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // Subtitle text
                  Text(
                    'Drag map to move pin',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Search bar container
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for search bar
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Map Icon
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/maps.png', // Replace with your map icon image
                            width: 24,
                            height: 24,
                          ),
                        ),
                        SizedBox(width: 10),
                        // Search input field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _fetchSuggestions,
                            decoration: InputDecoration(
                              hintText: 'Search here',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // Clear button for search
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _suggestions = [];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Select Button with half width
          Positioned(
            bottom: 30, // Adjusted padding for the bottom button
            left: MediaQuery.of(context).size.width *
                0.25, // Centering the half-width button
            right: MediaQuery.of(context).size.width *
                0.25, // Centering the half-width button
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedPosition);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(50), // Button with rounded corners
                ),
              ),
              child: Text(
                'Select',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
