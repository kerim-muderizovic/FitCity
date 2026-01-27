import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_chat_screen.dart';

class MobileRequestsScreen extends StatelessWidget {
  const MobileRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Requests'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.requests),
      body: RoleGate(
        allowedRoles: const {'Trainer'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: AppColors.slate, child: Icon(Icons.person, color: AppColors.muted)),
                const SizedBox(height: 8),
                Text('Mike Tyson', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Postavite svoj cjenovnik', style: Theme.of(context).textTheme.bodyMedium),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MobileChatScreen()),
                  ),
                  child: const Text('Open chats', style: TextStyle(color: AppColors.accentDeep)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Cijena po treningu', style: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zahtjevi za trening', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _RequestTile(name: 'Ana', time: 'Aposo 20 AM'),
                      const SizedBox(height: 12),
                      _RequestTile(name: 'Ivan', time: 'Promoc 5:50 AM'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String name;
  final String time;

  const _RequestTile({required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
        AccentButton(label: 'Prihvati', onPressed: () {}),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentDeep,
            side: const BorderSide(color: AppColors.accentDeep),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Odbij'),
        ),
      ],
    );
  }
}
