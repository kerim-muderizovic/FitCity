import 'package:flutter/material.dart';
import 'fitcity_app.dart';
import 'services/app_config.dart';
import 'services/locale_controller.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await LocaleController.instance.init();
  runApp(const FitCityApp(home: AuthBootstrap(kind: AuthAppKind.mobile)));
}
