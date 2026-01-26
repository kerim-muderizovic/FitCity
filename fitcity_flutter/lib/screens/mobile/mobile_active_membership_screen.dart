import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_gym_list_screen.dart';
import 'mobile_membership_screen.dart';
import 'mobile_qr_screen.dart';
import 'mobile_qr_scan_screen.dart';

class MobileActiveMembershipScreen extends StatefulWidget {
  const MobileActiveMembershipScreen({super.key});

  @override
  State<MobileActiveMembershipScreen> createState() => _MobileActiveMembershipScreenState();
}

class _MobileActiveMembershipScreenState extends State<MobileActiveMembershipScreen> {
  final FitCityApi _api = FitCityApi.instance;
  ActiveMembership? _active;
  bool _loading = true;
  bool _paying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActive();
  }

  Future<void> _loadActive() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final active = await _api.activeMembership();
      setState(() => _active = active);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openQrPass() async {
    final active = _active;
    if (active == null || active.membershipId == null) {
      return;
    }
    try {
      final issue = await _api.issueQr(active.membershipId!);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MobileQrScreen(
            issue: issue,
            gymName: active.gymName,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _payMembership() async {
    final active = _active;
    if (active == null || active.requestId == null) {
      return;
    }
    final gymName = active.gymName;
    final confirmed = await _confirmPayment(gymName);
    if (!confirmed) {
      return;
    }
    setState(() => _paying = true);
    try {
      final response = await _api.payMembershipRequest(requestId: active.requestId!, paymentMethod: 'Card');
      await _loadActive();
      if (!mounted) {
        return;
      }
      final showQr = await _showPaymentReceipt(response);
      final qr = response.qr;
      if (showQr && qr != null) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MobileQrScreen(
              issue: qr,
              gymName: _active?.gymName ?? gymName,
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  Future<bool> _confirmPayment(String? gymName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm payment'),
          content: Text(
            'Pay for a 30-day membership${gymName == null ? '' : ' at $gymName'}? Your pass activates immediately.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Pay now')),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<bool> _showPaymentReceipt(MembershipPaymentResponse response) async {
    final membership = response.membership;
    final shouldShowQr = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Membership active until ${membership.endDateUtc.toLocal()}'),
              const SizedBox(height: 6),
              Text('Gym ID: ${membership.gymId}', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
          actions: [
            if (response.qr != null)
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Show QR')),
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Close')),
          ],
        );
      },
    );
    return shouldShowQr == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Active Pass'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.membership),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.red)))
                    : _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final active = _active;
    if (active == null) {
      return const Text('No membership data found.', style: TextStyle(color: AppColors.muted));
    }

    if (active.state == 'Active') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Pass', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _PassCard(active: active),
          const SizedBox(height: 16),
          AccentButton(label: 'Show QR pass', onPressed: _openQrPass, width: double.infinity),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileQrScanScreen())),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentDeep,
              side: const BorderSide(color: AppColors.accentDeep),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Scan QR'),
          ),
          const SizedBox(height: 16),
          SectionTitle(
            title: 'Memberships',
            action: 'View all',
            onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileMembershipScreen())),
          ),
          const SizedBox(height: 8),
          const Text('Manage or renew your plans in the memberships list.', style: TextStyle(color: AppColors.muted)),
        ],
      );
    }

    if (active.state == 'Approved' || active.canPay) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership approved', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Payment status: ${active.paymentStatus ?? 'Unpaid'}', style: const TextStyle(color: AppColors.accentDeep)),
          const SizedBox(height: 8),
          Text('Gym: ${active.gymName ?? active.gymId ?? '-'}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          AccentButton(
            label: _paying ? 'Processing...' : 'Pay membership',
            onPressed: _paying ? null : _payMembership,
            width: double.infinity,
          ),
        ],
      );
    }

    if (active.state == 'Pending') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership pending', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Status: ${active.requestStatus ?? 'Pending'}', style: const TextStyle(color: AppColors.accentDeep)),
          const SizedBox(height: 8),
          Text('Gym: ${active.gymName ?? active.gymId ?? '-'}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          AccentButton(
            label: 'Browse gyms',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileGymListScreen())),
            width: double.infinity,
          ),
        ],
      );
    }

    if (active.state == 'Expired') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership expired', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Gym: ${active.gymName ?? active.gymId ?? '-'}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text('Expired on: ${active.endDateUtc?.toLocal() ?? '-'}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          AccentButton(
            label: 'Renew membership',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileMembershipScreen())),
            width: double.infinity,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No active membership', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Browse gyms to get started with a plan.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        AccentButton(
          label: 'Browse gyms',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileGymListScreen())),
          width: double.infinity,
        ),
      ],
    );
  }
}

class _PassCard extends StatelessWidget {
  final ActiveMembership active;

  const _PassCard({required this.active});

  @override
  Widget build(BuildContext context) {
    final remaining = active.remainingDays ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(active.planName ?? 'Membership pass', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(active.gymName ?? 'Gym', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleBadge(color: AppColors.green, label: active.membershipStatus ?? 'Active'),
              const SizedBox(width: 8),
              Text('$remaining days left', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Start: ${active.startDateUtc?.toLocal() ?? '-'}', style: const TextStyle(color: AppColors.muted)),
          Text('End: ${active.endDateUtc?.toLocal() ?? '-'}', style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
