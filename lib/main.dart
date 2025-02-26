import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locationalarm/backgroundService/ForegroundServiceProvider.dart';
import 'package:locationalarm/backgroundService/LocationSharingServiceProvider.dart';
import 'package:locationalarm/presentation/screens/HomeScreen/Track/utils/track_utils.dart';
import 'package:provider/provider.dart';
import 'package:locationalarm/presentation/state_management/providers/circle_style_provider.dart';
import 'package:locationalarm/presentation/state_management/providers/radius_provider.dart';
import 'package:locationalarm/presentation/state_management/providers/location_provider.dart';
import 'package:locationalarm/data/data_providers/location_api_provider.dart';
import 'package:locationalarm/routes/approutes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Ensure you import TrackUtils
import 'data/data_providers/aot_api_provider.dart';
import 'presentation/state_management/providers/address_box_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications(); // Initialize notifications globally

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationSharingServiceProvider()),
        ChangeNotifierProvider(create: (_) => ForegroundServiceProvider()),
        ChangeNotifierProvider(create: (_) => CircleStyleProvider()),
        ChangeNotifierProvider(create: (_) => RadiusProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AddressBoxProvider()),
        Provider<LocationApiProvider>(
          create: (_) => LocationApiProvider(),
        ),
        Provider<AotApiProvider>(
          create: (_) => AotApiProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: handleNotificationAction,
  );

  print("✅ Notification System Initialized!");
}

// 🔥 Handles notification actions globally (even when the app is closed)
void handleNotificationAction(NotificationResponse response) async {
  print("🔔 Notification Clicked! Action ID: ${response.actionId}");

  if (response.actionId == 'Stop') {
    print("🔕 Stop button clicked! Stopping alarm...");

    // Call the method to stop alarm
    TrackUtils.stopAlarm();

    // Cancel the notification only after stopping the alarm
    await flutterLocalNotificationsPlugin.cancel(0);

    print("✅ Alarm stopped & notification dismissed!");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ).copyWith(
          primary: Colors.black,
          secondary: Colors.black,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          bodyMedium:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          displayLarge:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          displayMedium:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          displaySmall:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          headlineMedium:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          headlineSmall:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          titleLarge:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          titleMedium:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          labelLarge:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          labelSmall:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
          bodySmall:
              TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: Routes.getRoutes(),
    );
  }
}
