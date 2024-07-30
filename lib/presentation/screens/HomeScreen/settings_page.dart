import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/setting_item_with_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  bool batteryEnabled = false;
  bool pictureInPictureEnabled = false;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
              padding: const EdgeInsets.only(
                  left: 25, top: 100), // Adjust the padding as needed
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 20),
              children: [
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
                    }),
                _buildSettingsItem(
                    icon: Icons.dark_mode_outlined,
                    text: 'Appearance',
                    onPress: () {
                      Navigator.pushNamed(context, '/appearance');
                    }),
                _buildSettingsItem(
                    icon: Icons.volume_up_outlined,
                    text: 'Volume',
                    onPress: () {
                      Navigator.pushNamed(context, '/volume');
                    }),
                _buildSettingsItem(
                    icon: Icons.notification_add_outlined,
                    text: 'Notification',
                    onPress: () {
                      Navigator.pushNamed(context, '/notificationPage');
                    }),
                SettingsItemWithSwitch(
                  icon: Icons.picture_in_picture_alt_rounded,
                  text: 'Picture in Picture',
                  switchValue: pictureInPictureEnabled,
                  onSwitchChanged: (value) {
                    setState(() {
                      pictureInPictureEnabled = value;
                    });
                  },
                ),
                SettingsItemWithSwitch(
                  icon: Icons.battery_saver_rounded,
                  text: 'Battery',
                  switchValue: batteryEnabled,
                  onSwitchChanged: (value) {
                    setState(() {
                      batteryEnabled = value;
                    });
                  },
                ),

                // Support Section
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 16,
                  ),
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
                    }),
                _buildSettingsItem(
                    icon: Icons.help_outline_rounded,
                    text: 'FAQ',
                    onPress: () {
                      Navigator.pushNamed(context, '/accountInformation');
                    }),

                // Add other settings items similarly with Divider
                // Logout Button
                // Logout Button
                SizedBox(height: 20), // Add some space before the button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      // Add your logout functionality here
                    },
                    child: Container(
                      height: 60, // Button height
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0), // Transparent background
                        borderRadius:
                            BorderRadius.circular(40), // Fully rounded
                        border: Border.all(
                          color: Colors.black, // Border color
                          width: 2, // Border width
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
          padding: const EdgeInsets.only(right: 15, left: 15),
          child: Divider(
            height: 0.0,
            thickness: 0.5,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
