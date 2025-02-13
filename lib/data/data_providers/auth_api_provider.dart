import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/preferences/user_preferences.dart';

class AuthApiProvider {
  // local Baseurl
  final String baseUrl = 'http://192.168.1.7:8080';
  //final String baseUrl = 'http://192.168.85.1:8080';

  //cloud base Url
  //final String baseUrl = 'https://locationalarm-v2-0-0.onrender.com';

  Future<bool> signup(String email, String password, String fullName) async {
    print("Signup initiated with email: $email");
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
    print("Signup response: ${response.statusCode} | ${response.body}");

    if (response.statusCode == 200) {
      print("Signup successful");
      return true;
    } else {
      print(
          "Signup failed with status: ${response.statusCode} | ${response.body}");
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    print("Login initiated with email: $email");
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
    print("Login response status: ${response.statusCode}");
    print("Login response body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print("Login successful, response: $responseBody");

      // Save session data in shared preferences
      String token = responseBody['token'];
      int expiresIn = responseBody['expiresIn'];
      String uuid = responseBody['uuid'];

      Map<String, dynamic> sessionData = {
        'token': token,
        'expiresIn': expiresIn,
        'uuid': uuid,
      };

      print("Saving session data: $sessionData");
      await UserPreferences.saveUserSession(sessionData);

      return responseBody;
    } else {
      print(
          "Login failed with status: ${response.statusCode} | ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    print("Fetching user details...");
    Map<String, dynamic>? sessionData = await UserPreferences.getUserSession();
    if (sessionData == null) {
      print("No session data found.");
      return null;
    }

    String token = sessionData['token'];
    print("Found token: $token");

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    print("Get user details response status: ${response.statusCode}");
    print("Get user details response body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> userDetails = jsonDecode(response.body);
      print("User details retrieved successfully: $userDetails");
      return userDetails;
    } else {
      print(
          'Failed to retrieve user details. Status Code: ${response.statusCode}');
      return null;
    }
  }
}
