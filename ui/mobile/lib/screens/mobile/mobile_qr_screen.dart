import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';

class MobileQrScreen extends StatefulWidget {
  final QrIssue? issue;
  final String? gymName;

  const MobileQrScreen({super.key, this.issue, this.gymName});

  @override
  State<MobileQrScreen> createState() => _MobileQrScreenState();
}

class _MobileQrScreenState extends State<MobileQrScreen> {
  final FitCityApi _api = FitCityApi.instance;
  Timer? _pollTimer;
  Timer? _successTimer;
  Timer? _deniedTimer;
  DateTime? _lastEntryAtUtc;
  bool _showSuccess = false;
  bool _showDenied = false;
  String? _deniedMessage;

  @override
  void initState() {
    super.initState();
    _primeEntryState();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollEntries());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _successTimer?.cancel();
    _deniedTimer?.cancel();
    super.dispose();
  }

  Future<void> _primeEntryState() async {
    try {
      final entries = await _api.entryHistory(fromUtc: DateTime.now().toUtc().subtract(const Duration(hours: 6)));
      if (entries.isNotEmpty) {
        _lastEntryAtUtc = entries.first.checkedAtUtc?.toUtc();
      }
    } catch (_) {}
  }

  Future<void> _pollEntries() async {
    if (!mounted) {
      return;
    }
      try {
        final from = _lastEntryAtUtc ?? DateTime.now().toUtc().subtract(const Duration(hours: 6));
        final entries = await _api.entryHistory(fromUtc: from);
        if (entries.isEmpty) {
          return;
        }
        final latest = entries.first.checkedAtUtc?.toUtc();
        if (latest != null && (_lastEntryAtUtc == null || latest.isAfter(_lastEntryAtUtc!))) {
          _lastEntryAtUtc = latest;
          final latestEntry = entries.first;
          if (latestEntry.status.toLowerCase() == 'granted') {
            _showSuccessOverlay();
          } else {
            _showDeniedOverlay(_mapDeniedReason(context, latestEntry.reason));
          }
        }
      } catch (_) {}
    }

  String _mapDeniedReason(BuildContext context, String reason) {
    final normalized = reason.toLowerCase();
    if (normalized.contains('gym administrator access is limited')) {
      return context.l10n.qrDeniedWrongGym;
    }
    if (normalized.contains('inactive or expired') || normalized.contains('no active membership')) {
      return context.l10n.qrDeniedInactive;
    }
    if (normalized.contains('expired')) {
      return context.l10n.qrDeniedExpired;
    }
    if (normalized.contains('invalid')) {
      return context.l10n.qrDeniedInvalid;
    }
    return context.l10n.qrDeniedGeneric;
  }

  void _showSuccessOverlay() {
    if (!mounted) {
      return;
    }
    setState(() {
      _showSuccess = true;
      _showDenied = false;
      _deniedMessage = null;
    });
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSuccess = false);
    });
  }

  void _showDeniedOverlay(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _showDenied = true;
      _deniedMessage = message;
      _showSuccess = false;
    });
    _deniedTimer?.cancel();
    _deniedTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) {
        return;
      }
      setState(() => _showDenied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expires = AppDateTimeFormat.dateTime(widget.issue?.expiresAtUtc);
      final token = widget.issue?.token ?? '';
      final payload = token.isEmpty ? '' : 'fitcity://member?token=$token';
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.qrPassTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.membership),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: Center(
          child: Stack(
            children: [
              Container(
                width: 320,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.gymName ?? context.l10n.gymNameFallback,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(context.l10n.qrShowAtEntrance, style: const TextStyle(color: AppColors.accentDeep)),
                    const SizedBox(height: 16),
                    const Icon(Icons.fitness_center, color: AppColors.accentDeep, size: 36),
                    const SizedBox(height: 12),
                    Container(
                      height: 190,
                      width: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: token.isEmpty
                          ? Center(
                              child: Text(context.l10n.qrNotAvailable,
                                  style: const TextStyle(color: AppColors.muted)),
                            )
                          : QrImageView(
                              data: payload,
                              version: QrVersions.auto,
                              gapless: true,
                              backgroundColor: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(context.l10n.qrExpiryDate(expires), style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                if (_showSuccess)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.green, size: 64),
                        const SizedBox(height: 8),
                        Text(context.l10n.commonSuccess,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                          Text(context.l10n.commonEntered, style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ),
                if (_showDenied)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: AppColors.red, size: 64),
                          const SizedBox(height: 8),
                          Text(context.l10n.qrDeniedTitle,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(_deniedMessage ?? context.l10n.qrDeniedGeneric,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.red)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
    );
  }
}
