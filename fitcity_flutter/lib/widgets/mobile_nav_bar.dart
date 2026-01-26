import 'package:flutter/material.dart';
import '../services/fitcity_api.dart';
import '../theme/app_theme.dart';
import '../screens/mobile/mobile_gym_list_screen.dart';
import '../screens/mobile/mobile_active_membership_screen.dart';
import '../screens/mobile/mobile_bookings_screen.dart';
import '../screens/mobile/mobile_chat_screen.dart';
import '../screens/mobile/mobile_profile_screen.dart';
import '../screens/mobile/mobile_notifications_screen.dart';
import '../screens/mobile/mobile_schedule_screen.dart';
import '../screens/mobile/mobile_requests_screen.dart';

enum MobileNavItem {
  gyms,
  membership,
  bookings,
  schedule,
  requests,
  chat,
  profile,
  notifications,
}

class MobileNavBar extends StatelessWidget {
  final MobileNavItem current;

  const MobileNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final api = FitCityApi.instance;
    return ValueListenableBuilder(
      valueListenable: api.session,
      builder: (context, session, _) {
        final role = session?.user.role;
        final items = _itemsForRole(role);
        final currentIndex = items.indexWhere((item) => item.item == current);
        final safeIndex = currentIndex >= 0 ? currentIndex : 0;
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: safeIndex,
          selectedItemColor: AppColors.accentDeep,
          unselectedItemColor: AppColors.muted,
          onTap: (index) {
            final target = items[index].item;
            if (target == current) {
              return;
            }
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => _screenFor(target)),
              (route) => false,
            );
          },
          items: items
              .map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.label))
              .toList(),
        );
      },
    );
  }

  Widget _screenFor(MobileNavItem item) {
    switch (item) {
      case MobileNavItem.membership:
        return const MobileActiveMembershipScreen();
      case MobileNavItem.bookings:
        return const MobileBookingsScreen();
      case MobileNavItem.schedule:
        return const MobileScheduleScreen();
      case MobileNavItem.requests:
        return const MobileRequestsScreen();
      case MobileNavItem.chat:
        return const MobileChatScreen();
      case MobileNavItem.profile:
        return const MobileProfileScreen();
      case MobileNavItem.notifications:
        return const MobileNotificationsScreen();
      case MobileNavItem.gyms:
      default:
        return const MobileGymListScreen();
    }
  }

  List<_NavItemConfig> _itemsForRole(String? role) {
    if (role == 'Trainer') {
      return const [
        _NavItemConfig(MobileNavItem.schedule, Icons.calendar_today, 'Schedule'),
        _NavItemConfig(MobileNavItem.requests, Icons.assignment_outlined, 'Requests'),
        _NavItemConfig(MobileNavItem.chat, Icons.chat_bubble_outline, 'Chat'),
        _NavItemConfig(MobileNavItem.profile, Icons.person_outline, 'Profile'),
        _NavItemConfig(MobileNavItem.notifications, Icons.notifications_none, 'Alerts'),
      ];
    }
    return const [
      _NavItemConfig(MobileNavItem.gyms, Icons.fitness_center, 'Gyms'),
      _NavItemConfig(MobileNavItem.membership, Icons.card_membership, 'Pass'),
      _NavItemConfig(MobileNavItem.bookings, Icons.event_note, 'Bookings'),
      _NavItemConfig(MobileNavItem.chat, Icons.chat_bubble_outline, 'Chat'),
      _NavItemConfig(MobileNavItem.profile, Icons.person_outline, 'Profile'),
      _NavItemConfig(MobileNavItem.notifications, Icons.notifications_none, 'Alerts'),
    ];
  }
}

class _NavItemConfig {
  final MobileNavItem item;
  final IconData icon;
  final String label;

  const _NavItemConfig(this.item, this.icon, this.label);
}
