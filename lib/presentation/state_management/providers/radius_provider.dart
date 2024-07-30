import 'package:flutter/foundation.dart';

class RadiusProvider extends ChangeNotifier {
  double _radius = 1.0;

  double get radius => _radius;

  void setRadius(double radius) {
    _radius = radius;
    notifyListeners();
  }
}
