import 'package:flutter/material.dart';

class GroupEvent extends StatefulWidget {
  const GroupEvent({super.key});

  @override
  State<GroupEvent> createState() => _GroupEventState();
}

class _GroupEventState extends State<GroupEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with background image and event details
          Stack(
            children: [
              // Background Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/GroupTopBar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Event details and back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Friends Meetup',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Arrival: 13:00, Madhav Institute of Technology And Science\nOn 17th June',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Created by Yash Gupta • 8/06/2024',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Event Settings Section with settings icon and divider
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, top: 4.0, bottom: 0.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.settings, color: Colors.grey),
                  title: Text(
                    'Event Settings',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Add your event settings navigation or functionality here
                  },
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey, // Grey divider color
            thickness: 0.5, // Thickness of the divider
          ),

          // Member List with grey-bordered circles and custom add member image
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildAddMemberTile(),
                _buildMemberTileWithBorder(
                    'Aman Sharma', 'AOT Score - 93%', '', Colors.red),
                _buildMemberTileWithBorder(
                    'Ankur Samwad', 'AOT Score - 89%', '', Colors.yellow),
                _buildMemberTileWithBorder(
                    'Yash Gupta', 'AOT Score - 88%', 'Event Admin', Colors.blue,
                    isAdmin: true),
              ],
            ),
          ),

          // Delete Event Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                // Add delete event functionality
              },
              child: Center(
                child: Text(
                  'Delete Event',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build a member tile with a grey-bordered circle
  Widget _buildMemberTileWithBorder(
      String name, String score, String subtitle, Color color,
      {IconData? icon, bool isAdmin = false}) {
    return ListTile(
      leading: Container(
        // space for grey border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 4), // grey border
        ),
        child: CircleAvatar(
          radius: 24, // radius of the colored circle
          backgroundColor: color,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(score),
      trailing: isAdmin
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Event Admin',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : icon != null
              ? Icon(icon, color: Colors.green)
              : null,
    );
  }

  // Function to build the Add Member tile using an image
  Widget _buildAddMemberTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        // space for grey border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green, width: 2), // green border
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.transparent, // no background color
          backgroundImage: AssetImage('assets/images/AddMember.png'),
        ),
      ),
      title: Text(
        'Add Member',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Seamlessly add members to ensure everyone reaches destination on time, together.',
      ),
    );
  }
}
