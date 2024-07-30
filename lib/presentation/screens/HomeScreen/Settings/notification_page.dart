import 'package:flutter/material.dart';

import '../../../widgets/custom_switch.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool pushNotificationEnabled = true;
  bool wholeScreenNotificationEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/BubblesBackground.JPG'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 50.0,
                left: 5.0,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 100),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                SizedBox(
                  height: 30,
                ),
                Text(
                  'System notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Configure the notifications for entry and exit, color and more.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset('assets/images/PushNotification.png',
                        width: 40, height: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Push',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ),
                    CustomSwitch(
                      value: pushNotificationEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          pushNotificationEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 16,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Row(
                  children: [
                    Image.asset('assets/images/WholeScreenNotification.png',
                        width: 40, height: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Whole Screen',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ),
                    CustomSwitch(
                      value: wholeScreenNotificationEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          wholeScreenNotificationEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 16,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                // Handle save action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 60),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 17,
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
