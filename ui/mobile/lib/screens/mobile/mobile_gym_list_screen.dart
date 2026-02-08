import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:latlong2/latlong.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import 'mobile_gym_detail_screen.dart';
import 'mobile_map_screen.dart';
import 'mobile_trainer_detail_screen.dart';

class MobileGymListScreen extends StatefulWidget {
  const MobileGymListScreen({super.key});

  @override
  State<MobileGymListScreen> createState() => _MobileGymListScreenState();
}

class _MobileGymListScreenState extends State<MobileGymListScreen> {
  final _searchController = TextEditingController();
  List<Gym> _gyms = [];
  List<RecommendedTrainer> _recommendedTrainers = [];
  List<RecommendedGym> _recommendedGyms = [];
  bool _loading = true;
  bool _recommendationsLoading = true;
  bool _sortNearest = false;
  bool _locating = false;
  LatLng? _userLocation;
  final Map<String, double> _distanceByGym = {};
  String? _error;
  String? _recommendationError;
  String? _locationError;

  FitCityApi get _api => FitCityApi.instance;
  GymSelectionStore get _selection => GymSelectionStore.instance;

  @override
  void initState() {
    super.initState();
    _loadGyms();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGyms({String? search}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final gyms = await _api.gyms(search: search);
      setState(() => _gyms = gyms);
      if (_sortNearest && _userLocation != null) {
        _computeDistances(_userLocation!);
      }
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _recommendationsLoading = true;
      _recommendationError = null;
    });
    try {
      final results = await Future.wait([
        _api.recommendedTrainers(limit: 8),
        _api.recommendedGyms(limit: 8),
      ]);
      if (!mounted) return;
      setState(() {
        _recommendedTrainers = results[0] as List<RecommendedTrainer>;
        _recommendedGyms = results[1] as List<RecommendedGym>;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _recommendationError = mapApiError(context, error));
    } finally {
      if (!mounted) return;
      setState(() => _recommendationsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gyms = _sortedGyms();
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.commonGyms),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.gyms),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(context.l10n.gymListTitle('Sarajevo'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SectionTitle(title: context.l10n.gymListRecommendedTrainersTitle),
              const SizedBox(height: 8),
              if (_recommendationsLoading)
                const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
              else if (_recommendationError != null)
                Text(_recommendationError!, style: const TextStyle(color: AppColors.red))
              else if (_recommendedTrainers.isEmpty)
                Text(context.l10n.gymListNoTrainerRecommendations,
                    style: const TextStyle(color: AppColors.muted))
              else
                SizedBox(
                  height: 176,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommendedTrainers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final trainer = _recommendedTrainers[index];
                      return _RecommendedTrainerCard(
                        trainer: trainer,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MobileTrainerDetailScreen(trainerId: trainer.trainerId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              SectionTitle(title: context.l10n.gymListRecommendedGymsTitle),
              const SizedBox(height: 8),
              if (_recommendationsLoading)
                const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
              else if (_recommendationError != null)
                Text(_recommendationError!, style: const TextStyle(color: AppColors.red))
              else if (_recommendedGyms.isEmpty)
                Text(context.l10n.gymListNoGymRecommendations,
                    style: const TextStyle(color: AppColors.muted))
              else
                SizedBox(
                  height: 176,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommendedGyms.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final gym = _recommendedGyms[index];
                      return _RecommendedGymCard(
                        gym: gym,
                        onTap: () async {
                          try {
                            final fullGym = await _api.gymById(gym.gymId);
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MobileGymDetailScreen(gym: fullGym)),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mapApiError(context, error))),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: context.l10n.gymListSearchHint,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (value) => _loadGyms(search: value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _loadGyms(search: _searchController.text),
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _locating ? null : _toggleNearestSort,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentDeep,
                        side: const BorderSide(color: AppColors.accentDeep),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_locating
                          ? context.l10n.gymListLocating
                          : _sortNearest
                              ? context.l10n.gymListSortDefault
                              : context.l10n.gymListSortNearest),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AccentButton(
                label: context.l10n.gymListOpenMap,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileMapScreen()));
                },
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.red)),
              if (_locationError != null) Text(_locationError!, style: const TextStyle(color: AppColors.red)),
              if (!_loading && _error == null)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gyms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    final isCurrent = _selection.currentGym.value?.id == gym.id;
                    return _GymCard(
                      gym: gym,
                      distanceKm: _sortNearest ? _distanceByGym[gym.id] : null,
                      isCurrent: isCurrent,
                      onTap: () {
                        _selection.selectGym(gym);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MobileGymDetailScreen(gym: gym)),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleNearestSort() async {
    if (_sortNearest) {
      setState(() {
        _sortNearest = false;
        _locationError = null;
      });
      return;
    }
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _locationError = context.l10n.locationServicesDisabled);
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _locationError = context.l10n.locationPermissionDenied);
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final userLocation = LatLng(position.latitude, position.longitude);
      _computeDistances(userLocation);
      setState(() {
        _userLocation = userLocation;
        _sortNearest = true;
      });
    } catch (error) {
      setState(() => _locationError = mapApiError(context, error));
    } finally {
      setState(() => _locating = false);
    }
  }

  void _computeDistances(LatLng userLocation) {
    const sarajevoLat = 43.8563;
    const sarajevoLng = 18.4131;
    _distanceByGym.clear();
    const distance = Distance();
    for (final gym in _gyms) {
      final lat = gym.latitude ?? sarajevoLat;
      final lng = gym.longitude ?? sarajevoLng;
      final km = distance.as(LengthUnit.Kilometer, userLocation, LatLng(lat, lng));
      _distanceByGym[gym.id] = km;
    }
  }

  List<Gym> _sortedGyms() {
    if (!_sortNearest || _userLocation == null) {
      return _gyms;
    }
    final gyms = List<Gym>.from(_gyms);
    gyms.sort((a, b) {
      final distA = _distanceByGym[a.id];
      final distB = _distanceByGym[b.id];
      if (distA == null && distB == null) return 0;
      if (distA == null) return 1;
      if (distB == null) return -1;
      return distA.compareTo(distB);
    });
    return gyms;
  }
}

class _RecommendedTrainerCard extends StatelessWidget {
  final RecommendedTrainer trainer;
  final VoidCallback onTap;

  const _RecommendedTrainerCard({required this.trainer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = trainer.ratingAverage != null ? trainer.ratingAverage!.round() : 0;
    final reason = trainer.reasons.isNotEmpty ? trainer.reasons.first : null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(url: trainer.photoUrl, fallbackIcon: Icons.person),
            const SizedBox(height: 6),
            Text(
              trainer.trainerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            if (trainer.hourlyRate != null)
              Text(
                context.l10n.trainerRate(trainer.hourlyRate!.toStringAsFixed(0)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted),
              ),
            const SizedBox(height: 2),
            if (trainer.ratingCount > 0) StarRow(rating: rating),
            if (reason != null) ...[
              const SizedBox(height: 2),
              Text(
                reason,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.accentDeep, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendedGymCard extends StatelessWidget {
  final RecommendedGym gym;
  final VoidCallback onTap;

  const _RecommendedGymCard({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = gym.ratingAverage != null ? gym.ratingAverage!.round() : 0;
    final reason = gym.reasons.isNotEmpty ? gym.reasons.first : null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(url: gym.photoUrl, fallbackIcon: Icons.fitness_center),
            const SizedBox(height: 6),
            Text(
              gym.gymName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            if (gym.workHours != null)
              Text(
                gym.workHours!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            const SizedBox(height: 2),
            if (gym.ratingCount > 0) StarRow(rating: rating),
            if (reason != null) ...[
              const SizedBox(height: 2),
              Text(
                reason,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.accentDeep, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String? url;
  final IconData fallbackIcon;

  const _CardImage({this.url, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2.8,
        child: Container(
          width: double.infinity,
          color: AppColors.slate,
          child: url == null || url!.isEmpty
              ? Icon(fallbackIcon, color: AppColors.muted)
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: AppColors.muted),
                ),
        ),
      ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback onTap;
  final bool isCurrent;
  final double? distanceKm;

  const _GymCard({required this.gym, required this.onTap, required this.isCurrent, this.distanceKm});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _GymImage(photoUrl: gym.photoUrl, fallbackUrl: gym.photoUrls.isNotEmpty ? gym.photoUrls.first : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gym.address}, ${gym.city}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  if (gym.phoneNumber != null)
                    Text(
                      gym.phoneNumber!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  if (distanceKm != null)
                    Text(
                      context.l10n.gymListDistanceAway(distanceKm!.toStringAsFixed(1)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (isCurrent)
              const Icon(Icons.check_circle, color: AppColors.green)
            else
              const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _GymImage extends StatelessWidget {
  final String? photoUrl;
  final String? fallbackUrl;

  const _GymImage({this.photoUrl, this.fallbackUrl});

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl != null && photoUrl!.isNotEmpty) ? photoUrl : fallbackUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        color: AppColors.slate,
        child: url == null || url.isEmpty
            ? const Icon(Icons.fitness_center, color: AppColors.muted)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppColors.muted),
              ),
      ),
    );
  }
}
