import 'package:flutter/material.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/gym_guard.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_qr_scan_result_screen.dart';
import '../../data/fitcity_models.dart';

class MobileQrScanScreen extends StatefulWidget {
  const MobileQrScanScreen({super.key});

  @override
  State<MobileQrScanScreen> createState() => _MobileQrScanScreenState();
}

class _MobileQrScanScreenState extends State<MobileQrScanScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final GymSelectionStore _selection = GymSelectionStore.instance;
  late final VoidCallback _selectionListener;
  final TextEditingController _tokenController = TextEditingController(text: 'token-hash-1');
  List<Gym> _gyms = [];
  Gym? _selectedGym;
  String? _statusMessage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectionListener = () {
      final gym = _selection.currentGym.value;
      if (gym == null || _gyms.isEmpty) {
        return;
      }
      final match = _gyms.firstWhere((g) => g.id == gym.id, orElse: () => gym);
      setState(() => _selectedGym = match);
    };
    _selection.currentGym.addListener(_selectionListener);
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    try {
      final gyms = await _api.gyms();
      if (!mounted) {
        return;
      }
      setState(() {
        _gyms = gyms;
        final current = _selection.currentGym.value;
        if (current != null) {
          _selectedGym = gyms.firstWhere((g) => g.id == current.id, orElse: () => gyms.first);
        } else {
          _selectedGym = gyms.isNotEmpty ? gyms.first : null;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _selection.currentGym.removeListener(_selectionListener);
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _scanToken() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      final result = await _api.validateQr(
        _tokenController.text.trim(),
        gymId: _selectedGym?.id,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MobileQrScanResultScreen(result: result)),
      );
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymsForDropdown = _dedupeGyms(_gyms);
    final selectedGymId = _selectedGym?.id;
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'QR Scan'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.membership),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: GymGuard(
          message: 'Select a gym before scanning a QR pass.',
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QR Scan', style: Theme.of(context).textTheme.titleMedium),
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
                      labelText: 'Gym',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'Token',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AccentButton(
                    label: _loading ? 'Scanning...' : 'Scan',
                    onPressed: _loading ? null : _scanToken,
                    width: double.infinity,
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Use seeded token token-hash-1 to test a successful scan.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
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
