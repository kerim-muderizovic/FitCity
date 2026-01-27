import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import 'mobile_gym_detail_screen.dart';

class MobileMapScreen extends StatefulWidget {
  const MobileMapScreen({super.key});

  @override
  State<MobileMapScreen> createState() => _MobileMapScreenState();
}

class _MobileMapScreenState extends State<MobileMapScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final GymSelectionStore _selection = GymSelectionStore.instance;
  final LatLng _sarajevoCenter = const LatLng(43.8563, 18.4131);
  final MapController _mapController = MapController();
  List<Gym> _gyms = [];
  Gym? _selectedGym;
  bool _loading = true;
  String? _error;
  LatLng? _myLocation;
  bool _locating = false;
  String? _locationError;


  @override
  void initState() {
    super.initState();
    _loadGyms();
    _loadLastKnownLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestMyLocation());
  }

  Future<void> _loadGyms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final gyms = await _api.gyms();
      setState(() {
        _gyms = gyms;
        final current = _selection.currentGym.value;
        if (_gyms.isEmpty) {
          _selectedGym = null;
        } else if (current != null) {
          _selectedGym = _gyms.firstWhere((g) => g.id == current.id, orElse: () => _gyms.first);
        } else {
          _selectedGym = _gyms.isNotEmpty ? _gyms.first : null;
        }
      });
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  LatLng? _positionForGym(Gym gym) {
    final lat = gym.latitude;
    final lng = gym.longitude;
    if (lat == null || lng == null) {
      return null;
    }
    return LatLng(lat, lng);
  }

  Future<void> _loadLastKnownLocation() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null || !mounted) {
        return;
      }
      setState(() => _myLocation = LatLng(last.latitude, last.longitude));
    } catch (_) {}
  }

  Future<void> _requestMyLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) {
        return;
      }
      setState(() => _myLocation = LatLng(position.latitude, position.longitude));
      _centerOnMe();
    } catch (error) {
      if (mounted) {
        setState(() => _locationError = error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_locationError!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  void _centerOnMe() {
    final location = _myLocation;
    if (location == null) {
      return;
    }
    _mapController.move(location, 14);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedGym;
    final markers = _gyms
        .where((gym) => _positionForGym(gym) != null)
        .map(
          (gym) => Marker(
            point: _positionForGym(gym)!,
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedGym = gym);
                _selection.selectGym(gym);
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.location_on, color: gym == selected ? AppColors.accentDeep : AppColors.muted),
              ),
            ),
          ),
        )
        .toList();
    if (_myLocation != null) {
      markers.add(
        Marker(
          point: _myLocation!,
          width: 46,
          height: 46,
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accentDeep,
            child: Icon(Icons.my_location, color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Map'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.gyms),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text(_error!, style: const TextStyle(color: AppColors.red)))
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _sarajevoCenter,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'fitcity_flutter',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('FitCity Map', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const CurrentGymIndicator(),
                  if (_locationError != null) ...[
                    const SizedBox(height: 8),
                    Text(_locationError!, style: const TextStyle(color: AppColors.red)),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: selected != null ? 160 : 20,
            child: FloatingActionButton(
              onPressed: _locating ? null : (_myLocation == null ? _requestMyLocation : _centerOnMe),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accentDeep,
              child: _locating ? const CircularProgressIndicator() : const Icon(Icons.my_location),
            ),
          ),
          if (!_loading && selected != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccentButton(
                      label: 'Open ${selected.name}',
                      onPressed: () {
                        _selection.selectGym(selected);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MobileGymDetailScreen(gym: selected)),
                        );
                      },
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: AppColors.slate,
                              child: _thumbnailFor(selected) == null
                                  ? const Icon(Icons.fitness_center, color: AppColors.muted)
                                  : Image.network(
                                      _thumbnailFor(selected)!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppColors.muted),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selected.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(selected.address, style: const TextStyle(color: AppColors.muted)),
                                const SizedBox(height: 4),
                                Text(selected.city, style: const TextStyle(color: AppColors.accentDeep)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _thumbnailFor(Gym gym) {
    if (gym.photoUrl != null && gym.photoUrl!.isNotEmpty) {
      return gym.photoUrl;
    }
    if (gym.photoUrls.isNotEmpty) {
      return gym.photoUrls.first;
    }
    return null;
  }
}
