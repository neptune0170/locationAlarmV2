import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/aot_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/aot_tracking_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/GeoFence/geo_fence_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Schedule/schedule_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/track_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/settings_page.dart';

import '../../data/data_providers/auth_api_provider.dart'; // Assuming AuthApiProvider is in this path

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _eventId = 0; // Global variable for eventId
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchEventId(); // Fetch eventId when the app starts
  }

  // Fetch eventId from API and set it
  Future<void> _fetchEventId() async {
    try {
      var userDetails = await AuthApiProvider().getUserDetails();
      if (userDetails != null && userDetails.isNotEmpty) {
        setState(() {
          _eventId = userDetails[0]
              ['eventId']; // Assuming eventId is part of user details
        });
      }
    } catch (e) {
      print('Error fetching eventId: $e');
    }
  }

  // Get the current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

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
      print('Location permissions are permanently denied.');
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

  // Handle navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Conditionally return AOTPage or AotTrackingPage based on _eventId
  List<Widget> get _widgetOptions {
    return <Widget>[
      TrackPage(),
      SchedulePage(),
      _eventId == 0 ? AotPage() : AotTrackingPage(),
      GeoFencePage(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: Color.fromRGBO(241, 244, 249, 1),
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.add_location_outlined, 'Track', 0),
            _buildNavItem(Icons.schedule_outlined, 'Schedule', 1),
            _buildNavItem(Icons.list_alt_rounded, 'AOT', 2),
            _buildNavItem(Icons.share_location_rounded, 'GeoFence', 3),
            _buildNavItem(Icons.settings_outlined, 'Settings', 4),
          ],
        ),
      ),
    );
  }

  // Build each item in the navigation bar
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
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
