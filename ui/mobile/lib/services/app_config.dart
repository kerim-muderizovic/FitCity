import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  static String apiBaseUrl = '';
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) {
      return;
    }

    const override = String.fromEnvironment('FITCITY_API_BASE_URL');
    if (override.isNotEmpty) {
      apiBaseUrl = override;
      _loaded = true;
      return;
    }

    final raw = await rootBundle.loadString('assets/config/app_config.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final apiConfig = decoded['apiBaseUrl'] as Map<String, dynamic>? ?? const {};

    final defaultUrl = (apiConfig['default'] as String?)?.trim();
    String? resolved = defaultUrl;

    if (kIsWeb) {
      resolved = (apiConfig['web'] as String?)?.trim() ?? resolved;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          resolved = (apiConfig['android'] as String?)?.trim() ?? resolved;
          break;
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
          resolved = (apiConfig['desktop'] as String?)?.trim() ?? resolved;
          break;
        case TargetPlatform.fuchsia:
        case TargetPlatform.iOS:
          resolved = (apiConfig['mobile'] as String?)?.trim() ?? resolved;
          break;
      }
    }

    apiBaseUrl = resolved ?? '';
    _loaded = true;
  }
}
