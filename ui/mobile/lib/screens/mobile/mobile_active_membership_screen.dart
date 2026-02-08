import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/error_mapper.dart';
import '../../utils/stripe_checkout.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_gym_list_screen.dart';
import 'mobile_membership_screen.dart';
import 'mobile_qr_screen.dart';

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
  bool _paymentPending = false;
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
      setState(() => _error = mapApiError(context, error));
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
        SnackBar(content: Text(mapApiError(context, error))),
      );
    }
  }

  Future<void> _payMembership() async {
    final active = _active;
    if (active == null || active.requestId == null) {
      return;
    }
    final method = await _selectPaymentMethod();
    if (method == null) {
      return;
    }
    if (method == 'Manual') {
      await _manualPayMembership(active.requestId!, active.gymName);
      return;
    }
    final gymName = active.gymName;
    final confirmed = await _confirmPayment(gymName);
    if (!confirmed) {
      return;
    }
    setState(() => _paying = true);
    try {
      final response = await _api.createMembershipCheckout(requestId: active.requestId!);
      final launched = await launchStripeCheckout(
        context,
        response.url,
        invalidUrlMessage: context.l10n.paymentInvalidCheckoutUrl,
        launchFailedMessage: context.l10n.paymentLaunchFailed,
      );
      if (!launched) {
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() => _paymentPending = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paymentOpenBrowser)),
      );
      await _pollForActiveMembership();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapApiError(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  Future<void> _manualPayMembership(String requestId, String? gymName) async {
    setState(() => _paying = true);
    try {
      final response = await _api.manualPayMembershipRequest(requestId: requestId);
      await _loadActive();
      if (!mounted) {
        return;
      }
      final shouldShowQr = await _showPaymentReceipt(response);
      final qr = response.qr;
      if (shouldShowQr && qr != null) {
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
        SnackBar(content: Text(mapApiError(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  Future<String?> _selectPaymentMethod() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(context.l10n.paymentChooseMethod, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(context.l10n.paymentUseStripe),
                onTap: () => Navigator.of(context).pop('Card'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(context.l10n.paymentMarkPaid),
                onTap: () => Navigator.of(context).pop('Manual'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pollForActiveMembership() async {
    for (var i = 0; i < 12; i += 1) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) {
        return;
      }
      await _loadActive();
      if (_active?.state == 'Active') {
        setState(() => _paymentPending = false);
        _showPaymentSuccess();
        return;
      }
    }
    if (mounted) {
      setState(() => _paymentPending = false);
    }
  }

  void _showPaymentSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 6), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          title: Text(context.l10n.membershipPaymentSuccessTitle),
          content: Text(context.l10n.paymentConfirmed),
        );
      },
    );
  }

  Future<bool> _confirmPayment(String? gymName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.membershipConfirmPaymentTitle),
          content: Text(
            context.l10n.membershipConfirmPaymentBody(gymName == null ? '' : ' ${gymName!}'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.membershipPayNow)),
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
          title: Text(context.l10n.membershipPaymentSuccessTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.membershipActiveUntil(AppDateTimeFormat.dateTime(membership.endDateUtc))),
              const SizedBox(height: 6),
            ],
          ),
          actions: [
            if (response.qr != null)
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.membershipShowQr)),
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonClose)),
          ],
        );
      },
    );
    return shouldShowQr == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.membershipActivePassTitle),
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
      return Text(context.l10n.membershipNoData, style: const TextStyle(color: AppColors.muted));
    }

    if (active.state == 'Active') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.membershipActivePassTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _PassCard(active: active),
          const SizedBox(height: 16),
          AccentButton(label: context.l10n.membershipShowQrPass, onPressed: _openQrPass, width: double.infinity),
          const SizedBox(height: 16),
          SectionTitle(
            title: context.l10n.commonMemberships,
            action: context.l10n.commonViewAll,
            onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileMembershipScreen())),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.membershipManageHint, style: const TextStyle(color: AppColors.muted)),
        ],
      );
    }

    if (active.state == 'Approved' || active.canPay) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.membershipApprovedTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(context.l10n.membershipPaymentStatus(active.paymentStatus ?? context.l10n.membershipUnpaid),
              style: const TextStyle(color: AppColors.accentDeep)),
          const SizedBox(height: 8),
          Text(context.l10n.membershipGymLabel(active.gymName ?? active.gymId ?? '-'),
              style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
            AccentButton(
              label: _paying ? context.l10n.membershipProcessing : context.l10n.membershipPayAction,
              onPressed: _paying ? null : _payMembership,
              width: double.infinity,
            ),
            if (_paymentPending) ...[
              const SizedBox(height: 8),
              Text(context.l10n.paymentPendingConfirmation,
                  style: const TextStyle(color: AppColors.accentDeep)),
            ],
          ],
        );
      }

    if (active.state == 'Pending') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.membershipPendingTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
            Text(context.l10n.membershipStatusLabel(active.requestStatus ?? context.l10n.commonPending),
                style: const TextStyle(color: AppColors.accentDeep)),
            const SizedBox(height: 8),
            Text(context.l10n.membershipGymLabel(active.gymName ?? active.gymId ?? '-'),
                style: const TextStyle(color: AppColors.muted)),
            if ((active.requestStatus ?? '').toLowerCase() == 'rejected') ...[
              const SizedBox(height: 8),
              Text(
                active.rejectionReason?.isNotEmpty == true
                    ? active.rejectionReason!
                    : context.l10n.membershipRejectedDefault,
                style: const TextStyle(color: AppColors.red),
              ),
            ],
            const SizedBox(height: 16),
          AccentButton(
            label: context.l10n.membershipBrowseGyms,
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
          Text(context.l10n.membershipExpiredTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(context.l10n.membershipGymLabel(active.gymName ?? active.gymId ?? '-'),
              style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(context.l10n.membershipExpiredOn(AppDateTimeFormat.dateTime(active.endDateUtc)),
              style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          AccentButton(
            label: context.l10n.membershipRenew,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileMembershipScreen())),
            width: double.infinity,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.membershipNoActiveTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(context.l10n.membershipBrowseHint, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        AccentButton(
          label: context.l10n.membershipBrowseGyms,
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
          Text(active.planName ?? context.l10n.membershipPassLabel,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(active.gymName ?? context.l10n.membershipGymNameFallback,
              style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleBadge(color: AppColors.green, label: active.membershipStatus ?? context.l10n.commonActive),
              const SizedBox(width: 8),
              Text(context.l10n.membershipDaysLeft(remaining),
                  style: const TextStyle(color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(context.l10n.membershipStartLabel(AppDateTimeFormat.dateTime(active.startDateUtc)),
              style: const TextStyle(color: AppColors.muted)),
          Text(context.l10n.membershipEndLabel(AppDateTimeFormat.dateTime(active.endDateUtc)),
              style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
