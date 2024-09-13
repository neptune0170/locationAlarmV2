import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/preferences/user_preferences.dart';

class AuthApiProvider {
  final String baseUrl = 'http://192.168.1.5:8080';

  Future<bool> signup(String email, String password, String fullName) async {
    print("here--------------------------------------------");
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );
    print("here 2 =================================================");
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Save session data in shared preferences
      String token = responseBody['token'];
      int expiresIn = responseBody['expiresIn'];
      String uuid = responseBody['uuid'];

      Map<String, dynamic> sessionData = {
        'token': token,
        'expiresIn': expiresIn,
        'uuid': uuid,
      };

      await UserPreferences.saveUserSession(sessionData);

      return responseBody;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      return null;
    }

    String token = sessionData['token'];
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Assuming you're using Bearer token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userDetails = jsonDecode(response.body);
      return userDetails; // Return user details
    } else {
      print(
          'Failed to retrieve user details. Status Code: ${response.statusCode}');
      return null; // Return null on failure
    }
  }
}
