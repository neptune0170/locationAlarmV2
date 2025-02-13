import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/set_destination_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../../data/data_providers/aot_api_provider.dart';
import '../../../../data/data_providers/location_api_provider.dart'; // Updated provider import
import '../../../widgets/custom_switch.dart'; // Assuming this is your custom AOT switch

class AotPage extends StatefulWidget {
  const AotPage({super.key});

  @override
  State<AotPage> createState() => _AotPageState();
}

class _AotPageState extends State<AotPage> {
  late GoogleMapController mapController;
  final LatLng _initialPosition =
      const LatLng(23.0225, 72.5714); // Initial location

  bool _isEventBoxVisible = false;
  bool _isAotScoreEnabled = false;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDateTime;
  final FocusNode _locationFocusNode = FocusNode();

  bool _areAllFieldsFilled = false;
  List<Map<String, dynamic>> _suggestions = []; // Store placeName, lat, lng
  String? _selectedLocation;
  double? _selectedLat;
  double? _selectedLng;

  late LayerLink _layerLink; // For positioning the overlay
  OverlayEntry? _overlayEntry; // Overlay to show suggestions

  @override
  void initState() {
    super.initState();
    _layerLink = LayerLink(); // Initialize LayerLink for positioning overlay

    // Validate fields on text change
    _eventNameController.addListener(_validateFields);
    _locationController.addListener(() {
      _fetchSuggestions(_locationController.text);
      _validateFields(); // Validate when location field changes
    });

    _locationFocusNode.addListener(() {
      if (_locationFocusNode.hasFocus && _locationController.text.isNotEmpty) {
        _showSuggestionsOverlay();
      } else {
        _removeSuggestionsOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    _eventNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Updated validation method to check for non-empty location
  void _validateFields() {
    setState(() {
      // Ensure all fields are filled and the selected location is not empty
      _areAllFieldsFilled = _eventNameController.text.isNotEmpty &&
          _selectedLocation != null &&
          _selectedLocation!.isNotEmpty &&
          _selectedDateTime != null;
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _removeSuggestionsOverlay();
      });
      return;
    }

    try {
      final locationApiProvider =
          Provider.of<LocationApiProvider>(context, listen: false);
      final results =
          await locationApiProvider.getSuggestionsWithCoordinates(query);

      setState(() {
        _suggestions = results;
        if (_locationFocusNode.hasFocus) {
          _showSuggestionsOverlay();
        }
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _showSuggestionsOverlay() {
    _removeSuggestionsOverlay(); // Remove any existing overlay

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width:
            MediaQuery.of(context).size.width - 70, // Adjust for right padding
        left: 10, // Left padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 50), // Position below the location text field
          child: Material(
            color: Colors.white, // White background
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => Divider(
                height: 0.5,
                color: Colors.grey,
              ),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                final description = suggestion['placeName'];

                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.black),
                  title: Text(
                    suggestion['placeName'] ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${suggestion['lat']}, ${suggestion['lng']}', // Show the coordinates for debugging
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: Icon(Icons.arrow_outward_rounded),
                  ),
                  onTap: () => _onSuggestionTap(suggestion), // Modify this part
                );
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeSuggestionsOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  // Toggle event box visibility
  void _toggleEventBoxVisibility() {
    setState(() {
      _isEventBoxVisible = !_isEventBoxVisible;
    });
  }

  // Toggle AOT score functionality
  void _toggleAotScore(bool value) {
    setState(() {
      _isAotScoreEnabled = value;
    });
  }

  Future<void> _selectTime() async {
    DateTime now = DateTime.now();

    // Time picker for selecting time for today
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return; // User canceled time selection

    // Combine today's date with the selected time
    final DateTime finalDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (finalDateTime.isBefore(now)) {
      // If the selected time is in the past, show an error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Invalid Time"),
            content: Text("Please select a time in the future."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _selectedDateTime = finalDateTime;
    });

    // Automatically format with today's date and the selected time
    final formattedDateTime =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(finalDateTime);
    print('Selected DateTime: $formattedDateTime');

    _validateFields(); // Revalidate fields after selecting time
  }

  // Add event using AotApiProvider and navigate to /groupEvent if successful
  Future<void> _addEvent() async {
    // Ensure both lat and lng are selected by the user (via search or map)
    if (_areAllFieldsFilled && _selectedLat != null && _selectedLng != null) {
      final aotApiProvider = AotApiProvider();

      final success = await aotApiProvider.addEvent(
        eventName: _eventNameController.text,
        locationName: _selectedLocation!,
        lat: _selectedLat!, // Use the selected lat
        lng: _selectedLng!, // Use the selected lng
        time: DateFormat('dd/MM/yyyy HH:mm:ss').format(_selectedDateTime!),
        aotEnable: _isAotScoreEnabled,
      );

      if (success) {
        Navigator.pushNamed(context, '/groupEvent');
      } else {
        // Handle failure (e.g., show a dialog or snackbar)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add event. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Show error if lat/lng not selected
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Missing Location'),
          content: Text('Please select a valid location.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Ensure that when a user selects a suggestion, the corresponding lat/lng are stored
  void _onSuggestionTap(Map<String, dynamic> suggestion) {
    setState(() {
      _locationController.text = suggestion['placeName'] ?? '';
      _selectedLocation = suggestion['placeName'];
      _selectedLat = suggestion['lat'];
      _selectedLng = suggestion['lng'];
    });
    _locationFocusNode.unfocus();
    _validateFields(); // Revalidate fields after selecting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GoogleMap widget (assuming it exists in your current code)
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            // myLocationButtonEnabled: true,
          ),
          if (_isEventBoxVisible)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Create An Event',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF737373), // Grey color
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _eventNameController,
                      style: TextStyle(
                        color: Colors.black, // Text color when typing
                      ),
                      decoration: InputDecoration(
                        labelText: 'Event Name',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF737373), // Grey color
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: Color(0xFF737373)), // Grey divider
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: TextField(
                        controller: _locationController,
                        focusNode: _locationFocusNode,
                        style: TextStyle(
                          color: Colors.black, // Text color when typing
                        ),
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF737373), // Grey color
                          ),
                          border: InputBorder.none,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ensures the row takes up minimal space
                            children: [
                              // Clear button
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _locationController.clear();
                                  setState(() {
                                    _selectedLocation =
                                        ""; // Clear selected location
                                    _selectedLat = null; // Clear latitude
                                    _selectedLng = null; // Clear longitude
                                    _suggestions = []; // Clear suggestions
                                    _removeSuggestionsOverlay();
                                    _validateFields(); // Revalidate after clearing
                                  });
                                },
                              ),
                              // Map icon (loading from assets)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Image.asset(
                                      'assets/images/maps.png'), // Replace with your image path
                                  onPressed: () async {
                                    // Open map screen and get the selected location
                                    LatLng? selectedLocation =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SetDestinationScreen(),
                                      ),
                                    );

                                    // If a location is selected, update the lat/lng values
                                    if (selectedLocation != null) {
                                      setState(() {
                                        _locationController.text =
                                            '${selectedLocation.latitude}, ${selectedLocation.longitude}';
                                        _selectedLocation =
                                            '${selectedLocation.latitude}, ${selectedLocation.longitude}'; // Set selected location
                                        _selectedLat = selectedLocation
                                            .latitude; // Set latitude
                                        _selectedLng = selectedLocation
                                            .longitude; // Set longitude
                                      });
                                      _validateFields(); // Revalidate after selecting location
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(color: Color(0xFF737373)), // Grey divider
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _selectTime,
                      child: Text(
                        _selectedDateTime == null
                            ? 'Select Time'
                            : DateFormat('dd/MM/yyyy HH:mm:ss')
                                .format(_selectedDateTime!),
                      ),
                    ),
                    Divider(color: Color(0xFF737373)), // Grey divider
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable AOT Score',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF737373), // Grey color
                          ),
                        ),
                        CustomSwitch(
                          value: _isAotScoreEnabled,
                          onChanged: _toggleAotScore,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleEventBoxVisibility,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF737373), // Grey text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                  ),
                  child: const Text(
                    'Create An Event',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF737373), // Grey text color
                    ),
                  ),
                ),
              ],
            ),
          ),
          // FloatingActionButton for arrow, only shows when all fields are filled
          if (_areAllFieldsFilled)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _addEvent, // Call _addEvent method here
                backgroundColor: Color(0xFF737373), // Grey color
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
