import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_qr_scan_screen.dart';

class MobileQrScreen extends StatelessWidget {
  final QrIssue? issue;
  final String? gymName;

  const MobileQrScreen({super.key, this.issue, this.gymName});

  @override
  Widget build(BuildContext context) {
    final expires = issue?.expiresAtUtc?.toLocal().toString() ?? '2025-12-31';
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'QR Code Pass'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.membership),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(gymName ?? 'FitCity Gym', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                const Text('Show this code at entrance', style: TextStyle(color: AppColors.accentDeep)),
                const SizedBox(height: 16),
                const Icon(Icons.fitness_center, color: AppColors.accentDeep, size: 36),
                const SizedBox(height: 12),
                Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    color: AppColors.slate,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(painter: _FakeQrPainter()),
                ),
                const SizedBox(height: 16),
                Text('Expiry Date: $expires', style: const TextStyle(color: AppColors.muted)),
                if (issue?.token != null) ...[
                  const SizedBox(height: 6),
                  Text('Token: ${issue!.token}', style: const TextStyle(color: AppColors.muted)),
                ],
                const SizedBox(height: 12),
                AccentButton(
                  label: 'Scan QR',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MobileQrScanScreen())),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    final cell = size.width / 10;
    for (var row = 0; row < 10; row++) {
      for (var col = 0; col < 10; col++) {
        final draw = (row + col) % 3 == 0 || (row - col).abs() == 3;
        if (draw) {
          canvas.drawRect(Rect.fromLTWH(col * cell, row * cell, cell * 0.9, cell * 0.9), paint);
        }
      }
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, cell * 2, cell * 2), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - cell * 2, 0, cell * 2, cell * 2), paint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - cell * 2, cell * 2, cell * 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
