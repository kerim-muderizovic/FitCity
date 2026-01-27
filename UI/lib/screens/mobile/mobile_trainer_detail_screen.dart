import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import 'mobile_booking_screen.dart';

class MobileTrainerDetailScreen extends StatelessWidget {
  final String trainerId;

  const MobileTrainerDetailScreen({super.key, required this.trainerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Trainer'),
      body: SafeArea(
        child: FutureBuilder<TrainerDetail>(
          future: FitCityApi.instance.trainerPublicDetail(trainerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString(), style: const TextStyle(color: AppColors.red)),
              );
            }
            final detail = snapshot.data;
            if (detail == null) {
              return const Center(child: Text('Trainer not found.'));
            }
            final trainer = detail.trainer;
            final session = FitCityApi.instance.session.value;
            final canBook = session?.user.role == 'User';
            final initialGymId = detail.gyms.isNotEmpty ? detail.gyms.first.id : null;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Text('Trainer', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                _TrainerHero(trainer: trainer),
                if (detail.gyms.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Work locations', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...detail.gyms.map(
                    (gym) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${gym.name} - ${gym.city}', style: const TextStyle(color: AppColors.muted)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (trainer.bio != null && trainer.bio!.isNotEmpty) ...[
                  Text('About', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(trainer.bio!, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 16),
                ],
                if (trainer.certifications != null && trainer.certifications!.isNotEmpty) ...[
                  Text('Certifications', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(trainer.certifications!, style: const TextStyle(color: AppColors.muted)),
                ],
                if (canBook) ...[
                  const SizedBox(height: 24),
                  AccentButton(
                    label: 'Book trainer',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MobileBookingScreen(
                            initialTrainerId: trainer.id,
                            initialGymId: initialGymId,
                            lockTrainer: true,
                          ),
                        ),
                      );
                    },
                    width: double.infinity,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrainerHero extends StatelessWidget {
  final Trainer trainer;

  const _TrainerHero({required this.trainer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.slate,
              child: trainer.photoUrl == null || trainer.photoUrl!.isEmpty
                  ? const Icon(Icons.person, color: AppColors.muted)
                  : Image.network(
                      trainer.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.muted),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                if (trainer.hourlyRate != null)
                  Text('${trainer.hourlyRate!.toStringAsFixed(0)} KM/hr', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

