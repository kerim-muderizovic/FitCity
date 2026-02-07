import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/fitcity_api.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final bool compact;

  const LanguageSelector({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, locale, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LanguageChip(
              label: context.l10n.languageEnglish,
              flag: '🇬🇧',
              locale: const Locale('en'),
              selected: locale.languageCode == 'en',
              compact: compact,
            ),
            _LanguageChip(
              label: context.l10n.languageBosnian,
              flag: '🇧🇦',
              locale: const Locale('bs'),
              selected: locale.languageCode == 'bs',
              compact: compact,
            ),
            _LanguageChip(
              label: context.l10n.languageGerman,
              flag: '🇩🇪',
              locale: const Locale('de'),
              selected: locale.languageCode == 'de',
              compact: compact,
            ),
          ],
        );
      },
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final String flag;
  final Locale locale;
  final bool selected;
  final bool compact;

  const _LanguageChip({
    required this.label,
    required this.flag,
    required this.locale,
    required this.selected,
    required this.compact,
  });

  Future<void> _select() async {
    final userId = FitCityApi.instance.session.value?.user.id;
    await LocaleController.instance.setLocale(locale, userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _select,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accent : AppColors.slate),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: compact ? 12 : 14)),
          ],
        ),
      ),
    );
  }
}
