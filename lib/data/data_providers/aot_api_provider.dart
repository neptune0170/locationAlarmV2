import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/preferences/user_preferences.dart';

class AotApiProvider {
  final String baseUrl =
      'http://192.168.1.5:8080'; // Replace with your base URL

  // Method to add a new event
  Future<bool> addEvent({
    required String eventName,
    required String locationName,
    required double lat,
    required double lng,
    required String time, // Format: dd/MM/yyyy HH:mm:ss
    required bool aotEnable,
  }) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false; // If user is not logged in or session is invalid
    }

    String token = sessionData['token'];

    Map<String, dynamic> eventData = {
      'eventName': eventName,
      'locationName': locationName,
      'lat': lat,
      'lng': lng,
      'time': time,
      'aotEnable': aotEnable,
    };

    print("Here aot api provider called =-=-=-=-=-=-=");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/event'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(eventData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Event added successfully.");
        return true;
      } else {
        print("Failed to add event: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return false;
    }
  }

  // Method to update event details
  Future<bool> updateEvent({
    required int eventId,
    required String eventName,
    required String locationName,
    required double lat,
    required double lng,
    required String time, // Format: dd/MM/yyyy HH:mm:ss
    required bool aotEnable,
  }) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false;
    }

    String token = sessionData['token'];

    Map<String, dynamic> eventData = {
      'eventName': eventName,
      'locationName': locationName,
      'lat': lat,
      'lng': lng,
      'time': time,
      'aotEnable': aotEnable,
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/event/$eventId/event'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(eventData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Event updated successfully.");
        return true;
      } else {
        print("Failed to update event: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return false;
    }
  }

  // Method to delete an event
  Future<bool> deleteEvent(int eventId) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false;
    }

    String token = sessionData['token'];

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/event/$eventId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Event deleted successfully.");
        return true;
      } else {
        print("Failed to delete event: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return false;
    }
  }

  // Method to get event details by event ID
  Future<Map<String, dynamic>?> getEventDetail(int eventId) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return null;
    }

    String token = sessionData['token'];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/event/$eventId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> eventDetail = jsonDecode(response.body);
        print("Event detail: $eventDetail");
        return eventDetail;
      } else {
        print("Failed to fetch event detail: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return null;
    }
  }

  // Method to add attendees to an event
  Future<bool> addAttendee({
    required int eventId,
    required List<String> emails,
  }) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false;
    }

    String token = sessionData['token'];

    Map<String, dynamic> attendeesData = {
      'emails': emails,
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/event/$eventId/attendee'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(attendeesData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Attendee(s) added successfully.");
        return true;
      } else {
        print("Failed to add attendee(s): ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return false;
    }
  }

  // Method to delete attendees from an event
  Future<bool> deleteAttendee({
    required int eventId,
    required List<String> emails,
  }) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false;
    }

    String token = sessionData['token'];

    Map<String, dynamic> attendeesData = {
      'emails': emails,
    };

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/event/$eventId/attendee'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(attendeesData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Attendee(s) removed successfully.");
        return true;
      } else {
        print("Failed to remove attendee(s): ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return false;
    }
  }
}
