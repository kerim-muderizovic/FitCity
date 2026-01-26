import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_active_membership_screen.dart';

class MobileMembershipScreen extends StatefulWidget {
  const MobileMembershipScreen({super.key});

  @override
  State<MobileMembershipScreen> createState() => _MobileMembershipScreenState();
}

class _MobileMembershipScreenState extends State<MobileMembershipScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final GymSelectionStore _selection = GymSelectionStore.instance;
  late final VoidCallback _selectionListener;
  List<Gym> _gyms = [];
  Gym? _selectedGym;
  List<Membership> _memberships = [];
  String? _statusMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectionListener = () {
      final gym = _selection.currentGym.value;
      if (gym == null) {
        return;
      }
      if (_gyms.isNotEmpty) {
        final match = _gyms.firstWhere((g) => g.id == gym.id, orElse: () => gym);
        setState(() => _selectedGym = match);
      }
    };
    _selection.currentGym.addListener(_selectionListener);
    _loadData();
  }

  @override
  void dispose() {
    _selection.currentGym.removeListener(_selectionListener);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final gyms = await _api.gyms();
      final memberships = await _api.memberships();
      setState(() {
        _gyms = gyms;
        _memberships = memberships;
        final current = _selection.currentGym.value;
        if (current != null) {
          _selectedGym = gyms.firstWhere((g) => g.id == current.id, orElse: () => gyms.first);
        } else if (_selectedGym == null && gyms.isNotEmpty) {
          _selectedGym = gyms.first;
        }
      });
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _requestMembership() async {
    if (_selectedGym == null) {
      return;
    }
    try {
      final response = await _api.requestMembership(gymId: _selectedGym!.id);
      setState(() => _statusMessage = 'Request status: ${response.status}');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  Future<void> _issueQr(String membershipId) async {
    try {
      final qr = await _api.issueQr(membershipId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR token: ${qr.token}')),
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

  @override
  Widget build(BuildContext context) {
    final session = _api.session.value;
    final gymsForDropdown = _dedupeGyms(_gyms);
    final selectedGymId = _selectedGym?.id;
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Memberships'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.membership),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Memberships', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Signed in as ${session?.user.email ?? '-'}', style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 12),
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
                      onChanged: (gymId) {
                        if (gymId == null) {
                          return;
                        }
                        final gym = gymsForDropdown.firstWhere((g) => g.id == gymId, orElse: () => gymsForDropdown.first);
                        _selection.selectGym(gym);
                        setState(() => _selectedGym = gym);
                      },
                      decoration: InputDecoration(
                        labelText: 'Select gym',
                        filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const MobileActiveMembershipScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentDeep,
                          side: const BorderSide(color: AppColors.accentDeep),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('View active pass'),
                      ),
                      const SizedBox(height: 12),
                      AccentButton(
                        label: 'Request membership',
                        onPressed: _requestMembership,
                        width: double.infinity,
                      ),
                      if (_statusMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
                      ],
                      const SizedBox(height: 16),
                      Text('Active memberships', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _memberships.isEmpty
                            ? const Text('No memberships found.', style: TextStyle(color: AppColors.muted))
                            : ListView.separated(
                                itemCount: _memberships.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final membership = _memberships[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Membership ${membership.status}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text('Gym ID: ${membership.gymId}', style: const TextStyle(color: AppColors.muted)),
                                        const SizedBox(height: 4),
                                        Text('Valid until: ${membership.endDateUtc.toLocal()}',
                                            style: const TextStyle(color: AppColors.muted)),
                                        const SizedBox(height: 10),
                                        AccentButton(
                                          label: 'Issue QR code',
                                          onPressed: () => _issueQr(membership.id),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  List<Gym> _dedupeGyms(List<Gym> gyms) {
    final map = <String, Gym>{};
    for (final gym in gyms) {
      map.putIfAbsent(gym.id, () => gym);
    }
    return map.values.toList();
  }
}
