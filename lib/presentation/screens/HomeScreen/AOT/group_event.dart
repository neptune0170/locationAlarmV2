import 'package:flutter/material.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/add_member_page.dart';
import '../../../../data/data_providers/aot_api_provider.dart';
import '../../../../data/data_providers/auth_api_provider.dart';

class GroupEvent extends StatefulWidget {
  const GroupEvent({super.key});

  @override
  State<GroupEvent> createState() => _GroupEventState();
}

class _GroupEventState extends State<GroupEvent> {
  Map<String, dynamic>? eventDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      // Fetch user details to get event ID
      Map<String, dynamic>? userDetails =
          await AuthApiProvider().getUserDetails();
      if (userDetails != null) {
        int eventId = userDetails['eventId'];
        // Fetch event details using event ID
        Map<String, dynamic>? fetchedEventDetails =
            await AotApiProvider().getEventDetail(eventId);

        // Check if widget is mounted before calling setState
        if (mounted && fetchedEventDetails != null) {
          setState(() {
            eventDetails = fetchedEventDetails;
            isLoading = false;
          });
        } else {
          // If event details are not found or null
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        // In case of any issues fetching the user details
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // Log or handle errors
      print("Error fetching event details: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAddMemberPage() async {
    if (eventDetails != null && eventDetails!['eventId'] != null) {
      // Use await to wait for the result when returning from AddMemberPage
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddMemberPage(eventId: int.parse(eventDetails!['eventId'])),
        ),
      );

      // Refresh the event details after returning from AddMemberPage
      _fetchEventDetails(); // Refresh the page
    } else {
      print("Event ID is not available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top section with background image and event details
                Stack(
                  children: [
                    // Background Image
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
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
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.black),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    eventDetails?['eventName'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Arrival: ${eventDetails?['locationName'] ?? ''}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'On ${eventDetails?['time'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created by ${eventDetails?['adminName'] ?? 'Admin'}', // Use 'adminName' for admin's name
                              style: const TextStyle(
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
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: const Text(
                          'Event Settings',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // Add your event settings navigation or functionality here
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),

                // Member List with grey-bordered circles and custom add member image
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildAddMemberTile(),
                      // Dynamically display attendees
                      ..._buildAttendeeList(),
                      _buildMemberTileWithBorder(
                          eventDetails?['adminName'] ??
                              'Event Admin', // Display admin's name
                          'AOT Score - 88%',
                          'Event Admin',
                          Colors.blue,
                          isAdmin: true),
                    ],
                  ),
                ),

                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () {
                      // Add delete event functionality
                    },
                    child: const Center(
                      child: Text(
                        'Cancel Event',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Function to build the attendee list dynamically
  List<Widget> _buildAttendeeList() {
    List<dynamic>? attendees = eventDetails?['attendees'];

    if (attendees == null || attendees.isEmpty) {
      return [const Text('No attendees found.')];
    }

    return attendees.map((attendee) {
      return _buildMemberTileWithBorder(
        attendee['name'] ?? 'Unknown', // Changed to show name instead of email
        'AOT Score - ${attendee['aot'] ?? 'N/A'}',
        '',
        Colors.grey,
      );
    }).toList();
  }

  // Function to build a member tile with a grey-bordered circle
  Widget _buildMemberTileWithBorder(
      String name, String score, String subtitle, Color color,
      {IconData? icon, bool isAdmin = false}) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 4),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: color,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        score,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: isAdmin
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/images/AddMember.png'),
          ),
        ),
        title: const Text(
          'Add Member',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Seamlessly add members to ensure everyone reaches destination on time, together.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        onTap: _navigateToAddMemberPage);
  }
}
