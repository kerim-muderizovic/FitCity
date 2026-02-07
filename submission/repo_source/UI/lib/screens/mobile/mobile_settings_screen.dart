import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../services/preferences_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import '../../services/gym_selection.dart';
import 'mobile_auth_screen.dart';
import 'mobile_change_password_screen.dart';

class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = FitCityApi.instance;
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.settingsTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: RoleGate(
        allowedRoles: const {'User', 'Trainer'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: PreferencesStore.instance.preferences,
                    builder: (context, prefs, _) {
                      return Column(
                        children: [
                          _ToggleRow(
                            label: context.l10n.settingsPushNotifications,
                            value: prefs.pushNotifications,
                            onChanged: (value) => PreferencesStore.instance
                                .update(prefs.copyWith(pushNotifications: value)),
                          ),
                          const SizedBox(height: 12),
                          _ToggleRow(
                            label: context.l10n.settingsAutoRenew,
                            value: prefs.autoRenew,
                            onChanged: (value) =>
                                PreferencesStore.instance.update(prefs.copyWith(autoRenew: value)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.settingsLanguage, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const LanguageSelector(),
                const SizedBox(height: 16),
                AccentButton(
                  label: context.l10n.settingsChangePassword,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MobileChangePasswordScreen()),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.settingsTermsTodo)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentDeep,
                    side: const BorderSide(color: AppColors.accentDeep),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(context.l10n.settingsTermsOfService),
                ),
                const SizedBox(height: 12),
                AccentButton(
                  label: context.l10n.commonSignOut,
                  onPressed: () {
                    api.session.value = null;
                    GymSelectionStore.instance.clear();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MobileAuthScreen()),
                      (_) => false,
                    );
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accentDeep,
        ),
      ],
    );
  }
}
