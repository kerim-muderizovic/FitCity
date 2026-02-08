import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'fitcity_app.dart';
import 'services/app_config.dart';
import 'services/locale_controller.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await LocaleController.instance.init();
  final isDesktop = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);
  runApp(FitCityApp(home: AuthBootstrap(kind: isDesktop ? AuthAppKind.desktop : AuthAppKind.mobile)));
}
