import 'package:flutter/material.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/AOT/add_member_page.dart';
import 'package:locationalarm/presentation/screens/Login/signup_page.dart';
import '../presentation/screens/HomeScreen/AOT/group_event.dart';
import '../presentation/screens/HomeScreen/Settings/appearance.dart';
import '../presentation/screens/HomeScreen/Settings/notification_page.dart';
import '../presentation/screens/Login/login_page.dart';
import '../presentation/screens/HomeScreen/Settings/volume.dart';
import '../presentation/screens/HomeScreen/Settings/account_information.dart';
import '../presentation/screens/home_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => LoginPage(),
      '/login': (context) => LoginPage(),
      '/signUp': (context) => SignupPage(),
      '/home': (context) => HomePage(),
      '/accountInformation': (context) => AccountInformation(),
      '/appearance': (context) => Appearance(),
      '/volume': (context) => Volume(),
      '/notificationPage': (context) => NotificationPage(),
      '/groupEvent': (context) => GroupEvent(),
    };
  }
}
