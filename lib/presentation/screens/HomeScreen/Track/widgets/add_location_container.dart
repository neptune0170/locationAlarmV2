import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/providers/radius_provider.dart';
import '../../../../state_management/providers/circle_style_provider.dart'; // Import your provider

class AddLocationContainer extends StatefulWidget {
  final LatLng? position;
  final String? title;
  final double? distance;
  final int? driveTime;
  final VoidCallback onSave;

  const AddLocationContainer({
    Key? key,
    this.position,
    this.title,
    this.distance,
    this.driveTime,
    required this.onSave,
  }) : super(key: key);

  @override
  _AddLocationContainerState createState() => _AddLocationContainerState();
}

class _AddLocationContainerState extends State<AddLocationContainer> {
  bool _onEntry = true;
  double _radius = 1.0;
  final TextEditingController _alarmNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alarmNameController.text = widget.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and radius display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? 'Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.distance?.toStringAsFixed(1) ?? '0'} km, ${widget.driveTime ?? 0} mins Drive',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                // Radius display
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_radius.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Alarm Rings'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(
                      'On entry',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    value: true,
                    groupValue: _onEntry,
                    onChanged: (value) {
                      setState(() {
                        _onEntry = value!;
                      });
                      Provider.of<CircleStyleProvider>(context, listen: false)
                          .setOnEntry(value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(
                      'On Exit',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    value: false,
                    groupValue: _onEntry,
                    onChanged: (value) {
                      setState(() {
                        _onEntry = value!;
                      });
                      Provider.of<CircleStyleProvider>(context, listen: false)
                          .setOnEntry(!value!);
                    },
                  ),
                ),
              ],
            ),
            Text('Radius'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey,
                thumbColor: Colors.black,
                overlayColor: Colors.black.withOpacity(0.2),
              ),
              child: Slider(
                value: _radius,
                min: 0.0,
                max: 10.0,
                divisions: 100,
                label: '${_radius.toStringAsFixed(1)} km',
                onChanged: (value) {
                  setState(() {
                    _radius = value;
                    Provider.of<RadiusProvider>(context, listen: false)
                        .setRadius(_radius);
                  });
                },
              ),
            ),

            // Alarm Name TextField
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarm Name',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextField(
                  controller: _alarmNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.normal, // Changed to normal font weight
                  ),
                ),
              ],
            ),
            Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
            // Add Note TextField
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Note',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.normal, // Changed to normal font weight
                  ),
                ),
              ],
            ),
            Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            // Aligning the buttons to the right and adding spacing between them
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _onEntry = true;
                      _radius = 1.0;
                      _alarmNameController.clear();
                      _noteController.clear();
                      widget.onSave();
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 16), // Space between buttons
                ElevatedButton(
                  onPressed: widget.onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
