import 'package:flutter/material.dart';
import 'fitcity_app.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitCityApp(home: AuthBootstrap(kind: AuthAppKind.desktop)));
}
