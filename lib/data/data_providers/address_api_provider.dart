import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/preferences/user_preferences.dart';

class AddressApiProvider {
  final String baseUrl = 'http://192.168.1.5:8080';

  // Method to save an address
  Future<bool> saveAddress({
    required String alarmName,
    required String note,
    required double radius,
    required bool alarmRings,
    required double latitude,
    required double longitude,
  }) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false;
    }

    String userId = sessionData['uuid'];
    final String token = sessionData['token'];

    Map<String, dynamic> addressData = {
      'userId': userId,
      'alarmName': alarmName,
      'note': note,
      'radius': radius,
      'alarmRings': alarmRings,
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/track-location/save'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(addressData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Address saved successfully.");
        return true;
      } else {
        print("Failed to save address: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return false;
    }
  }

  // Method to retrieve addresses
  Future<List<Map<String, dynamic>>?> getAddresses() async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return null;
    }

    String userId = sessionData['uuid'];
    final String token = sessionData['token'];

    final response = await http.get(
      Uri.parse('$baseUrl/track-location/user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      List<Map<String, dynamic>> addresses = responseBody.map((dynamic item) {
        return {
          'id': item['id'],
          'userId': item['userId'],
          'alarmName': item['alarmName'],
          'note': item['note'],
          'radius': item['radius'],
          'alarmRings': item['alarmRings'],
          'latitude': item['latitude'],
          'longitude': item['longitude'],
          'createdAt': item['createdAt'],
          'updatedAt': item['updatedAt'],
        };
      }).toList();

      print("Here in addresapi provider  [][][][][] -" + addresses.toString());
      return addresses;
    } else {
      return null;
    }
  }
}
