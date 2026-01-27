import 'package:flutter/material.dart';
import '../services/gym_selection.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../screens/mobile/mobile_gym_list_screen.dart';
import '../screens/mobile/mobile_map_screen.dart';

class GymGuard extends StatelessWidget {
  final Widget child;
  final String? message;

  const GymGuard({super.key, required this.child, this.message});

  @override
  Widget build(BuildContext context) {
    final store = GymSelectionStore.instance;
    return ValueListenableBuilder(
      valueListenable: store.currentGym,
      builder: (context, gym, _) {
        if (gym != null) {
          return child;
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message ?? 'Select a gym to continue.', style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 12),
                AccentButton(
                  label: 'Choose from list',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MobileGymListScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MobileMapScreen()),
                  ),
                  child: const Text('Open map', style: TextStyle(color: AppColors.accentDeep)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
