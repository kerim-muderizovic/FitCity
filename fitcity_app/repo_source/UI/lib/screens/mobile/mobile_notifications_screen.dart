import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../services/notifications_socket.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';

class MobileNotificationsScreen extends StatefulWidget {
  const MobileNotificationsScreen({super.key});

  @override
  State<MobileNotificationsScreen> createState() => _MobileNotificationsScreenState();
}

class _MobileNotificationsScreenState extends State<MobileNotificationsScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final NotificationsSocketService _socket = NotificationsSocketService.instance;
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;
  late final void Function(Map<String, dynamic>) _notificationHandler;

  @override
  void initState() {
    super.initState();
    _notificationHandler = _handleNotification;
    _loadNotifications();
    _connectSocket();
  }

  @override
  void dispose() {
    _socket.offNotificationNew(_notificationHandler);
    super.dispose();
  }

  Future<void> _connectSocket() async {
    await _socket.connect();
    _socket.onNotificationNew(_notificationHandler);
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.notifications();
      setState(() => _notifications = items);
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleNotification(Map<String, dynamic> payload) {
    final notification = AppNotification.fromJson(payload);
    if (!mounted) {
      return;
    }
    setState(() => _notifications = [notification, ..._notifications]);
  }

  Future<void> _markRead(AppNotification notification) async {
    await _api.markNotificationRead(notification.id);
    setState(() {
      _notifications = _notifications
          .map((item) => item.id == notification.id
              ? AppNotification(
                  id: item.id,
                  title: item.title,
                  message: item.message,
                  category: item.category,
                  isRead: true,
                  createdAtUtc: item.createdAtUtc,
                )
              : item)
          .toList();
    });
  }

  Future<void> _markAllRead() async {
    await _api.markAllNotificationsRead();
    setState(() {
      _notifications = _notifications
          .map((item) => AppNotification(
                id: item.id,
                title: item.title,
                message: item.message,
                category: item.category,
                isRead: true,
                createdAtUtc: item.createdAtUtc,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.notificationsTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.notifications),
      body: RoleGate(
        allowedRoles: const {'User', 'Trainer'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.l10n.notificationsTitle, style: Theme.of(context).textTheme.titleMedium),
                    TextButton(
                      onPressed: _notifications.isEmpty ? null : _markAllRead,
                      child: Text(context.l10n.notificationsMarkAllRead,
                          style: const TextStyle(color: AppColors.accentDeep)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: const TextStyle(color: AppColors.red))
                else if (_notifications.isEmpty)
                  Text(context.l10n.notificationsEmpty, style: const TextStyle(color: AppColors.muted))
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return InkWell(
                          onTap: item.isRead ? null : () => _markRead(item),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: item.isRead ? Colors.transparent : AppColors.accent.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleBadge(
                                      color: item.isRead ? AppColors.muted : AppColors.accentDeep,
                                      label: item.isRead ? context.l10n.notificationRead : context.l10n.notificationNew,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item.message, style: const TextStyle(color: AppColors.muted)),
                                if (item.createdAtUtc != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    AppDateTimeFormat.dateTime(item.createdAtUtc),
                                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
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
