import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/gym_selection.dart';
import '../theme/app_theme.dart';
import '../screens/mobile/mobile_gym_list_screen.dart';

class CurrentGymIndicator extends StatelessWidget {
  final bool showSwitchAction;

  const CurrentGymIndicator({super.key, this.showSwitchAction = true});

  @override
  Widget build(BuildContext context) {
    final store = GymSelectionStore.instance;
    return ValueListenableBuilder(
      valueListenable: store.currentGym,
      builder: (context, gym, _) {
        final name = gym?.name ?? context.l10n.gymNoSelection;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accentDeep, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.gymCurrentLabel(name),
                  style: const TextStyle(color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showSwitchAction)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MobileGymListScreen()),
                  ),
                  child: Text(context.l10n.gymSwitch),
                ),
            ],
          ),
        );
      },
    );
  }
}
