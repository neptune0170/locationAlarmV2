import 'package:flutter/material.dart';

class Appearance extends StatefulWidget {
  const Appearance({super.key});

  @override
  State<Appearance> createState() => _AppearanceState();
}

class _AppearanceState extends State<Appearance> {
  // Variable to keep track of the selected theme
  bool isLightThemeSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
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
                  'Appearance',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Application theme',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selecting a particular option will change the appearance (coloring) of the application according to your preferences.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              child: Image.asset(
                                'assets/images/LightMode.png',
                                width: 180,
                                height: 280,
                              ),
                              onTap: () {
                                setState(() {
                                  isLightThemeSelected = true;
                                });
                              },
                            ),
                            Text('Light'),
                            Radio(
                              value: true,
                              groupValue: isLightThemeSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  isLightThemeSelected = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => {
                                setState(() {
                                  isLightThemeSelected = false;
                                })
                              },
                              child: Image.asset(
                                'assets/images/DarkMode.png',
                                width: 180,
                                height: 280,
                              ),
                            ),
                            Text('Dark'),
                            Radio(
                              value: false,
                              groupValue: isLightThemeSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  isLightThemeSelected = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0, left: 0, bottom: 15),
            child: Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                // Handle save action
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 60),
              ),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
