import 'package:flutter/material.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Alarm/alarm_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/GeoFence/geo_fence_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Schedule/schedule_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/track_page.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/settings_page.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Position? _currentPosition;

  static const List<Widget> _widgetOptions = <Widget>[
    TrackPage(),
    SchedulePage(),
    AlarmPage(),
    GeoFencePage(),
    SettingsPage()
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      // Location services are not enabled, don't continue
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, don't continue
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // Get the current location
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Current location: $_currentPosition");
    } catch (e) {
      print("Error getting current location: $e");
    }
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
            _buildNavItem(Icons.list_alt_rounded, 'Alarm', 2),
            _buildNavItem(Icons.share_location_rounded, 'GeoFence', 3),
            _buildNavItem(Icons.settings_outlined, 'Settings', 4),
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
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
