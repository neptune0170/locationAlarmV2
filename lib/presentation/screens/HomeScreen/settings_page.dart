import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added this for logout functionality

import '../../widgets/setting_item_with_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool batteryEnabled = false;
  bool pictureInPictureEnabled = false;

  Future<void> _logout() async {
    // Clear the saved credentials in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This will remove all the stored keys and values.

    // Navigate back to the login page and clear the navigation stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Header Section with Background Image and Title
          Container(
            height: MediaQuery.of(context).size.height * .2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BubblesBackground.JPG'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 100),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Settings Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 20),
              children: [
                // General Section
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    'General',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.person_add_alt,
                  text: 'Account information',
                  onPress: () {
                    Navigator.pushNamed(context, '/accountInformation');
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.volume_up_outlined,
                  text: 'Volume',
                  onPress: () {
                    Navigator.pushNamed(context, '/volume');
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.notification_add_outlined,
                  text: 'Notification',
                  onPress: () {
                    Navigator.pushNamed(context, '/notificationPage');
                  },
                ),
                // Uncomment these if needed
                // SettingsItemWithSwitch(
                //   icon: Icons.picture_in_picture_alt_rounded,
                //   text: 'Picture in Picture',
                //   switchValue: pictureInPictureEnabled,
                //   onSwitchChanged: (value) {
                //     setState(() {
                //       pictureInPictureEnabled = value;
                //     });
                //   },
                // ),
                // SettingsItemWithSwitch(
                //   icon: Icons.battery_saver_rounded,
                //   text: 'Battery',
                //   switchValue: batteryEnabled,
                //   onSwitchChanged: (value) {
                //     setState(() {
                //       batteryEnabled = value;
                //     });
                //   },
                // ),

                // Support Section
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.report_problem_outlined,
                  text: 'Report an Issue',
                  onPress: () {
                    Navigator.pushNamed(context, '/accountInformation');
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.help_outline_rounded,
                  text: 'FAQ',
                  onPress: () {
                    Navigator.pushNamed(context, '/accountInformation');
                  },
                ),

                // Logout Button
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _logout, // Call the logout function
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    required VoidCallback onPress,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          trailing: Icon(Icons.arrow_forward),
          onTap: onPress,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            height: 0.0,
            thickness: 0.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
