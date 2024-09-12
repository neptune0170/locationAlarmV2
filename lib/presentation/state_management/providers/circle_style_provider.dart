import 'package:flutter/material.dart';

class CircleStyleProvider with ChangeNotifier {
  bool _isOnEntry = true;

  bool get isOnEntry => _isOnEntry;

  void setIsOnEntry(bool value) {
    _isOnEntry = value;
    notifyListeners();
  }
}
