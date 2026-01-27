import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_active_membership_screen.dart';
import 'mobile_gym_list_screen.dart';
import 'mobile_qr_scan_screen.dart';

class MobileQrScanResultScreen extends StatelessWidget {
  final QrScanResult result;

  const MobileQrScanResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isGranted = result.status.toLowerCase() == 'granted';
    final color = isGranted ? AppColors.green : AppColors.red;
    final session = FitCityApi.instance.session.value;
    final canViewMembership = session != null && session.user.id == result.memberId;

    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Scan Result'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.membership),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan Result', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleBadge(color: color, label: isGranted ? 'Granted' : 'Denied'),
                      const SizedBox(height: 8),
                      Text(result.reason, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      _ResultRow(label: 'Gym', value: result.gymName ?? result.gymId ?? '-'),
                      _ResultRow(label: 'Member', value: result.memberName ?? result.memberId ?? '-'),
                      _ResultRow(label: 'Timestamp', value: result.scannedAtUtc?.toLocal().toString() ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AccentButton(
                  label: 'Scan again',
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MobileQrScanScreen()),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                if (canViewMembership)
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MobileActiveMembershipScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentDeep,
                      side: const BorderSide(color: AppColors.accentDeep),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View membership'),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MobileGymListScreen()),
                    (route) => false,
                  ),
                  child: const Text('Back to home', style: TextStyle(color: AppColors.accentDeep)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
