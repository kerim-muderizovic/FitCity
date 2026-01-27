import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MockPhoneFrame extends StatelessWidget {
  final Widget child;

  const MockPhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 390,
        height: 780,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(36),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 12)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            color: AppColors.paper,
            child: child,
          ),
        ),
      ),
    );
  }
}

class DesktopFrame extends StatelessWidget {
  final Widget child;

  const DesktopFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 1100,
        height: 650,
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 10)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
