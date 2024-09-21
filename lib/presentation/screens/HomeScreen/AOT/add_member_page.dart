import 'package:flutter/material.dart';

import '../../../../data/data_providers/aot_api_provider.dart'; // Import your API provider

class AddMemberPage extends StatefulWidget {
  final int eventId; // Ensure eventId is passed

  const AddMemberPage({super.key, required this.eventId});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isAddingMember = false; // Track loading state
  String _buttonText = '+ Add Member'; // Default button text
  final AotApiProvider _apiProvider = AotApiProvider(); // API provider instance

  Future<void> _addMember() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showDialog('Error', 'Please enter a valid email.');
      return;
    }

    // Use widget.eventId to make the API call
    List<String> emails = [email];

    setState(() {
      _isAddingMember = true; // Show loading indicator
    });

    // Call the addAttendee API
    Map<String, dynamic> result = await _apiProvider.addAttendee(
      eventId: widget.eventId,
      emails: emails,
    );

    setState(() {
      _isAddingMember = false; // Hide loading indicator
    });

    // Check the result and update the UI accordingly
    if (result['statusCode'] == 200) {
      setState(() {
        _buttonText = 'Member Added!';
        _emailController.clear(); // Clear the input field
      });

      // Revert button text after a delay
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _buttonText = '+ Add Member';
        });
      });
    } else {
      // Display an error message if the API call fails
      _showDialog('Error', result['message'] ?? 'Failed to add member.');
    }
  }

  // Method to show error dialogs
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with background image and title
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
                  icon: Icon(Icons.arrow_back, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 100),
                child: Text(
                  'Add Members',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Add Member details section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seamlessly add members to ensure everyone reaches the destination on time, together.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Add Member\'s email',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),

          Divider(
            height: 0.0,
            thickness: 0.5,
            color: Colors.grey,
          ),

          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
            child: ElevatedButton(
              onPressed: _isAddingMember
                  ? null
                  : _addMember, // Disable the button during loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 60),
              ),
              child: Text(
                _buttonText,
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
