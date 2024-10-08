import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:locationalarm/presentation/state_management/providers/circle_style_provider.dart';
import 'package:locationalarm/presentation/state_management/providers/radius_provider.dart';
import 'package:locationalarm/presentation/state_management/providers/location_provider.dart';
import 'package:locationalarm/data/data_providers/location_api_provider.dart';
import 'package:locationalarm/routes/approutes.dart';

import 'data/data_providers/aot_api_provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RadiusProvider()),
      ChangeNotifierProvider(create: (_) => CircleStyleProvider()),
      ChangeNotifierProvider(create: (_) => LocationProvider()),
      Provider<LocationApiProvider>(
        create: (_) => LocationApiProvider(),
      ),
      Provider<AotApiProvider>(
        create: (_) => AotApiProvider(),
      ),
    ],
    child: MyApp(),
  ));
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
      initialRoute: '/login', // Set the initial route
      routes: Routes.getRoutes(), // Use the Routes class to define routes
    );
  }
}
