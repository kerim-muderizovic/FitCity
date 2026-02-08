import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';

class MobileRecommendedScreen extends StatelessWidget {
  const MobileRecommendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.recommendedTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.gyms),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.recommendedTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const _RecommendationCard(name: 'Emma Johnson', type: 'Strength Training', price: '\$50', rating: 5),
              const SizedBox(height: 12),
              const _RecommendationCard(name: 'Mark Williams', type: 'Cardio', price: '\$60', rating: 4),
              const SizedBox(height: 12),
              const _RecommendationCard(name: 'Alexandra Lee', type: 'Yoga', price: '\$70', rating: 5),
              const SizedBox(height: 12),
              _RecommendationCard(
                name: 'Jason Smith',
                type: 'Strength Training',
                price: '\$55',
                rating: 4,
                highlight: context.l10n.notificationNew,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String name;
  final String type;
  final String price;
  final int rating;
  final String? highlight;

  const _RecommendationCard({required this.name, required this.type, required this.price, required this.rating, this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundColor: AppColors.slate, child: Icon(Icons.person, color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (highlight != null) ...[
                      const SizedBox(width: 8),
                      CircleBadge(color: AppColors.accentDeep, label: highlight!),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(color: AppColors.accentDeep)),
                const SizedBox(height: 4),
                StarRow(rating: rating),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
