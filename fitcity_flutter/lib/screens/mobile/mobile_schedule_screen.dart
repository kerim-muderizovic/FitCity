import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_requests_screen.dart';

class MobileScheduleScreen extends StatefulWidget {
  const MobileScheduleScreen({super.key});

  @override
  State<MobileScheduleScreen> createState() => _MobileScheduleScreenState();
}

class _MobileScheduleScreenState extends State<MobileScheduleScreen> {
  final FitCityApi _api = FitCityApi.instance;
  TrainerScheduleResponse? _schedule;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final schedule = await _api.trainerSchedule();
      setState(() => _schedule = schedule);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _api.session.value;
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Schedule'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.schedule),
      body: RoleGate(
        allowedRoles: const {'Trainer'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.slate,
                      child: Icon(Icons.person, color: AppColors.muted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session?.user.fullName ?? 'Trainer', style: Theme.of(context).textTheme.titleMedium),
                          Text(session?.user.email ?? '', style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MobileRequestsScreen()),
                      ),
                      child: const Text('Training requests', style: TextStyle(color: AppColors.accentDeep)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.red))))
                else
                  Expanded(child: _ScheduleList(schedule: _schedule)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final TrainerScheduleResponse? schedule;

  const _ScheduleList({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final data = schedule;
    if (data == null || data.schedules.isEmpty) {
      return const Center(child: Text('No schedule entries yet.', style: TextStyle(color: AppColors.muted)));
    }
    final sessions = data.sessions;
    return ListView.separated(
      itemCount: data.schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final slot = data.schedules[index];
        final isBooked = sessions.any((session) {
          return _overlaps(slot.startUtc, slot.endUtc, session.startUtc, session.endUtc);
        });
        final status = isBooked ? 'Booked' : (slot.isAvailable ? 'Available' : 'Blocked');
        final color = isBooked
            ? AppColors.red
            : slot.isAvailable
                ? AppColors.green
                : AppColors.muted;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleBadge(color: color, label: status),
              const SizedBox(height: 6),
              Text(
                '${slot.startUtc.toLocal()} - ${slot.endUtc.toLocal()}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (slot.gymId != null) ...[
                const SizedBox(height: 4),
                Text('Gym: ${slot.gymId}', style: const TextStyle(color: AppColors.muted)),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }
}
