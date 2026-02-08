import 'package:flutter/foundation.dart';
import '../data/fitcity_models.dart';
import 'fitcity_api.dart';

class GymSelectionStore {
  GymSelectionStore._();

  static final GymSelectionStore instance = GymSelectionStore._();

  final ValueNotifier<Gym?> currentGym = ValueNotifier<Gym?>(null);

  void selectGym(Gym gym) {
    currentGym.value = gym;
  }

  void clear() {
    currentGym.value = null;
  }

  Future<void> selectGymById(String gymId) async {
    final gym = await FitCityApi.instance.gymById(gymId);
    currentGym.value = gym;
  }
}
