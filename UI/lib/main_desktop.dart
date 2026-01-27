import 'package:flutter/material.dart';
import 'fitcity_app.dart';
import 'screens/desktop/desktop_admin_login_screen.dart';
import 'services/fitcity_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FitCityApi.instance.init();
  runApp(const FitCityApp(home: DesktopAdminLoginScreen()));
}
