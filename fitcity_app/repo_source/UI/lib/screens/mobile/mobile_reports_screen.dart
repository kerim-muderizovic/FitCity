import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import 'mobile_gym_list_screen.dart';

class MobileReportsScreen extends StatelessWidget {
  const MobileReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.reportsTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.reportsDesktopOnlyTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(context.l10n.reportsDesktopOnlyBody, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                AccentButton(
                  label: context.l10n.reportsBackHome,
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MobileGymListScreen()),
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
