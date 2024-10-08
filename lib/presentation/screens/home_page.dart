import 'package:flutter/material.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/aot_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/aot_tracking_page.dart'; // Import AotTrackingPage
import 'package:locationalarm/presentation/screens/HomeScreen/GeoFence/geo_fence_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Schedule/schedule_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/track_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/settings_page.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/data_providers/auth_api_provider.dart'; // Import API provider

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Position? _currentPosition;
  List<Widget> _widgetOptions = [];
  bool isLoading = true; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializePages();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Current location: $_currentPosition");
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  // Initialize pages based on eventId from the user details
  Future<void> _initializePages() async {
    AuthApiProvider apiProvider = AuthApiProvider(); // Instantiate API provider
    final userDetails =
        await apiProvider.getUserDetails(); // Fetch user details
    final eventId = userDetails!['eventId'];
    final name = userDetails['fullName'];
    final email = userDetails['email'];
    print("Fetched values:");
    print("eventId: $eventId");
    print("name: $name");
    print("email: $email");
    setState(() {
      if (userDetails != null && userDetails['eventId'] != 0) {
        _widgetOptions = [
          TrackPage(),
          // SchedulePage(),
          AotTrackingPage(eventId.toString(), name,
              email), // Show AotTrackingPage if eventId != 0
          // GeoFencePage(),
          SettingsPage(),
        ];
      } else {
        _widgetOptions = [
          TrackPage(),
          // SchedulePage(),
          AotPage(), // Show AotPage if eventId == 0
          // GeoFencePage(),
          SettingsPage(),
        ];
      }
      isLoading = false; // Pages are initialized, hide the loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show a loader while fetching user details
          : Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
      bottomNavigationBar: isLoading
          ? SizedBox.shrink() // Hide navigation bar while loading
          : Container(
              color: Color.fromRGBO(241, 244, 249, 1),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.add_location_outlined, 'Track', 0),
                  // _buildNavItem(Icons.schedule_outlined, 'Schedule', 1),
                  _buildNavItem(Icons.list_alt_rounded, 'AOT', 1),
                  // _buildNavItem(Icons.share_location_rounded, 'GeoFence', 3),
                  _buildNavItem(Icons.settings_outlined, 'Settings', 2),
                ],
              ),
            ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Color.fromRGBO(183, 182, 182, 1)
                  : Colors.transparent,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Icon(
              icon,
              color: Color.fromRGBO(94, 94, 94, 1),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Color.fromRGBO(94, 94, 94, 1),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
