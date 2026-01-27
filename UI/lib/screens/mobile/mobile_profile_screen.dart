import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_active_membership_screen.dart';
import 'mobile_membership_screen.dart';
import 'mobile_notifications_screen.dart';
import 'mobile_auth_screen.dart';
import 'mobile_settings_screen.dart';
import 'mobile_schedule_screen.dart';
import 'mobile_requests_screen.dart';
import 'mobile_chat_screen.dart';
import 'mobile_gym_list_screen.dart';
import 'mobile_profile_edit_screen.dart';

class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  final FitCityApi _api = FitCityApi.instance;
  List<Membership> _memberships = [];
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    final session = _api.session.value;
    if (session == null || session.user.role != 'User') {
      setState(() => _memberships = []);
      return;
    }
    try {
      final memberships = await _api.memberships();
      setState(() => _memberships = memberships);
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _api.session.value;
    final role = session?.user.role;
    final isTrainer = role == 'Trainer';
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Profile'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: RoleGate(
        allowedRoles: const {'User', 'Trainer'},
        allowAnonymous: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 42, backgroundColor: AppColors.slate, child: Icon(Icons.person, size: 36, color: AppColors.muted)),
                      const SizedBox(height: 8),
                      Text(session?.user.fullName ?? 'Guest', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(session?.user.email ?? 'Not signed in', style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (session == null)
                  AccentButton(
                    label: 'Sign in',
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MobileAuthScreen())),
                  ),
                if (session == null) const SizedBox(height: 16),
                const Text('Current gym', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const CurrentGymIndicator(),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const MobileGymListScreen())),
                  child: const Text('Switch gym', style: TextStyle(color: AppColors.accentDeep)),
                ),
                const SizedBox(height: 16),
                if (session != null && !isTrainer) ...[
                  const Text('Memberships', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  if (_statusMessage != null) Text(_statusMessage!, style: const TextStyle(color: AppColors.red)),
                  if (_memberships.isEmpty)
                    const Text('No active memberships.', style: TextStyle(color: AppColors.muted))
                  else
                    Column(
                      children: _memberships
                          .map(
                            (membership) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${membership.status} until ${membership.endDateUtc.toLocal()}',
                                style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const MobileActiveMembershipScreen())),
                        child: const Text('Active pass', style: TextStyle(color: AppColors.accentDeep)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const MobileMembershipScreen())),
                        child: const Text('All memberships', style: TextStyle(color: AppColors.accentDeep)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (session != null && isTrainer) ...[
                  const Text('Trainer tools', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AccentButton(
                        label: 'Schedule',
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const MobileScheduleScreen())),
                        width: 140,
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const MobileRequestsScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentDeep,
                          side: const BorderSide(color: AppColors.accentDeep),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Requests'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MobileChatScreen())),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentDeep,
                      side: const BorderSide(color: AppColors.accentDeep),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Trainer chat'),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Preferences', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Weight Loss  Cardio', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AccentButton(
                      label: 'Edit Profile',
                      onPressed: session == null
                          ? null
                          : () async {
                              final updated = await Navigator.of(context).push<CurrentUser>(
                                MaterialPageRoute(
                                  builder: (_) => MobileProfileEditScreen(user: session.user),
                                ),
                              );
                              if (updated != null) {
                                setState(() {});
                              }
                            },
                      width: 140,
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const MobileNotificationsScreen())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentDeep,
                        side: const BorderSide(color: AppColors.accentDeep),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Notifications'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const MobileSettingsScreen())),
                  child: const Text('Settings', style: TextStyle(color: AppColors.accentDeep)),
                ),
                if (session != null) ...[
                  const SizedBox(height: 20),
                  AccentButton(
                    label: 'Logout',
                    onPressed: () {
                      _api.session.value = null;
                      GymSelectionStore.instance.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MobileAuthScreen()),
                        (_) => false,
                      );
                    },
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


