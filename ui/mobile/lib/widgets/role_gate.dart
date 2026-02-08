import 'package:flutter/material.dart';
import '../services/fitcity_api.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../screens/mobile/mobile_auth_screen.dart';
import '../screens/mobile/mobile_gym_list_screen.dart';
import '../screens/mobile/mobile_schedule_screen.dart';

class RoleGate extends StatelessWidget {
  final Set<String> allowedRoles;
  final bool allowAnonymous;
  final String? unauthorizedMessage;
  final String? adminMessage;
  final Widget child;

  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.allowAnonymous = false,
    this.unauthorizedMessage,
    this.adminMessage,
  });

  @override
  Widget build(BuildContext context) {
    final api = FitCityApi.instance;
    return ValueListenableBuilder(
      valueListenable: api.session,
      builder: (context, session, _) {
        if (session == null) {
          if (allowAnonymous) {
            return child;
          }
          return _AccessCard(
            message: 'Sign in to continue.',
            actionLabel: 'Go to login',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MobileAuthScreen()),
            ),
          );
        }

        final role = session.user.role;
        if (role == 'CentralAdministrator' || role == 'GymAdministrator') {
          return _AccessCard(
            message: adminMessage ?? 'Admin accounts use the desktop app.',
            actionLabel: 'Sign out',
            onAction: () => api.session.value = null,
          );
        }

        if (!allowedRoles.contains(role)) {
          return _AccessCard(
            message: unauthorizedMessage ?? 'This screen is not available for your role.',
            actionLabel: 'Back to home',
            onAction: () => _goHome(context, role),
          );
        }

        return child;
      },
    );
  }

  void _goHome(BuildContext context, String role) {
    final Widget destination =
        role == 'Trainer' ? const MobileScheduleScreen() : const MobileGymListScreen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }
}

class _AccessCard extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _AccessCard({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: AppColors.muted), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AccentButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
