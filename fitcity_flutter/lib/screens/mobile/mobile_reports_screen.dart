import 'package:flutter/material.dart';
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
      appBar: buildMobileAppBar(context, title: 'Reports'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Admin reports are available on desktop only.', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Sign in on the desktop app to view analytics and reports.', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                AccentButton(
                  label: 'Back to home',
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
