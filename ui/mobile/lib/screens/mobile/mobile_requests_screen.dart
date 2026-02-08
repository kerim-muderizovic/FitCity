import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_chat_screen.dart';

class MobileRequestsScreen extends StatefulWidget {
  const MobileRequestsScreen({super.key});

  @override
  State<MobileRequestsScreen> createState() => _MobileRequestsScreenState();
}

class _MobileRequestsScreenState extends State<MobileRequestsScreen> {
  final FitCityApi _api = FitCityApi.instance;
  Trainer? _trainer;
  TrainerScheduleResponse? _schedule;
  bool _loading = true;
  String? _error;
  final Set<String> _busyRequests = {};
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _load();
    _poller = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) {
        return;
      }
      _refreshRequests();
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.trainerMeProfile(),
        _api.trainerSchedule(),
      ]);
      setState(() {
        _trainer = results[0] as Trainer;
        _schedule = results[1] as TrainerScheduleResponse;
      });
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshRequests() async {
    try {
      final schedule = await _api.trainerSchedule();
      if (mounted) {
        setState(() => _schedule = schedule);
      }
    } catch (_) {
      // Silent refresh failure to avoid UI noise.
    }
  }

  Future<void> _decide(Booking booking, bool confirm) async {
    setState(() => _busyRequests.add(booking.id));
    try {
      await _api.updateBookingStatus(bookingId: booking.id, confirm: confirm);
      await _refreshRequests();
    } catch (error) {
      if (mounted) {
        setState(() => _error = mapApiError(context, error));
      }
    } finally {
      if (mounted) {
        setState(() => _busyRequests.remove(booking.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _api.session.value;
    final trainer = _trainer;
    final rate = trainer?.hourlyRate;
    final requests = (_schedule?.sessions ?? [])
        .where((booking) => booking.status.toLowerCase() == 'pending')
        .toList()
      ..sort((a, b) => a.startUtc.compareTo(b.startUtc));

    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.requestsTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.requests),
      body: RoleGate(
        allowedRoles: const {'Trainer'},
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshRequests,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.slate,
                      child: Icon(Icons.person, color: AppColors.muted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session?.user.fullName ?? context.l10n.commonTrainer,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(session?.user.email ?? '', style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MobileChatScreen()),
                      ),
                      child: Text(context.l10n.requestsOpenChats,
                          style: const TextStyle(color: AppColors.accentDeep)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    rate != null
                        ? context.l10n.trainerHourlyRate(rate.toStringAsFixed(0))
                        : context.l10n.trainerHourlyRateNotSet,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: const TextStyle(color: AppColors.red)),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.requestsTitle, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        if (requests.isEmpty)
                          Text(context.l10n.requestsEmpty, style: const TextStyle(color: AppColors.muted))
                        else
                          ...requests.map((booking) {
                            final startLocal = booking.startUtc.toLocal();
                            final endLocal = booking.endUtc.toLocal();
                            final timeLabel = AppDateTimeFormat.range(startLocal, endLocal);
                            final busy = _busyRequests.contains(booking.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RequestTile(
                                title: booking.gymName?.isNotEmpty == true
                                    ? booking.gymName!
                                    : context.l10n.requestsTrainingSession,
                                time: timeLabel,
                                busy: busy,
                                onAccept: busy ? null : () => _decide(booking, true),
                                onReject: busy ? null : () => _decide(booking, false),
                              ),
                            );
                          }),
                      ],
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

class _RequestTile extends StatelessWidget {
  final String title;
  final String time;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool busy;

  const _RequestTile({
    required this.title,
    required this.time,
    required this.onAccept,
    required this.onReject,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
        AccentButton(label: busy ? context.l10n.commonWorking : context.l10n.commonAccept, onPressed: onAccept),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: onReject,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentDeep,
            side: const BorderSide(color: AppColors.accentDeep),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(context.l10n.requestsDecline),
        ),
      ],
    );
  }
}
