import 'package:flutter/foundation.dart';

class UserPreferences {
  final bool pushNotifications;
  final bool autoRenew;

  const UserPreferences({
    required this.pushNotifications,
    required this.autoRenew,
  });

  UserPreferences copyWith({
    bool? pushNotifications,
    bool? autoRenew,
  }) {
    return UserPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}

class PreferencesStore {
  PreferencesStore._();

  static final PreferencesStore instance = PreferencesStore._();

  final ValueNotifier<UserPreferences> preferences = ValueNotifier<UserPreferences>(
    const UserPreferences(
      pushNotifications: true,
      autoRenew: false,
    ),
  );

  void update(UserPreferences value) {
    preferences.value = value;
  }
}
