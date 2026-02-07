import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_gym_detail_screen.dart';

class MobileBookingsScreen extends StatefulWidget {
  const MobileBookingsScreen({super.key});

  @override
  State<MobileBookingsScreen> createState() => _MobileBookingsScreenState();
}

class _MobileBookingsScreenState extends State<MobileBookingsScreen> {
  final FitCityApi _api = FitCityApi.instance;
  List<Booking> _upcoming = [];
  List<AccessLog> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final upcoming = await _api.bookings(status: 'upcoming');
      final entries = await _api.entryHistory();
      setState(() {
        _upcoming = upcoming;
        _entries = entries;
      });
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.bookingsTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.bookings),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    labelColor: AppColors.ink,
                    unselectedLabelColor: AppColors.muted,
                    indicatorColor: AppColors.accentDeep,
                    tabs: [
                      Tab(text: context.l10n.bookingsUpcomingTab),
                      Tab(text: context.l10n.bookingsEntryHistoryTab),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (_error != null)
                    Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.red))))
                  else
                    Expanded(
                      child: TabBarView(
                        children: [
                          _BookingList(bookings: _upcoming, emptyLabel: context.l10n.bookingsNoUpcoming),
                          _EntryHistoryList(entries: _entries),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyLabel;

  const _BookingList({required this.bookings, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(child: Text(emptyLabel, style: const TextStyle(color: AppColors.muted)));
    }
    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.bookingsStatusLabel(booking.status),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(context.l10n.bookingsTrainerLabel(booking.trainerName),
                  style: const TextStyle(color: AppColors.muted)),
              Text(context.l10n.bookingsGymLabel(booking.gymName ?? '-'),
                  style: const TextStyle(color: AppColors.muted)),
              Text(context.l10n.bookingsStartLabel(AppDateTimeFormat.dateTime(booking.startUtc)),
                  style: const TextStyle(color: AppColors.muted)),
              Text(context.l10n.bookingsPaymentLabel(booking.paymentStatus),
                  style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        );
      },
    );
  }
}

class _EntryHistoryList extends StatelessWidget {
  final List<AccessLog> entries;

  const _EntryHistoryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          context.l10n.bookingsNoEntries,
          style: const TextStyle(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final timeLabel = AppDateTimeFormat.dateTime(entry.checkedAtUtc);
        return GestureDetector(
          onTap: () {
            if (entry.gymId.isEmpty) {
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MobileGymDetailScreen(gymId: entry.gymId)),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2, color: AppColors.accentDeep),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.gymName.isEmpty ? context.l10n.bookingsGymEntry : entry.gymName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(timeLabel, style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                Text(context.l10n.bookingsEntered, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        );
      },
    );
  }
}
