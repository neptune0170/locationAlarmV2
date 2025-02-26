import 'package:flutter/material.dart';

class CircleStyleProvider with ChangeNotifier {
  bool _isOnEntry = true;

  bool get isOnEntry => _isOnEntry;

  void setIsOnEntry(bool value) {
    print("Value chagged=====================================================");
    _isOnEntry = value;
    notifyListeners();
  }
}
