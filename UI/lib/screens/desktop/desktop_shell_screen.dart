import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/qr_scanner_service.dart';
import '../../services/notifications_socket.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/qr_scanner_view.dart';

class DesktopShellScreen extends StatefulWidget {
  final String? forcedRole;

  const DesktopShellScreen({super.key, this.forcedRole});

  @override
  State<DesktopShellScreen> createState() => _DesktopShellScreenState();
}

class _DesktopShellScreenState extends State<DesktopShellScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final NotificationsSocketService _notificationsSocket = NotificationsSocketService.instance;
  late final VoidCallback _sessionListener;

  bool _loading = false;
  String? _error;
  int _selectedIndex = 0;
  bool _shownRequestAlert = false;
  bool _requestPopupOpen = false;

  List<Gym> _gyms = [];
  List<Member> _members = [];
  List<Membership> _memberships = [];
  List<MembershipRequest> _membershipRequests = [];
  List<Trainer> _trainers = [];
  List<MonthlyCount> _membershipsPerMonth = [];
  List<MonthlyRevenue> _revenuePerMonth = [];
  List<TopTrainer> _topTrainers = [];
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _sessionListener = () {
      if (mounted) {
        _loadAdminData();
      }
    };
    _api.session.addListener(_sessionListener);
    _notificationsSocket.onNotificationNew(_handleNotification);
    _loadAdminData();
  }

  @override
  void dispose() {
    _api.session.removeListener(_sessionListener);
    _notificationsSocket.offNotificationNew(_handleNotification);
    _notificationsSocket.disconnect();
    super.dispose();
  }

  String get _currentRole => _api.session.value?.user.role ?? (widget.forcedRole ?? '');

  bool get _isCentralAdmin {
    return _api.session.value?.user.role == 'CentralAdministrator';
  }

  bool get _isGymAdmin {
    return _api.session.value?.user.role == 'GymAdministrator';
  }

  bool get _isAdmin {
    final role = _api.session.value?.user.role;
    if (role == null) {
      return false;
    }
    if (widget.forcedRole != null && role != widget.forcedRole) {
      return false;
    }
    return role == 'CentralAdministrator' || role == 'GymAdministrator';
  }

  Future<void> _loadAdminData() async {
    final session = _api.session.value;
    if (session == null) {
      await _notificationsSocket.disconnect();
      setState(() {
        _loading = false;
        _error = null;
        _gyms = [];
        _members = [];
        _memberships = [];
        _membershipRequests = [];
        _trainers = [];
        _membershipsPerMonth = [];
        _revenuePerMonth = [];
        _topTrainers = [];
        _notifications = [];
      });
      return;
    }
    if (!_isAdmin) {
      _api.session.value = null;
      _showSnack('Admin access required for this workspace.', color: AppColors.red);
      await _notificationsSocket.disconnect();
      setState(() {
        _loading = false;
        _error = null;
        _gyms = [];
        _members = [];
        _memberships = [];
        _membershipRequests = [];
        _trainers = [];
        _membershipsPerMonth = [];
        _revenuePerMonth = [];
        _topTrainers = [];
        _notifications = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _notificationsSocket.connect();
      final results = await Future.wait([
        _api.gyms(),
        _api.members(),
        _api.memberships(),
        _api.membershipRequests(),
        _api.trainers(),
        _api.membershipsPerMonth(),
        _api.revenuePerMonth(),
        _api.topTrainers(),
        _api.notifications(),
      ]);
      setState(() {
        _gyms = results[0] as List<Gym>;
        _members = results[1] as List<Member>;
        _memberships = results[2] as List<Membership>;
        _membershipRequests = results[3] as List<MembershipRequest>;
        _trainers = results[4] as List<Trainer>;
        _membershipsPerMonth = results[5] as List<MonthlyCount>;
        _revenuePerMonth = results[6] as List<MonthlyRevenue>;
        _topTrainers = results[7] as List<TopTrainer>;
        _notifications = results[8] as List<AppNotification>;
      });
      await _maybeShowRequestPopup();
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _maybeShowRequestPopup() async {
    if (_shownRequestAlert || !mounted) {
      return;
    }
    final pending = _notifications
        .where((n) => !n.isRead && (n.category ?? '').toLowerCase() == 'membership_request')
        .toList();
    if (pending.isEmpty) {
      return;
    }
    final viewLabel = _isGymAdmin ? 'View requests' : 'View notifications';
    _shownRequestAlert = true;
    final view = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New membership request'),
          content: Text('You have ${pending.length} new membership request notification${pending.length == 1 ? '' : 's'}.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Later')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(viewLabel)),
          ],
        );
      },
    );
    if (!mounted) {
      return;
    }
    if (view == true) {
      if (_isCentralAdmin) {
        _jumpTo(7);
      } else if (_isGymAdmin) {
        _jumpTo(2);
      }
    }
    for (final item in pending) {
      await _api.markNotificationRead(item.id);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _notifications = _notifications
          .map((item) => pending.any((pendingItem) => pendingItem.id == item.id)
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

  void _showSnack(String message, {Color? color}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.accentDeep,
      ),
    );
  }

  void _logout() {
    if (kDebugMode) {
      debugPrint('[DesktopShell] Logout');
    }
    _api.session.value = null;
    _notificationsSocket.disconnect();
    _showSnack('Signed out.', color: AppColors.muted);
  }


  void _handleNotification(Map<String, dynamic> payload) {
    if (!_isAdmin) {
      return;
    }
    final notification = AppNotification.fromJson(payload);
    setState(() => _notifications = [notification, ..._notifications]);
    if ((notification.category ?? '').toLowerCase() == 'membership_request' && !notification.isRead) {
      _refreshMembershipRequests();
      _showRealtimeRequestPopup(notification);
    }
  }

  void _jumpTo(int index) {
    if (mounted) {
      if (_isGymAdmin && index == 2) {
        _refreshMembershipRequests();
      }
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _refreshMembershipRequests() async {
    if (!_isGymAdmin) {
      return;
    }
    try {
      final requests = await _api.membershipRequests();
      if (mounted) {
        setState(() => _membershipRequests = requests);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    }
  }

  Future<void> _showRealtimeRequestPopup(AppNotification notification) async {
    if (_requestPopupOpen || !mounted) {
      return;
    }
    final viewLabel = _isGymAdmin ? 'View requests' : 'View notifications';
    _requestPopupOpen = true;
    final view = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New membership request'),
          content: Text(notification.message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Later')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(viewLabel)),
          ],
        );
      },
    );
    _requestPopupOpen = false;
    if (!mounted) {
      return;
    }
    if (view == true) {
      if (_isCentralAdmin) {
        _jumpTo(7);
      } else if (_isGymAdmin) {
        _jumpTo(2);
      }
    }
    await _api.markNotificationRead(notification.id);
    if (!mounted) {
      return;
    }
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

  Future<void> _openQrScanner() async {
    final service = QrScannerService();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return QrScannerView(
          service: service,
          onClose: () => Navigator.of(context).pop(),
          onPayload: (payload) async {
            try {
              final success = await _api.scanQr(payload);
              _showSnack(
                success ? 'QR scanned successfully.' : 'QR scan failed.',
                color: success ? AppColors.green : AppColors.red,
              );
            } catch (error) {
              _showSnack(error.toString(), color: AppColors.red);
            }
          },
        );
      },
    );
  }

  Future<void> _createMember({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final created = await _api.createMember(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    setState(() => _members = [created, ..._members]);
  }

  Future<void> _deleteMember(String memberId) async {
    await _api.deleteMember(memberId);
    setState(() => _members.removeWhere((member) => member.id == memberId));
  }

  @override
  Widget build(BuildContext context) {
    final session = _api.session.value;
    final isAdmin = _isAdmin;
    final sections = _isCentralAdmin
        ? const [
            _NavSection('Dashboard', Icons.dashboard_outlined),
            _NavSection('Gyms', Icons.fitness_center_outlined),
            _NavSection('Members', Icons.people_alt_outlined),
            _NavSection('Trainers', Icons.sports_gymnastics_outlined),
            _NavSection('Analytics', Icons.insights_outlined),
            _NavSection('Payments', Icons.payments_outlined),
            _NavSection('Access Logs', Icons.qr_code_scanner),
            _NavSection('Notifications', Icons.notifications_outlined),
            _NavSection('Reference Data', Icons.tune),
            _NavSection('Settings', Icons.settings_outlined),
          ]
        : _isGymAdmin
            ? const [
                _NavSection('Dashboard', Icons.dashboard_outlined),
                _NavSection('Members', Icons.people_alt_outlined),
                _NavSection('Membership Requests', Icons.assignment_ind_outlined),
                _NavSection('Trainers', Icons.sports_gymnastics_outlined),
                _NavSection('Access Logs', Icons.qr_code_scanner),
                _NavSection('Notifications', Icons.notifications_outlined),
                _NavSection('Settings', Icons.settings_outlined),
              ]
            : const [];

    final currentIndex = _selectedIndex >= sections.length ? 0 : _selectedIndex;

    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? _buildErrorCard(_error!)
            : isAdmin
                ? _buildAdminContent(context, currentIndex, isCentralAdmin: _isCentralAdmin)
                : const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Row(
        children: [
          Container(
            width: 240,
            color: AppColors.paper,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FitCity', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          session == null ? 'Desktop workspace' : session.user.fullName,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 20),
                        for (var i = 0; i < sections.length; i++) ...[
                          _NavItem(
                            label: sections[i].label,
                            icon: sections[i].icon,
                            selected: currentIndex == i,
                            onTap: () {
                              if (_isGymAdmin && i == 2) {
                                _refreshMembershipRequests();
                              }
                              setState(() => _selectedIndex = i);
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 16),
                        _AdminSessionCard(
                          session: session,
                          onLogout: _logout,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.paper,
              padding: const EdgeInsets.all(28),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminContent(BuildContext context, int index, {required bool isCentralAdmin}) {
    if (isCentralAdmin) {
      switch (index) {
        case 0:
          return _DashboardPanel(
            gyms: _gyms,
            members: _members,
            memberships: _memberships,
            trainers: _trainers,
            membershipsPerMonth: _membershipsPerMonth,
            revenuePerMonth: _revenuePerMonth,
            topTrainers: _topTrainers,
            onMembersTap: () => _jumpTo(2),
            onTrainersTap: () => _jumpTo(3),
            onGymsTap: () => _jumpTo(1),
            onMembershipsTap: () => _jumpTo(2),
            onAnalyticsTap: () => _jumpTo(4),
            onPaymentsTap: () => _jumpTo(5),
            onAccessLogsTap: () => _jumpTo(6),
          );
        case 1:
          return _GymsPanel(gyms: _gyms);
        case 2:
          return _MembersSearchPanel(gyms: _gyms);
        case 3:
          return _TrainersPanel(trainers: _trainers);
        case 4:
          return _AnalyticsPanel(
            membershipsPerMonth: _membershipsPerMonth,
            revenuePerMonth: _revenuePerMonth,
            topTrainers: _topTrainers,
          );
        case 5:
          return const _PaymentsPanel();
        case 6:
          return _AccessLogsPanel();
        case 7:
          return _NotificationsPanel(notifications: _notifications);
        case 8:
          return _ReferenceDataPanel(gyms: _gyms);
        case 9:
          return const _SettingsPanel();
        default:
          return const SizedBox.shrink();
      }
    }
    switch (index) {
      case 0:
        return _DashboardPanel(
          gyms: _gyms,
          members: _members,
          memberships: _memberships,
          trainers: _trainers,
          membershipsPerMonth: _membershipsPerMonth,
          revenuePerMonth: _revenuePerMonth,
          topTrainers: _topTrainers,
          onMembersTap: () => _jumpTo(1),
          onTrainersTap: () => _jumpTo(2),
          onGymsTap: () => _jumpTo(1),
          onMembershipsTap: () => _jumpTo(1),
          onAnalyticsTap: () => _jumpTo(0),
          onPaymentsTap: () => _jumpTo(0),
          onAccessLogsTap: () => _jumpTo(3),
        );
      case 1:
        return _MembersPanel(
          members: _members,
          memberships: _memberships,
          onCreateMember: _createMember,
          onDeleteMember: _deleteMember,
          onValidateMembership: _api.validateMembership,
          onIssueQr: _api.issueQr,
          onRefresh: _loadAdminData,
          onScanQr: _openQrScanner,
        );
      case 2:
        return _MembershipRequestsPanel(
          requests: _membershipRequests,
          members: _members,
          notifications: _notifications,
          onRequestsChanged: (requests) => setState(() => _membershipRequests = requests),
        );
      case 3:
        return _TrainersPanel(trainers: _trainers);
      case 4:
        return _AccessLogsPanel();
      case 5:
        return _NotificationsPanel(notifications: _notifications);
      case 6:
        return const _SettingsPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorCard(String message) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load admin data', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(color: AppColors.muted), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              AccentButton(label: 'Retry', onPressed: _loadAdminData, width: 140),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSection {
  final String label;
  final IconData icon;

  const _NavSection(this.label, this.icon);
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.accentDeep : AppColors.muted),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppColors.ink : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSessionCard extends StatelessWidget {
  final AuthSession? session;
  final VoidCallback onLogout;

  const _AdminSessionCard({required this.session, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final current = session;
    if (current == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(current.user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(current.user.email, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text('Role: ${current.user.role}', style: const TextStyle(color: AppColors.accentDeep)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onLogout,
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  final List<Gym> gyms;
  final List<Member> members;
  final List<Membership> memberships;
  final List<Trainer> trainers;
  final List<MonthlyCount> membershipsPerMonth;
  final List<MonthlyRevenue> revenuePerMonth;
  final List<TopTrainer> topTrainers;
  final VoidCallback? onMembersTap;
  final VoidCallback? onTrainersTap;
  final VoidCallback? onGymsTap;
  final VoidCallback? onMembershipsTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onPaymentsTap;
  final VoidCallback? onAccessLogsTap;

  const _DashboardPanel({
    required this.gyms,
    required this.members,
    required this.memberships,
    required this.trainers,
    required this.membershipsPerMonth,
    required this.revenuePerMonth,
    required this.topTrainers,
    this.onMembersTap,
    this.onTrainersTap,
    this.onGymsTap,
    this.onMembershipsTap,
    this.onAnalyticsTap,
    this.onPaymentsTap,
    this.onAccessLogsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatCard(label: 'Members', value: '${members.length}', icon: Icons.people_alt, onTap: onMembersTap),
            const SizedBox(width: 16),
            _StatCard(label: 'Trainers', value: '${trainers.length}', icon: Icons.sports_gymnastics, onTap: onTrainersTap),
            const SizedBox(width: 16),
            _StatCard(label: 'Gyms', value: '${gyms.length}', icon: Icons.fitness_center, onTap: onGymsTap),
            const SizedBox(width: 16),
            _StatCard(label: 'Memberships', value: '${memberships.length}', icon: Icons.card_membership, onTap: onMembershipsTap),
            const SizedBox(width: 16),
            _StatCard(label: 'Access Logs', value: 'View', icon: Icons.qr_code_scanner, onTap: onAccessLogsTap),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  title: 'Memberships per month',
                  onTap: onAnalyticsTap,
                  child: membershipsPerMonth.isEmpty
                      ? const Text('No report data yet.', style: TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: membershipsPerMonth.take(6).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${item.month}/${item.year} • ${item.count} new'),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: 'Revenue per month',
                  onTap: onPaymentsTap,
                  child: revenuePerMonth.isEmpty
                      ? const Text('No revenue data yet.', style: TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: revenuePerMonth.take(6).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${item.month}/${item.year} • ${item.revenue.toStringAsFixed(2)}'),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: 'Top trainers',
                  onTap: onAnalyticsTap,
                  child: topTrainers.isEmpty
                      ? const Text('No trainer activity yet.', style: TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: topTrainers.take(6).map((trainer) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${trainer.trainerName} • ${trainer.bookingCount} bookings'),
                            );
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({required this.label, required this.value, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.slate,
                child: Icon(icon, color: AppColors.accentDeep),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  Text(label, style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  const _DashboardCard({required this.title, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
class _MembersPanel extends StatefulWidget {
  final List<Member> members;
  final List<Membership> memberships;
  final Future<void> Function({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) onCreateMember;
  final Future<void> Function(String memberId) onDeleteMember;
  final Future<bool> Function(String membershipId) onValidateMembership;
  final Future<QrIssue> Function(String membershipId) onIssueQr;
  final VoidCallback onRefresh;
  final VoidCallback onScanQr;

  const _MembersPanel({
    required this.members,
    required this.memberships,
    required this.onCreateMember,
    required this.onDeleteMember,
    required this.onValidateMembership,
    required this.onIssueQr,
    required this.onRefresh,
    required this.onScanQr,
  });

  @override
  State<_MembersPanel> createState() => _MembersPanelState();
}

class _MembersPanelState extends State<_MembersPanel> {
  final TextEditingController _searchController = TextEditingController();
  String? _statusMessage;
  bool _busy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Member> get _filteredMembers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.members;
    }
    return widget.members.where((member) {
      return member.fullName.toLowerCase().contains(query) ||
          member.email.toLowerCase().contains(query) ||
          (member.phoneNumber ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openAddMemberDialog() async {
    final result = await showDialog<_AddMemberResult>(
      context: context,
      builder: (context) => const _AddMemberDialog(),
    );
    if (result == null) {
      return;
    }
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    try {
      await widget.onCreateMember(
        email: result.email,
        password: result.password,
        fullName: result.fullName,
        phoneNumber: result.phoneNumber,
      );
      widget.onRefresh();
      setState(() => _statusMessage = 'Member created.');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete member'),
          content: Text('Delete ${member.fullName}? This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _deleteMember(member);
    }
  }

  Future<void> _openMemberDetail(Member member) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _MemberDetailDialog(
          member: member,
          onDelete: _busy ? null : () => _confirmDelete(member),
        );
      },
    );
  }

  Future<void> _deleteMember(Member member) async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    try {
      await widget.onDeleteMember(member.id);
      setState(() => _statusMessage = 'Member deleted.');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _validateMembership(Membership membership) async {
    try {
      final isValid = await widget.onValidateMembership(membership.id);
      setState(() => _statusMessage = isValid ? 'Membership valid.' : 'Membership invalid.');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  Future<void> _issueQr(Membership membership) async {
    try {
      final qr = await widget.onIssueQr(membership.id);
      setState(() => _statusMessage = 'QR issued: ${qr.token}');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _filteredMembers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Members', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                TextButton(
                  onPressed: _busy ? null : widget.onScanQr,
                  child: const Text('Scan QR code'),
                ),
                const SizedBox(width: 8),
                AccentButton(
                  label: _busy ? 'Working...' : 'Add member',
                  onPressed: _busy ? null : _openAddMemberDialog,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name, email, phone',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: members.isEmpty
                      ? const Center(child: Text('No members found.'))
                      : ListView.separated(
                          itemCount: members.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final member = members[index];
                            return Row(
                              children: [
                                const Icon(Icons.person, color: AppColors.muted),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text(member.email, style: const TextStyle(color: AppColors.muted)),
                                    ],
                                  ),
                                ),
                                Text(member.phoneNumber ?? '-', style: const TextStyle(color: AppColors.muted)),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: _busy ? null : () => _openMemberDetail(member),
                                  child: const Text('View'),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: _busy ? null : () => _confirmDelete(member),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _MembershipsCard(
                  memberships: widget.memberships,
                  onValidate: _validateMembership,
                  onIssueQr: _issueQr,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  final List<MonthlyCount> membershipsPerMonth;
  final List<MonthlyRevenue> revenuePerMonth;
  final List<TopTrainer> topTrainers;

  const _AnalyticsPanel({
    required this.membershipsPerMonth,
    required this.revenuePerMonth,
    required this.topTrainers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  title: 'Membership growth',
                  child: membershipsPerMonth.isEmpty
                      ? const Text('No membership data yet.', style: TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: membershipsPerMonth.take(8).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${item.month}/${item.year} • ${item.count} new'),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: 'Revenue trend',
                  child: revenuePerMonth.isEmpty
                      ? const Text('No revenue data yet.', style: TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: revenuePerMonth.take(8).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${item.month}/${item.year} • ${item.revenue.toStringAsFixed(2)}'),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: 'Top trainers',
                  child: topTrainers.isEmpty
                      ? const Text('No trainer activity yet.', style: TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: topTrainers.take(8).map((trainer) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${trainer.trainerName} • ${trainer.bookingCount} bookings'),
                            );
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembershipsCard extends StatelessWidget {
  final List<Membership> memberships;
  final void Function(Membership membership) onValidate;
  final void Function(Membership membership) onIssueQr;

  const _MembershipsCard({
    required this.memberships,
    required this.onValidate,
    required this.onIssueQr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Memberships', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Expanded(
            child: memberships.isEmpty
                ? const Center(child: Text('No memberships found.'))
                : ListView.separated(
                    itemCount: memberships.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final membership = memberships[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Member ${membership.userId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Gym ${membership.gymId}', style: const TextStyle(color: AppColors.muted)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(membership.status, style: const TextStyle(color: AppColors.accentDeep)),
                              const Spacer(),
                              TextButton(
                                onPressed: () => onValidate(membership),
                                child: const Text('Validate'),
                              ),
                              const SizedBox(width: 6),
                              AccentButton(label: 'Issue QR', onPressed: () => onIssueQr(membership), width: 110),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog();

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Name, email, and password are required.');
      return false;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return false;
    }
    if (password.length < 4) {
      setState(() => _error = 'Password must be at least 4 characters.');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add member'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Full name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(hintText: 'Phone (optional)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        AccentButton(
          label: 'Create',
          onPressed: () {
            if (_validate()) {
              Navigator.of(context).pop(
                _AddMemberResult(
                  fullName: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                  phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _AddMemberResult {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;

  const _AddMemberResult({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
  });
}

class _MembersSearchPanel extends StatefulWidget {
  final List<Gym> gyms;

  const _MembersSearchPanel({required this.gyms});

  @override
  State<_MembersSearchPanel> createState() => _MembersSearchPanelState();
}

class _MembersSearchPanelState extends State<_MembersSearchPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _searchController = TextEditingController();
  String _type = 'all';
  String _status = 'all';
  String? _selectedGymId;
  String? _selectedCity;
  bool _loading = false;
  String? _error;
  AdminSearchResponse? _results;

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _cities {
    final values = widget.gyms.map((g) => g.city).where((c) => c.isNotEmpty).toSet().toList();
    values.sort();
    return values;
  }

  Future<void> _runSearch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _api.adminSearch(
        query: _searchController.text.trim(),
        type: _type,
        gymId: _selectedGymId,
        city: _selectedCity,
        status: _status == 'all' ? null : _status,
      );
      if (!mounted) {
        return;
      }
      setState(() => _results = results);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gyms = widget.gyms;
    final cities = _cities;
    final results = _results;
    final showGyms = _type == 'all' || _type == 'gyms';
    final showMembers = _type == 'all' || _type == 'members';
    final showTrainers = _type == 'all' || _type == 'trainers';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Members', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search gyms, members, trainers',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              onPressed: _runSearch,
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (_) => _runSearch(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'gyms', child: Text('Gyms', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'members', child: Text('Members', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'trainers', child: Text('Trainers', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                  isExpanded: true,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                  setState(() => _type = value);
                  _runSearch();
                },
                decoration: InputDecoration(
                  labelText: 'Type',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String?>(
                  value: _selectedGymId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All gyms', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    ...gyms.map((gym) => DropdownMenuItem<String?>(
                          value: gym.id,
                          child: Text(gym.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() => _selectedGymId = value);
                    _runSearch();
                },
                decoration: InputDecoration(
                  labelText: 'Gym',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String?>(
                  value: _selectedCity,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All cities', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    ...cities.map((city) => DropdownMenuItem<String?>(
                          value: city,
                          child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                    _runSearch();
                },
                decoration: InputDecoration(
                  labelText: 'City',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All statuses', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'active', child: Text('Active', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                  isExpanded: true,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                  }
                  setState(() => _status = value);
                  _runSearch();
                },
                decoration: InputDecoration(
                  labelText: 'Status',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            AccentButton(label: 'Search', onPressed: _runSearch),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.red)),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : results == null
                    ? const Center(child: Text('No results yet.'))
                    : ListView(
                        children: [
                          if (showGyms) _SearchSectionTitle(title: 'Gyms', count: results.gyms.length),
                          if (showGyms)
                            ...results.gyms.map((gym) => _GymSearchRow(gym: gym)),
                          if (showMembers) _SearchSectionTitle(title: 'Members', count: results.members.length),
                          if (showMembers)
                            ...results.members.map((member) => _MemberSearchRow(member: member)),
                          if (showTrainers) _SearchSectionTitle(title: 'Trainers', count: results.trainers.length),
                          if (showTrainers)
                            ...results.trainers.map((trainer) => _TrainerSearchRow(trainer: trainer)),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

class _SearchSectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SearchSectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 8),
          CircleBadge(color: AppColors.accentDeep, label: count.toString()),
        ],
      ),
    );
  }
}

class _GymSearchRow extends StatelessWidget {
  final AdminGymSearch gym;

  const _GymSearchRow({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gym.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${gym.address} • ${gym.city}', style: const TextStyle(color: AppColors.muted)),
                if (gym.workHours != null && gym.workHours!.isNotEmpty)
                  Text('Hours: ${gym.workHours}', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleBadge(color: gym.isActive ? AppColors.green : AppColors.red, label: gym.isActive ? 'Active' : 'Inactive'),
              const SizedBox(height: 6),
              Text('${gym.memberCount} members', style: const TextStyle(color: AppColors.muted)),
              Text('${gym.trainerCount} trainers', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberSearchRow extends StatelessWidget {
  final AdminMemberSearch member;

  const _MemberSearchRow({required this.member});

  @override
  Widget build(BuildContext context) {
    final memberships = member.memberships;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(member.email, style: const TextStyle(color: AppColors.muted)),
                if (member.phoneNumber != null && member.phoneNumber!.isNotEmpty)
                  Text(member.phoneNumber!, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: memberships.isEmpty
                      ? [const Text('No memberships', style: TextStyle(color: AppColors.muted))]
                      : memberships
                          .map((m) => CircleBadge(color: AppColors.accentDeep, label: '${m.gymName} • ${m.status}'))
                          .toList(),
                ),
              ],
            ),
          ),
          Text(
            member.createdAtUtc == null ? '-' : member.createdAtUtc!.toLocal().toString().split(' ').first,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _TrainerSearchRow extends StatelessWidget {
  final AdminTrainerSearch trainer;

  const _TrainerSearchRow({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final gymsLabel = trainer.gyms.isEmpty ? 'No gyms' : trainer.gyms.join(', ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_gymnastics, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (trainer.hourlyRate != null)
                  Text('${trainer.hourlyRate!.toStringAsFixed(0)} KM/hr', style: const TextStyle(color: AppColors.muted)),
                Text(gymsLabel, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleBadge(color: trainer.isActive ? AppColors.green : AppColors.red, label: trainer.isActive ? 'Active' : 'Inactive'),
              const SizedBox(height: 6),
              Text('${trainer.upcomingSessions} upcoming', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainersPanel extends StatefulWidget {
  final List<Trainer> trainers;

  const _TrainersPanel({required this.trainers});

  @override
  State<_TrainersPanel> createState() => _TrainersPanelState();
}

class _TrainersPanelState extends State<_TrainersPanel> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openTrainerDetail(Trainer trainer) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _TrainerDetailDialog(trainer: trainer);
      },
    );
  }

  List<Trainer> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.trainers;
    }
    return widget.trainers.where((trainer) {
      return trainer.userName.toLowerCase().contains(query) ||
          (trainer.certifications ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final trainers = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trainers', style: Theme.of(context).textTheme.titleMedium),
            Text('${trainers.length} active', style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search trainer by name',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: trainers.isEmpty
                ? const Center(child: Text('No trainers found.'))
                : ListView.separated(
                    itemCount: trainers.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final trainer = trainers[index];
                      return Row(
                        children: [
                          _TrainerAvatarThumb(photoUrl: trainer.photoUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trainer.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  trainer.certifications ?? 'No certifications',
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          if (trainer.hourlyRate != null)
                            Text(
                              '${trainer.hourlyRate!.toStringAsFixed(0)} KM/hr',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          if (trainer.hourlyRate != null) const SizedBox(width: 12),
                          Text(trainer.isActive ? 'Active' : 'Inactive', style: TextStyle(color: trainer.isActive ? AppColors.green : AppColors.red)),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => _openTrainerDetail(trainer),
                            child: const Text('View'),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _GymsPanel extends StatefulWidget {
  final List<Gym> gyms;

  const _GymsPanel({required this.gyms});

  @override
  State<_GymsPanel> createState() => _GymsPanelState();
}

class _GymsPanelState extends State<_GymsPanel> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Gym> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.gyms;
    }
    return widget.gyms.where((gym) {
      return gym.name.toLowerCase().contains(query) ||
          gym.city.toLowerCase().contains(query) ||
          gym.address.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gyms = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gyms', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search gyms',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: gyms.isEmpty
                ? const Center(child: Text('No gyms found.'))
                : ListView.separated(
                    itemCount: gyms.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final gym = gyms[index];
                      return Row(
                        children: [
                          const Icon(Icons.fitness_center, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(gym.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${gym.address}, ${gym.city}', style: const TextStyle(color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Text(
                            gym.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(color: gym.isActive ? AppColors.green : AppColors.red),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _PaymentsPanel extends StatelessWidget {
  const _PaymentsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payments', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Payments data will appear here once payment endpoints are connected.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _AccessLogsPanel extends StatefulWidget {
  @override
  State<_AccessLogsPanel> createState() => _AccessLogsPanelState();
}

class _AccessLogsPanelState extends State<_AccessLogsPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _queryController = TextEditingController();
  List<Gym> _gyms = [];
  Gym? _selectedGym;
  List<AccessLog> _logs = [];
  DateTime? _fromDate;
  DateTime? _toDate;
  String _status = 'all';
  bool _loading = true;
  String? _error;

  bool get _isGymAdmin => _api.session.value?.user.role == 'GymAdministrator';

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    try {
      final gyms = await _api.gyms();
      setState(() {
        _gyms = gyms;
        if (_isGymAdmin && gyms.isNotEmpty) {
          _selectedGym = gyms.first;
        }
      });
      await _loadLogs();
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final logs = await _api.accessLogs(
        gymId: _selectedGym?.id,
        fromUtc: _fromDate,
        toUtc: _toDate,
        status: _status == 'all' ? null : _status,
        query: _queryController.text.trim().isEmpty ? null : _queryController.text.trim(),
      );
      setState(() => _logs = logs);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _fromDate = DateTime(selected.year, selected.month, selected.day);
      } else {
        _toDate = DateTime(selected.year, selected.month, selected.day, 23, 59, 59);
      }
    });
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    final gymsForDropdown = _dedupeGyms(_gyms);
    final selectedGymId = _selectedGym?.id;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Access Logs', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final fieldWidth = isNarrow ? constraints.maxWidth : 220.0;
              final statusWidth = isNarrow ? constraints.maxWidth : 160.0;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!_isGymAdmin)
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String>(
                        value: selectedGymId,
                        items: gymsForDropdown
                            .map((gym) => DropdownMenuItem<String>(
                                  value: gym.id,
                                  child: Text(gym.name, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (gymId) {
                          if (gymId == null) {
                            return;
                          }
                          final gym = gymsForDropdown.firstWhere((g) => g.id == gymId, orElse: () => gymsForDropdown.first);
                          setState(() => _selectedGym = gym);
                          _loadLogs();
                        },
                        decoration: InputDecoration(
                          labelText: 'Gym',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  OutlinedButton(
                    onPressed: () => _pickDate(isFrom: true),
                    child: Text(_fromDate == null ? 'From date' : _fromDate!.toLocal().toString().split(' ').first),
                  ),
                  OutlinedButton(
                    onPressed: () => _pickDate(isFrom: false),
                    child: Text(_toDate == null ? 'To date' : _toDate!.toLocal().toString().split(' ').first),
                  ),
                  SizedBox(
                    width: statusWidth,
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'granted', child: Text('Granted')),
                        DropdownMenuItem(value: 'denied', child: Text('Denied')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _status = value);
                        _loadLogs();
                      },
                      decoration: InputDecoration(
                        labelText: 'Status',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: TextField(
                      controller: _queryController,
                      decoration: InputDecoration(
                        hintText: 'Member search',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _loadLogs(),
                    ),
                  ),
                  AccentButton(
                    label: 'Refresh',
                    onPressed: _loadLogs,
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.red)))
                    : _logs.isEmpty
                        ? const Center(child: Text('No access logs found.', style: TextStyle(color: AppColors.muted)))
                        : ListView.separated(
                            itemCount: _logs.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              final isGranted = log.status.toLowerCase() == 'granted';
                              return InkWell(
                                onTap: () => _showLogDetail(log),
                                child: Row(
                                  children: [
                                    CircleBadge(
                                      color: isGranted ? AppColors.green : AppColors.red,
                                      label: log.status,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${log.memberName} • ${log.gymName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(log.reason, style: const TextStyle(color: AppColors.muted)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      log.checkedAtUtc?.toLocal().toString() ?? '-',
                                      style: const TextStyle(color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }

  void _showLogDetail(AccessLog log) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Access log'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailHeaderRow(label: 'Member', value: log.memberName),
              _DetailHeaderRow(label: 'Gym', value: log.gymName),
              _DetailHeaderRow(label: 'Status', value: log.status),
              _DetailHeaderRow(label: 'Reason', value: log.reason),
              _DetailHeaderRow(label: 'Time', value: log.checkedAtUtc?.toLocal().toString() ?? '-'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        );
      },
    );
  }

  List<Gym> _dedupeGyms(List<Gym> gyms) {
    final map = <String, Gym>{};
    for (final gym in gyms) {
      map.putIfAbsent(gym.id, () => gym);
    }
    return map.values.toList();
  }
}

class _MembershipRequestsPanel extends StatefulWidget {
  final List<MembershipRequest> requests;
  final List<Member> members;
  final List<AppNotification> notifications;
  final ValueChanged<List<MembershipRequest>>? onRequestsChanged;

  const _MembershipRequestsPanel({
    required this.requests,
    required this.members,
    required this.notifications,
    this.onRequestsChanged,
  });

  @override
  State<_MembershipRequestsPanel> createState() => _MembershipRequestsPanelState();
}

class _MembershipRequestsPanelState extends State<_MembershipRequestsPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _searchController = TextEditingController();
  late List<MembershipRequest> _requests;
  late List<AppNotification> _notifications;
  late Map<String, Member> _memberLookup;
  String _statusFilter = 'Pending';
  String? _statusMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _requests = List.of(widget.requests);
    _notifications = List.of(widget.notifications);
    _memberLookup = {for (final member in widget.members) member.id: member};
  }

  @override
  void didUpdateWidget(covariant _MembershipRequestsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests) {
      _requests = List.of(widget.requests);
    }
    if (oldWidget.notifications != widget.notifications) {
      _notifications = List.of(widget.notifications);
    }
    if (oldWidget.members != widget.members) {
      _memberLookup = {for (final member in widget.members) member.id: member};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MembershipRequest> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    var items = _requests;
    if (_statusFilter != 'All') {
      items = items.where((r) => r.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
    }
    if (query.isEmpty) {
      return items;
    }
    return items.where((request) {
      final member = _memberLookup[request.userId];
      return request.userId.toLowerCase().contains(query) ||
          request.gymId.toLowerCase().contains(query) ||
          request.status.toLowerCase().contains(query) ||
          request.paymentStatus.toLowerCase().contains(query) ||
          (member?.fullName.toLowerCase().contains(query) ?? false) ||
          (member?.email.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _decideRequest(MembershipRequest request, bool approve) async {
    setState(() {
      _statusMessage = null;
      _submitting = true;
    });
    try {
      final updated = await _api.decideMembershipRequest(requestId: request.id, approve: approve);
      setState(() {
        _requests = _requests.map((item) => item.id == request.id ? updated : item).toList();
        _statusMessage = approve ? 'Request approved.' : 'Request rejected.';
      });
      widget.onRequestsChanged?.call(List.of(_requests));
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final unreadRequestNotifications = _notifications
        .where((n) => !n.isRead && (n.category ?? '').toLowerCase() == 'membership_request')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Membership requests', style: Theme.of(context).textTheme.titleMedium),
            Text('${items.length} records', style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        if (unreadRequestNotifications.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...unreadRequestNotifications.take(5).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${item.title}: ${item.message}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by member, gym, status',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButton<String>(
                value: _statusFilter,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _statusFilter = value);
                },
              ),
            ),
          ],
        ),
        if (_statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: items.isEmpty
                ? const Center(child: Text('No membership requests found.'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final request = items[index];
                      final member = _memberLookup[request.userId];
                      final canDecide = request.status.toLowerCase() == 'pending' && !_submitting;
                      return Row(
                        children: [
                          const Icon(Icons.assignment_ind_outlined, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member?.fullName ?? 'Member ${request.userId}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  member?.email ?? 'Gym ${request.gymId}',
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(request.status, style: const TextStyle(color: AppColors.accentDeep)),
                              Text(request.paymentStatus, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: canDecide ? () => _decideRequest(request, false) : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          AccentButton(
                            label: _submitting ? 'Updating...' : 'Approve',
                            onPressed: canDecide ? () => _decideRequest(request, true) : null,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsPanel extends StatefulWidget {
  final List<AppNotification> notifications;

  const _NotificationsPanel({required this.notifications});

  @override
  State<_NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<_NotificationsPanel> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppNotification> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.notifications;
    }
    return widget.notifications.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          (item.category ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search notifications',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: notifications.isEmpty
                ? const Center(child: Text('No notifications yet.'))
                : ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Row(
                        children: [
                          CircleBadge(
                            color: item.isRead ? AppColors.muted : AppColors.accentDeep,
                            label: item.isRead ? 'Read' : 'New',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(item.message, style: const TextStyle(color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReferenceDataPanel extends StatefulWidget {
  final List<Gym> gyms;

  const _ReferenceDataPanel({required this.gyms});

  @override
  State<_ReferenceDataPanel> createState() => _ReferenceDataPanelState();
}

class _ReferenceDataPanelState extends State<_ReferenceDataPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGymId;
  bool _loading = true;
  String? _error;
  List<GymPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await _api.gymPlans(
        gymId: _selectedGymId,
        query: _searchController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() => _plans = plans);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openPlanDialog({GymPlan? plan}) async {
    final result = await showDialog<_GymPlanDraft>(
      context: context,
      builder: (context) => _GymPlanDialog(gyms: widget.gyms, plan: plan),
    );
    if (result == null) {
      return;
    }
    try {
      if (plan == null) {
        await _api.createGymPlan(
          gymId: result.gymId,
          name: result.name,
          price: result.price,
          durationMonths: result.durationMonths,
          description: result.description,
          isActive: result.isActive,
        );
      } else {
        await _api.updateGymPlan(
          id: plan.id,
          gymId: result.gymId,
          name: result.name,
          price: result.price,
          durationMonths: result.durationMonths,
          description: result.description,
          isActive: result.isActive,
        );
      }
      await _loadPlans();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _deletePlan(GymPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete gym plan'),
        content: Text('Delete "${plan.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await _api.deleteGymPlan(plan.id);
      await _loadPlans();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reference Data', style: Theme.of(context).textTheme.titleMedium),
            AccentButton(label: 'Add plan', onPressed: () => _openPlanDialog()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search gym plans',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _loadPlans(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                value: _selectedGymId,
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All gyms')),
                  ...widget.gyms.map((gym) => DropdownMenuItem<String?>(value: gym.id, child: Text(gym.name))),
                ],
                isExpanded: true,
                onChanged: (value) {
                  setState(() => _selectedGymId = value);
                  _loadPlans();
                },
                decoration: InputDecoration(
                  labelText: 'Gym',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AccentButton(label: 'Search', onPressed: _loadPlans),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.red)),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _plans.isEmpty
                    ? const Center(child: Text('No gym plans found.'))
                    : ListView.separated(
                        itemCount: _plans.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return Row(
                            children: [
                              const Icon(Icons.fact_check, color: AppColors.muted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text('${plan.gymName} • ${plan.durationMonths} months', style: const TextStyle(color: AppColors.muted)),
                                    Text('${plan.price.toStringAsFixed(2)} KM', style: const TextStyle(color: AppColors.muted)),
                                    if (plan.description != null && plan.description!.isNotEmpty)
                                      Text(plan.description!, style: const TextStyle(color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CircleBadge(
                                    color: plan.isActive ? AppColors.green : AppColors.red,
                                    label: plan.isActive ? 'Active' : 'Inactive',
                                  ),
                                  const SizedBox(height: 6),
                                  TextButton(onPressed: () => _openPlanDialog(plan: plan), child: const Text('Edit')),
                                  TextButton(
                                    onPressed: () => _deletePlan(plan),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}

class _GymPlanDraft {
  final String gymId;
  final String name;
  final double price;
  final int durationMonths;
  final String? description;
  final bool isActive;

  _GymPlanDraft({
    required this.gymId,
    required this.name,
    required this.price,
    required this.durationMonths,
    this.description,
    required this.isActive,
  });
}

class _GymPlanDialog extends StatefulWidget {
  final List<Gym> gyms;
  final GymPlan? plan;

  const _GymPlanDialog({required this.gyms, this.plan});

  @override
  State<_GymPlanDialog> createState() => _GymPlanDialogState();
}

class _GymPlanDialogState extends State<_GymPlanDialog> {
  late String _gymId;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _gymId = plan?.gymId ?? (widget.gyms.isNotEmpty ? widget.gyms.first.id : '');
    _nameController = TextEditingController(text: plan?.name ?? '');
    _priceController = TextEditingController(text: plan?.price.toStringAsFixed(2) ?? '');
    _durationController = TextEditingController(text: plan?.durationMonths.toString() ?? '');
    _descriptionController = TextEditingController(text: plan?.description ?? '');
    _isActive = plan?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());
    if (_gymId.isEmpty || name.isEmpty || price == null || duration == null) {
      return;
    }
    Navigator.of(context).pop(_GymPlanDraft(
      gymId: _gymId,
      name: name,
      price: price,
      durationMonths: duration,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isActive: _isActive,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.plan == null ? 'Add gym plan' : 'Edit gym plan'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _gymId.isEmpty ? null : _gymId,
                items: widget.gyms.map((gym) => DropdownMenuItem(value: gym.id, child: Text(gym.name))).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _gymId = value);
                },
                decoration: InputDecoration(
                  labelText: 'Gym',
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (KM)',
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (months)',
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: const Text('Active'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('General', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _ToggleRow(label: 'Allow new gym registrations', value: true),
              const SizedBox(height: 8),
              _ToggleRow(label: 'Send weekly reports', value: true),
              const SizedBox(height: 8),
              _ToggleRow(label: 'Enable trainer chat', value: true),
              const SizedBox(height: 16),
              const Text('Support email'),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'support@fitcity.local',
                  filled: true,
                  fillColor: AppColors.slate,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              AccentButton(label: 'Save settings', onPressed: () {}, width: 160),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;

  const _ToggleRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Switch(value: value, onChanged: (_) {}),
      ],
    );
  }
}

class _MemberDetailDialog extends StatelessWidget {
  final Member member;
  final VoidCallback? onDelete;

  const _MemberDetailDialog({required this.member, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final api = FitCityApi.instance;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<MemberDetail>(
            future: api.memberDetail(member.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _DetailError(message: snapshot.error.toString());
              }
              final detail = snapshot.data;
              if (detail == null) {
                return const _DetailError(message: 'Member detail not found.');
              }
              final memberships = detail.memberships;
              final bookings = detail.bookings;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(detail.member.fullName, style: Theme.of(context).textTheme.titleMedium)),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailHeaderRow(label: 'Email', value: detail.member.email),
                  _DetailHeaderRow(label: 'Phone', value: detail.member.phoneNumber ?? '-'),
                  _DetailHeaderRow(
                    label: 'Member since',
                    value: detail.member.createdAtUtc?.toLocal().toString() ?? '-',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleBadge(
                        color: detail.qrStatus == 'Active' ? AppColors.green : AppColors.red,
                        label: 'QR ${detail.qrStatus}',
                      ),
                      const SizedBox(width: 12),
                      Text(
                        detail.qrExpiresAtUtc == null
                            ? 'No active QR pass'
                            : 'Expires ${detail.qrExpiresAtUtc!.toLocal()}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.lastAccessAtUtc == null
                        ? 'No access logs yet.'
                        : 'Last access: ${detail.lastAccessAtUtc!.toLocal()} • ${detail.lastAccessGymName ?? '-'}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DetailCard(
                            title: 'Memberships',
                            child: memberships.isEmpty
                                ? const Text('No memberships yet.', style: TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: memberships.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = memberships[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.status} • ${item.gymId}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(item.endDateUtc.toLocal().toString(),
                                              style: const TextStyle(color: AppColors.muted)),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DetailCard(
                            title: 'Bookings',
                            child: bookings.isEmpty
                                ? const Text('No bookings yet.', style: TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: bookings.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = bookings[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.status} • ${item.trainerId}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(item.startUtc.toLocal().toString(),
                                              style: const TextStyle(color: AppColors.muted)),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onDelete != null)
                        TextButton(
                          onPressed: onDelete,
                          style: TextButton.styleFrom(foregroundColor: AppColors.red),
                          child: const Text('Delete member'),
                        ),
                      const Spacer(),
                      AccentButton(
                        label: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        width: 140,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrainerDetailDialog extends StatelessWidget {
  final Trainer trainer;

  const _TrainerDetailDialog({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final api = FitCityApi.instance;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<TrainerDetail>(
            future: api.trainerDetail(trainer.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _DetailError(message: snapshot.error.toString());
              }
              final detail = snapshot.data;
              if (detail == null) {
                return const _DetailError(message: 'Trainer detail not found.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TrainerAvatarThumb(photoUrl: detail.trainer.photoUrl, size: 44),
                      const SizedBox(width: 12),
                      Expanded(child: Text(detail.trainer.userName, style: Theme.of(context).textTheme.titleMedium)),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (detail.trainer.hourlyRate != null)
                    _DetailHeaderRow(
                      label: 'Rate',
                      value: '${detail.trainer.hourlyRate!.toStringAsFixed(0)} KM/hr',
                    ),
                  _DetailHeaderRow(label: 'Bio', value: detail.trainer.bio ?? '-'),
                  _DetailHeaderRow(label: 'Certifications', value: detail.trainer.certifications ?? '-'),
                  _DetailHeaderRow(label: 'Status', value: detail.trainer.isActive ? 'Active' : 'Inactive'),
                  const SizedBox(height: 12),
                  Text('Gyms', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: detail.gyms.isEmpty
                        ? [const Text('No gym association yet.', style: TextStyle(color: AppColors.muted))]
                        : detail.gyms.map((gym) => CircleBadge(color: AppColors.accentDeep, label: gym.name)).toList(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DetailCard(
                            title: 'Schedule',
                            child: detail.schedules.isEmpty
                                ? const Text('No schedule entries.', style: TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: detail.schedules.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = detail.schedules[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.startUtc.toLocal()} - ${item.endUtc.toLocal()}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          CircleBadge(
                                            color: item.isAvailable ? AppColors.green : AppColors.red,
                                            label: item.isAvailable ? 'Available' : 'Booked',
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DetailCard(
                            title: 'Sessions',
                            child: detail.sessions.isEmpty
                                ? const Text('No sessions recorded.', style: TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: detail.sessions.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = detail.sessions[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.status} • ${item.userId}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(item.startUtc.toLocal().toString(),
                                              style: const TextStyle(color: AppColors.muted)),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Spacer(),
                      AccentButton(
                        label: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        width: 140,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrainerAvatarThumb extends StatelessWidget {
  final String? photoUrl;
  final double size;

  const _TrainerAvatarThumb({this.photoUrl, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.slate,
      child: url == null || url.isEmpty
          ? const Icon(Icons.sports_gymnastics, color: AppColors.muted)
          : ClipOval(
              child: Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_gymnastics, color: AppColors.muted),
              ),
            ),
    );
  }
}

class _DetailHeaderRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailHeaderRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  final String message;

  const _DetailError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, style: const TextStyle(color: AppColors.red)));
  }
}

