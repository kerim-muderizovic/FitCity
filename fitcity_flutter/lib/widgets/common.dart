import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;

  const AccentButton({super.key, required this.label, this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(color: AppColors.accentDeep)),
          ),
      ],
    );
  }
}

class StarRow extends StatelessWidget {
  final int rating;

  const StarRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          size: 14,
          color: index < rating ? AppColors.accent : AppColors.slate,
        ),
      ),
    );
  }
}

class CircleBadge extends StatelessWidget {
  final Color color;
  final String label;

  const CircleBadge({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
