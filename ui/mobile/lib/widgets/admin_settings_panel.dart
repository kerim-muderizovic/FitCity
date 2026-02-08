import 'package:flutter/material.dart';
import '../data/fitcity_models.dart';
import '../l10n/l10n.dart';
import '../services/fitcity_api.dart';
import '../theme/app_theme.dart';
import '../utils/error_mapper.dart';
import 'common.dart';
import 'language_selector.dart';

class AdminSettingsPanel extends StatefulWidget {
  const AdminSettingsPanel({super.key});

  @override
  State<AdminSettingsPanel> createState() => _AdminSettingsPanelState();
}

class _AdminSettingsPanelState extends State<AdminSettingsPanel> {
  final FitCityApi _api = FitCityApi.instance;
  AdminSettings? _settings;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final settings = await _api.adminSettings();
      if (mounted) {
        setState(() => _settings = settings);
      }
    } on FitCityApiException catch (error) {
      if (mounted) {
        setState(() => _error = mapApiError(context, error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.errorsGeneric);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final settings = _settings;
    if (settings == null || _saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await _api.updateAdminSettings(settings);
      if (!mounted) {
        return;
      }
      setState(() => _settings = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonSuccess)),
      );
    } on FitCityApiException catch (error) {
      if (mounted) {
        setState(() => _error = mapApiError(context, error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.errorsGeneric);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: AppColors.red)),
              const SizedBox(height: 12),
              AccentButton(
                label: context.l10n.commonRetry,
                onPressed: _loadSettings,
                width: 160,
              ),
            ],
          ),
        ),
      );
    }

    final settings = _settings ??
        AdminSettings(
          allowGymRegistrations: true,
          allowUserRegistration: true,
          allowTrainerCreation: true,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.settingsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.settingsGeneral, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _ToggleRow(
                label: context.l10n.settingsAllowGymRegistrations,
                value: settings.allowGymRegistrations,
                onChanged: (value) => setState(() {
                  _settings = AdminSettings(
                    allowGymRegistrations: value,
                    allowUserRegistration: settings.allowUserRegistration,
                    allowTrainerCreation: settings.allowTrainerCreation,
                  );
                }),
              ),
              const SizedBox(height: 8),
              _ToggleRow(
                label: context.l10n.settingsAllowUserRegistrations,
                value: settings.allowUserRegistration,
                onChanged: (value) => setState(() {
                  _settings = AdminSettings(
                    allowGymRegistrations: settings.allowGymRegistrations,
                    allowUserRegistration: value,
                    allowTrainerCreation: settings.allowTrainerCreation,
                  );
                }),
              ),
              const SizedBox(height: 8),
              _ToggleRow(
                label: context.l10n.settingsAllowTrainerCreation,
                value: settings.allowTrainerCreation,
                onChanged: (value) => setState(() {
                  _settings = AdminSettings(
                    allowGymRegistrations: settings.allowGymRegistrations,
                    allowUserRegistration: settings.allowUserRegistration,
                    allowTrainerCreation: value,
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(context.l10n.settingsLanguage, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const LanguageSelector(),
              const SizedBox(height: 12),
              AccentButton(
                label: _saving ? context.l10n.commonWorking : context.l10n.settingsSave,
                onPressed: _saving ? null : _saveSettings,
                width: 160,
              ),
            ],
          ),
        ),
      ],
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
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
