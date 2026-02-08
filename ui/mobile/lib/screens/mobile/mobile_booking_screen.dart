import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/gym_guard.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_booking_confirmation_screen.dart';
import 'mobile_bookings_screen.dart';

class MobileBookingScreen extends StatefulWidget {
  final String? initialTrainerId;
  final String? initialGymId;
  final bool lockTrainer;

  const MobileBookingScreen({
    super.key,
    this.initialTrainerId,
    this.initialGymId,
    this.lockTrainer = false,
  });

  @override
  State<MobileBookingScreen> createState() => _MobileBookingScreenState();
}

class _MobileBookingScreenState extends State<MobileBookingScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final GymSelectionStore _selection = GymSelectionStore.instance;
  late final VoidCallback _selectionListener;
  List<Gym> _gyms = [];
  Gym? _selectedGym;
  List<Trainer> _trainers = [];
  Trainer? _selectedTrainer;
  TrainerDetail? _trainerDetail;
  TrainerScheduleResponse? _availability;
  TrainerSchedule? _selectedSlot;
  String? _selectedSlotKey;
  String? _statusMessage;
  bool _loading = true;
  bool _loadingAvailability = false;
  bool _loadingTrainerDetail = false;
  late final DateTime _rangeStartUtc;
  late final DateTime _rangeEndUtc;
  late DateTime _selectedDate;
  String _paymentMethod = 'Card';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    _rangeStartUtc = DateTime.utc(now.year, now.month, now.day);
    _rangeEndUtc = _rangeStartUtc.add(const Duration(days: 14));
    _selectedDate = DateTime.now();
    _selectionListener = () {
      final gym = _selection.currentGym.value;
      if (gym == null) {
        setState(() => _selectedGym = null);
        return;
      }
      if (_gyms.isNotEmpty) {
        final match = _gyms.firstWhere((g) => g.id == gym.id, orElse: () => gym);
        setState(() => _selectedGym = match);
        _loadTrainers();
      }
    };
    _selection.currentGym.addListener(_selectionListener);
    _loadGyms();
  }

  @override
  void dispose() {
    _selection.currentGym.removeListener(_selectionListener);
    super.dispose();
  }

  Future<void> _loadGyms() async {
    setState(() => _loading = true);
    try {
      final gyms = await _api.gyms();
      setState(() {
        _gyms = gyms;
        if (gyms.isEmpty) {
          _selectedGym = null;
        } else if (widget.initialGymId != null) {
          _selectedGym = gyms.firstWhere(
            (g) => g.id == widget.initialGymId,
            orElse: () => gyms.first,
          );
        } else {
          final current = _selection.currentGym.value;
          if (current != null) {
            _selectedGym = gyms.firstWhere((g) => g.id == current.id, orElse: () => gyms.first);
          } else {
            _selectedGym = gyms.first;
          }
        }
      });
      if (_selectedGym != null) {
        _selection.selectGym(_selectedGym!);
      }
      await _loadTrainers();
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadTrainers() async {
    if (_selectedGym == null) {
      return;
    }
    final trainers = await _api.trainersByGym(_selectedGym!.id);
    setState(() {
      _trainers = _dedupeTrainers(trainers);
      _selectedTrainer = _resolveSelectedTrainer(_trainers);
    });
    await _loadTrainerDetail();
    await _loadAvailability();
  }

  Future<void> _loadTrainerDetail() async {
    final trainer = _selectedTrainer;
    if (trainer == null) {
      setState(() => _trainerDetail = null);
      return;
    }
    setState(() => _loadingTrainerDetail = true);
    try {
      final detail = await _api.trainerPublicDetail(trainer.id);
      setState(() => _trainerDetail = detail);
      final gyms = detail.gyms;
      if (gyms.isNotEmpty) {
        final current = _selectedGym;
        if (current == null || !gyms.any((g) => g.id == current.id)) {
          setState(() => _selectedGym = gyms.first);
          _selection.selectGym(gyms.first);
        }
      }
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    } finally {
      setState(() => _loadingTrainerDetail = false);
    }
  }

  Future<void> _loadAvailability() async {
    if (_selectedTrainer == null) {
      setState(() {
        _availability = null;
        _setSelectedSlot(null);
      });
      return;
    }
    setState(() {
      _loadingAvailability = true;
      _availability = null;
      _setSelectedSlot(null);
    });
    try {
      final availability = await _api.trainerAvailability(
        trainerId: _selectedTrainer!.id,
        fromUtc: _rangeStartUtc,
        toUtc: _rangeEndUtc,
      );
      setState(() {
        _availability = availability;
        _setSelectedSlot(_firstAvailableSlot(availability));
      });
    } catch (error) {
      if (error is FitCityApiException && error.statusCode == 404) {
        setState(() {
          _statusMessage = context.l10n.bookingTrainerNotFound;
          _availability = null;
          _setSelectedSlot(null);
        });
      } else {
        setState(() => _statusMessage = mapApiError(context, error));
      }
    } finally {
      setState(() => _loadingAvailability = false);
    }
  }

  Future<void> _createBooking() async {
    if (_selectedTrainer == null || _selectedSlot == null) {
      setState(() => _statusMessage = context.l10n.bookingSelectSlotFirst);
      return;
    }
    try {
      final gymId = _resolveBookingGymId();
      final booking = await _api.createBooking(
        trainerId: _selectedTrainer!.id,
        gymId: gymId,
        startUtc: _selectedSlot!.startUtc,
        endUtc: _selectedSlot!.endUtc,
        paymentMethod: _paymentMethod,
      );
      if (!mounted) {
        return;
      }
      await _loadAvailability();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MobileBookingConfirmationScreen(
            booking: booking,
            trainerName: _selectedTrainer?.userName,
            gymName: _selectedGym?.name,
          ),
        ),
      );
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymsForDropdown = _dedupeGyms((_trainerDetail?.gyms.isNotEmpty == true) ? _trainerDetail!.gyms : _gyms);
    final selectedGymForDropdown = _resolveSelectedGym(gymsForDropdown, _selectedGym?.id);
    final trainersForDropdown = _dedupeTrainers(_trainers);
    final selectedTrainerForDropdown = _resolveSelectedTrainer(trainersForDropdown);
    final selectedGymId = selectedGymForDropdown?.id;
    final selectedTrainerId = selectedTrainerForDropdown?.id;
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.bookingScreenTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.bookings),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: GymGuard(
          message: context.l10n.bookingSelectGymMessage,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.bookingScreenTitle, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const CurrentGymIndicator(),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedGymId,
                          items: gymsForDropdown
                              .map((gym) => DropdownMenuItem<String>(
                                    value: gym.id,
                                    child: Text(gym.name),
                                  ))
                              .toList(),
                          onChanged: (gymId) async {
                            if (gymId == null) {
                              return;
                            }
                            final gym = gymsForDropdown.firstWhere((g) => g.id == gymId, orElse: () => gymsForDropdown.first);
                            _selection.selectGym(gym);
                            setState(() => _selectedGym = gym);
                            await _loadTrainers();
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.bookingLocationLabel,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedTrainerId,
                          items: trainersForDropdown
                              .map((trainer) => DropdownMenuItem<String>(
                                    value: trainer.id,
                                    child: Text(_trainerLabel(trainer)),
                                  ))
                              .toList(),
                          onChanged: widget.lockTrainer
                              ? null
                              : (trainerId) async {
                                  if (trainerId == null) {
                                    return;
                                  }
                                  final trainer = trainersForDropdown.firstWhere(
                                    (t) => t.id == trainerId,
                                    orElse: () => trainersForDropdown.first,
                                  );
                                  setState(() => _selectedTrainer = trainer);
                                  await _loadTrainerDetail();
                                  await _loadAvailability();
                                },
                          decoration: InputDecoration(
                            labelText: context.l10n.bookingTrainerLabel,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _loadingTrainerDetail ? null : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: _rangeStartUtc.toLocal(),
                                    lastDate: _rangeEndUtc.toLocal().subtract(const Duration(days: 1)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDate = picked;
                                      _setSelectedSlot(null);
                                    });
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accentDeep,
                                  side: const BorderSide(color: AppColors.accentDeep),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(context.l10n.bookingDateLabel(
                                  AppDateTimeFormat.date(_selectedDate),
                                )),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButton<String>(
                                  value: _paymentMethod,
                                  underline: const SizedBox.shrink(),
                                  items: [
                                    DropdownMenuItem(value: 'Card', child: Text(context.l10n.bookingPaymentCard)),
                                    DropdownMenuItem(value: 'Cash', child: Text(context.l10n.bookingPaymentCash)),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() => _paymentMethod = value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(context.l10n.bookingAvailableSlots,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Expanded(child: _buildSlotList()),
                        const SizedBox(height: 12),
                        AccentButton(
                          label: _selectedSlot == null
                              ? context.l10n.bookingSelectSlot
                              : context.l10n.bookingCreate,
                          onPressed: _selectedSlot == null ? null : _createBooking,
                          width: double.infinity,
                        ),
                        if (_statusMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
                        ],
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MobileBookingsScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentDeep,
                            side: const BorderSide(color: AppColors.accentDeep),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(context.l10n.bookingViewAll),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotList() {
    if (_loadingAvailability) {
      return const Center(child: CircularProgressIndicator());
    }
    final slots = _filteredSlots();
    if (slots.isEmpty) {
      final availability = _availability;
      final hasAnySlots = availability != null && availability.schedules.any((slot) => slot.isAvailable);
      final reason = availability?.reason;
      final message = hasAnySlots
          ? context.l10n.bookingNoSlotsDate
          : (reason != null && reason.isNotEmpty ? reason : context.l10n.bookingNoSlotsRange);
      return Center(child: Text(message, style: const TextStyle(color: AppColors.muted)));
    }
    return ListView.separated(
      itemCount: slots.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isAvailable = slot.isAvailable;
        final isSelected = _selectedSlotKey == _slotKey(slot);
        final startLocal = slot.startUtc.toLocal();
        final endLocal = slot.endUtc.toLocal();
        final label = AppDateTimeFormat.range(startLocal, endLocal);
        return ListTile(
          title: Text(label),
          subtitle: Text(isAvailable ? context.l10n.bookingSlotAvailable : context.l10n.bookingSlotBooked,
              style: const TextStyle(color: AppColors.muted)),
          trailing: isAvailable
              ? Icon(isSelected ? Icons.check_circle : Icons.check_circle_outline, color: AppColors.accentDeep)
              : const Icon(Icons.lock, color: AppColors.muted),
          onTap: isAvailable
              ? () {
                  setState(() {
                    if (isSelected) {
                      _setSelectedSlot(null);
                    } else {
                      _setSelectedSlot(slot);
                    }
                  });
                }
              : null,
        );
      },
    );
  }

  List<TrainerSchedule> _filteredSlots() {
    final availability = _availability;
    if (availability == null) {
      return [];
    }
    final gymId = _selectedGym?.id;
    final slots = availability.schedules
        .where((slot) => gymId == null || slot.gymId == null || slot.gymId == gymId)
        .where((slot) => _isSameDate(slot.startUtc.toLocal(), _selectedDate))
        .toList();
    slots.sort((a, b) => a.startUtc.compareTo(b.startUtc));
    return slots;
  }

  TrainerSchedule? _firstAvailableSlot(TrainerScheduleResponse availability) {
    final gymId = _selectedGym?.id;
    for (final slot in availability.schedules) {
      final matchesGym = gymId == null || slot.gymId == null || slot.gymId == gymId;
      final matchesDate = _isSameDate(slot.startUtc.toLocal(), _selectedDate);
      if (matchesGym && matchesDate && slot.isAvailable) {
        return slot;
      }
    }
    return null;
  }

  void _setSelectedSlot(TrainerSchedule? slot) {
    _selectedSlot = slot;
    _selectedSlotKey = slot == null ? null : _slotKey(slot);
  }

  String _slotKey(TrainerSchedule slot) {
    return '${slot.startUtc.toIso8601String()}-${slot.endUtc.toIso8601String()}-${slot.gymId ?? ''}';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _trainerLabel(Trainer trainer) {
    final rate = trainer.hourlyRate;
    if (rate == null) {
      return trainer.userName;
    }
    return context.l10n.bookingTrainerRateLabel(trainer.userName, rate.toStringAsFixed(0));
  }

  Trainer? _resolveSelectedTrainer(List<Trainer> trainers) {
    if (trainers.isEmpty) {
      return null;
    }
    if (widget.initialTrainerId == null) {
      return _selectedTrainer != null
          ? trainers.firstWhere((t) => t.id == _selectedTrainer!.id, orElse: () => trainers.first)
          : trainers.first;
    }
    return trainers.firstWhere(
      (t) => t.id == widget.initialTrainerId,
      orElse: () => trainers.first,
    );
  }

  String? _resolveBookingGymId() {
    final gyms = _trainerDetail?.gyms ?? [];
    if (gyms.isEmpty) {
      return null;
    }
    final selectedId = _selectedGym?.id;
    if (selectedId == null || selectedId.isEmpty) {
      return gyms.first.id;
    }
    return gyms.any((g) => g.id == selectedId) ? selectedId : gyms.first.id;
  }

  Gym? _resolveSelectedGym(List<Gym> gyms, String? selectedGymId) {
    if (gyms.isEmpty) {
      return null;
    }
    if (selectedGymId == null || selectedGymId.isEmpty) {
      return gyms.first;
    }
    return gyms.firstWhere((g) => g.id == selectedGymId, orElse: () => gyms.first);
  }

  List<Gym> _dedupeGyms(List<Gym> gyms) {
    final map = <String, Gym>{};
    for (final gym in gyms) {
      map.putIfAbsent(gym.id, () => gym);
    }
    return map.values.toList();
  }

  List<Trainer> _dedupeTrainers(List<Trainer> trainers) {
    final map = <String, Trainer>{};
    for (final trainer in trainers) {
      map.putIfAbsent(trainer.id, () => trainer);
    }
    return map.values.toList();
  }
}
