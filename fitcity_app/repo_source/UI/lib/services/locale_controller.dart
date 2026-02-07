import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const String _localeStorageKey = 'fitcity.locale';
  static const String _userLocalePrefix = 'fitcity.locale.user.';

  static final LocaleController instance = LocaleController._();

  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('en'));

  LocaleController._();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localeStorageKey);
    locale.value = _localeFromCode(stored) ?? const Locale('en');
  }

  Future<void> applyForUser(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userCode = userId == null ? null : prefs.getString('$_userLocalePrefix$userId');
    final stored = userCode ?? prefs.getString(_localeStorageKey);
    locale.value = _localeFromCode(stored) ?? const Locale('en');
  }

  Future<void> setLocale(Locale newLocale, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final code = _localeCode(newLocale);
    await prefs.setString(_localeStorageKey, code);
    if (userId != null) {
      await prefs.setString('$_userLocalePrefix$userId', code);
    }
    locale.value = newLocale;
  }

  Locale? _localeFromCode(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    switch (code.toLowerCase()) {
      case 'en':
        return const Locale('en');
      case 'bs':
        return const Locale('bs');
      case 'de':
        return const Locale('de');
      default:
        return null;
    }
  }

  String _localeCode(Locale locale) {
    return locale.languageCode.toLowerCase();
  }
}
