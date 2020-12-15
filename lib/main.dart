import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/routes.dart';

import 'screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: theme(),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
