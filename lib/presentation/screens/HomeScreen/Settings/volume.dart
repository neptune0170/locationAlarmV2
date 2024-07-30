import 'package:flutter/material.dart';

import '../../../widgets/custom_switch.dart';

class Volume extends StatefulWidget {
  const Volume({super.key});

  @override
  State<Volume> createState() => _VolumeState();
}

class _VolumeState extends State<Volume> {
  bool speakersEnabled = true;
  bool earphonesEnabled = false;
  double volume = 0.5;

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
                  'Volume',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
              child: ListView(
                children: [
                  Text(
                    'Ringtones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Select a ringtone that will play when the alarm goes off.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'The Air',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Icon(Icons.volume_up_outlined),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  ListTile(
                    title: Text(
                      'The Fire',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Icon(Icons.volume_up_outlined),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  ListTile(
                    title: Text(
                      'The Water',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Icon(Icons.volume_up_outlined),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  ListTile(
                    title: Text(
                      'The Earth',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Icon(Icons.volume_up_outlined),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sound Output',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/Speaker.png',
                                width: 40, height: 40),
                            SizedBox(width: 8),
                            Text('Speakers',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16)),
                          ],
                        ),
                        CustomSwitch(
                          value: speakersEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              speakersEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/Earphone.png',
                                width: 40, height: 40),
                            SizedBox(width: 8),
                            Text('Earphone',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16)),
                          ],
                        ),
                        CustomSwitch(
                          value: earphonesEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              earphonesEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Volume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Slider(
                    value: volume,
                    onChanged: (double value) {
                      setState(() {
                        volume = value;
                      });
                    },
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label: (volume * 100).round().toString(),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 0.0,
            thickness: 0.5,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
