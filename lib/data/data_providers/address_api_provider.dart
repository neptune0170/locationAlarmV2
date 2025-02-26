import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/preferences/user_preferences.dart';

class AddressApiProvider {
  // local Baseurl
  // final String baseUrl = 'http://192.168.1.7:8080';
  // final String baseUrl = 'http://192.168.128.1:8080';
  //cloud base Url
  final String baseUrl = 'https://locationalarm-v2-0-0.onrender.com';

  // Method to save an address
  Future<bool> saveAddress(
      {required String alarmName,
      required String note,
      required double radius,
      required bool alarmRings,
      required double latitude,
      required double longitude,
      required String alarmId}) async {
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
      'alarmId': alarmId
    };

    print("==========================================");

    print("AlarmID " + alarmId);
    print(alarmName);

    print("==========================================");

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

  // **New Method to Delete a Track Location**
  Future<bool> deleteAddress(String addressId) async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return false;
    }

    final String token = sessionData['token'];

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/track-location/delete/$addressId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );

      print("Delete Response Status: ${response.statusCode}");
      print("Delete Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Address deleted successfully.");
        return true;
      } else {
        print("Failed to delete address: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception occurred while deleting: $e");
      return false;
    }
  }
}
