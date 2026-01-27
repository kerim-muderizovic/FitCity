import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class FitCityApp extends StatelessWidget {
  final Widget home;

  const FitCityApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: home,
    );
  }
}
