import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressBoxProvider with ChangeNotifier {
  Map<String, Map<String, dynamic>> _addressBoxData = {};

  Map<String, Map<String, dynamic>> get addressBoxData => _addressBoxData;

  void updateAddressBox(
      String userId, LatLng position, String estimatedTime) async {
    final String address = await _getAddressFromLatLng(position);
    _addressBoxData[userId] = {
      'position': position,
      'address': address,
      'driveTime': int.tryParse(estimatedTime.split(' ')[0]),
    };
    notifyListeners();
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    final String googleApiKey =
        "Your API Key"; // Replace with your Google API key
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      return data['results'][0]['formatted_address'];
    } else {
      return 'Unknown Address';
    }
  }
}
