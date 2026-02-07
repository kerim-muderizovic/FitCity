import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../l10n/l10n.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/notifications_socket.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/common.dart';
import '../../widgets/admin_qr_scanner_view.dart';
import '../../widgets/admin_settings_panel.dart';
import '../../widgets/language_selector.dart';

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
      _showSnack(context.l10n.adminAccessRequired, color: AppColors.red);
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
        final gymsFuture = _isGymAdmin
            ? _api.adminGym().then((value) => [value])
            : _api.adminGyms();
        final results = await Future.wait([
          gymsFuture,
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
    final viewLabel =
        _isGymAdmin ? context.l10n.adminViewRequests : context.l10n.adminViewNotifications;
    _shownRequestAlert = true;
    final view = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.adminNewMembershipRequestTitle),
          content: Text(context.l10n.adminNewMembershipRequestBody(
            pending.length,
            pending.length == 1 ? '' : 's',
          )),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonLater)),
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
    _showSnack(context.l10n.commonSignedOut, color: AppColors.muted);
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
    final viewLabel =
        _isGymAdmin ? context.l10n.adminViewRequests : context.l10n.adminViewNotifications;
    _requestPopupOpen = true;
    final view = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.adminNewMembershipRequestTitle),
          content: Text(notification.message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonLater)),
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
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AdminQrScannerView(
          onClose: () => Navigator.of(context).pop(),
          onScan: (payload) async {
            return _api.scanQr(payload);
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
        ? [
            _NavSection(context.l10n.commonDashboard, Icons.dashboard_outlined),
            _NavSection(context.l10n.commonGyms, Icons.fitness_center_outlined),
            _NavSection(context.l10n.commonMembers, Icons.people_alt_outlined),
            _NavSection(context.l10n.commonTrainers, Icons.sports_gymnastics_outlined),
            _NavSection(context.l10n.commonAnalytics, Icons.insights_outlined),
            _NavSection(context.l10n.commonPayments, Icons.payments_outlined),
            _NavSection(context.l10n.commonAccessLogs, Icons.qr_code_scanner),
            _NavSection(context.l10n.commonNotifications, Icons.notifications_outlined),
            _NavSection(context.l10n.settingsTitle, Icons.settings_outlined),
          ]
        : _isGymAdmin
            ? [
                _NavSection(context.l10n.commonDashboard, Icons.dashboard_outlined),
                _NavSection(context.l10n.commonMembers, Icons.people_alt_outlined),
                _NavSection(context.l10n.adminMembershipRequests, Icons.assignment_ind_outlined),
                _NavSection(context.l10n.commonTrainers, Icons.sports_gymnastics_outlined),
                _NavSection(context.l10n.commonAccessLogs, Icons.qr_code_scanner),
                _NavSection(context.l10n.commonNotifications, Icons.notifications_outlined),
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
        body: Stack(
          children: [
            Row(
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
                              Text(context.l10n.desktopAppTitle, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                session == null ? context.l10n.authDesktopWorkspace : session.user.fullName,
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
            if (_isGymAdmin)
              Positioned(
                right: 20,
                bottom: 20,
                child: AlwaysOnQrScannerPanel(
                  onScan: (payload) => _api.scanQr(payload),
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
            showGymCount: !_isGymAdmin,
            onMembersTap: () => _jumpTo(2),
            onTrainersTap: () => _jumpTo(3),
            onGymsTap: () => _jumpTo(1),
            onMembershipsTap: () => _jumpTo(2),
            onAnalyticsTap: () => _jumpTo(4),
            onPaymentsTap: () => _jumpTo(5),
            onAccessLogsTap: () => _jumpTo(6),
          );
        case 1:
          return _GymsPanel(gyms: _gyms, onRefresh: _loadAdminData);
        case 2:
          return _MembersSearchPanel(gyms: _gyms);
        case 3:
          return _TrainersPanel(
            trainers: _trainers,
            canManage: false,
          );
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
          showGymCount: !_isGymAdmin,
          onMembersTap: () => _jumpTo(1),
          onTrainersTap: () => _jumpTo(3),
          onGymsTap: () => _jumpTo(1),
          onMembershipsTap: () => _jumpTo(1),
          onAnalyticsTap: () => _jumpTo(0),
          onPaymentsTap: () => _jumpTo(0),
          onAccessLogsTap: () => _jumpTo(4),
        );
        case 1:
          return _MembersPanel(
            members: _members,
            memberships: _memberships,
            onCreateMember: _createMember,
            onDeleteMember: _deleteMember,
            onRefresh: _loadAdminData,
            onScanQr: _isGymAdmin ? null : _openQrScanner,
            loading: _loading,
          );
      case 2:
        return _MembershipRequestsPanel(
          requests: _membershipRequests,
          members: _members,
          notifications: _notifications,
          onRequestsChanged: (requests) => setState(() => _membershipRequests = requests),
        );
      case 3:
        return _TrainersPanel(
          trainers: _trainers,
          canManage: _isGymAdmin,
          onRefresh: _loadAdminData,
        );
      case 4:
        return _AccessLogsPanel();
      case 5:
        return _NotificationsPanel(notifications: _notifications);
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
              Text(context.l10n.desktopUnableLoadAdmin, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(color: AppColors.muted), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              AccentButton(label: context.l10n.commonRetry, onPressed: _loadAdminData, width: 140),
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

class _AdminSessionCard extends StatefulWidget {
  final AuthSession? session;
  final VoidCallback onLogout;

  const _AdminSessionCard({required this.session, required this.onLogout});

  @override
  State<_AdminSessionCard> createState() => _AdminSessionCardState();
}

class _AdminSessionCardState extends State<_AdminSessionCard> {
  static const int _maxPhotoBytes = 5 * 1024 * 1024;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  final FitCityApi _api = FitCityApi.instance;
  bool _uploadingPhoto = false;
  String? _photoError;
  Uint8List? _previewBytes;

  Future<void> _pickAndUploadPhoto() async {
    final current = widget.session;
    if (current == null || _uploadingPhoto) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      return;
    }
    if (bytes.length > _maxPhotoBytes) {
      setState(() => _photoError = context.l10n.profilePhotoTooLarge);
      return;
    }
    final extension = _fileExtension(file.name);
    if (extension == null || !_allowedExtensions.contains(extension)) {
      setState(() => _photoError = context.l10n.profilePhotoInvalidType);
      return;
    }

    setState(() {
      _uploadingPhoto = true;
      _photoError = null;
      _previewBytes = bytes;
    });

    try {
      final updated = await _api.uploadProfilePhoto(bytes: bytes, fileName: file.name);
      final currentSession = _api.session.value;
      if (currentSession != null) {
        _api.session.value = AuthSession(auth: currentSession.auth, user: updated);
      }
      if (mounted) {
        setState(() => _previewBytes = null);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _photoError = mapApiError(context, error));
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  String? _fileExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) {
      return null;
    }
    return fileName.substring(dot + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.session;
    if (current == null) {
      return const SizedBox.shrink();
    }
    final photoUrl = current.user.photoUrl;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.slate,
                      child: _previewBytes != null
                          ? ClipOval(
                              child: Image.memory(
                                _previewBytes!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (photoUrl == null || photoUrl.isEmpty)
                              ? const Icon(Icons.person, size: 18, color: AppColors.muted)
                              : ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.person, size: 18, color: AppColors.muted),
                                  ),
                                ),
                    ),
                    if (_uploadingPhoto)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(current.user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(current.user.email, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(context.l10n.commonRoleLabel(current.user.role),
              style: const TextStyle(color: AppColors.accentDeep)),
          const SizedBox(height: 10),
          if (_photoError != null) ...[
            Text(_photoError!, style: const TextStyle(color: AppColors.red)),
            const SizedBox(height: 6),
          ],
          TextButton(
            onPressed: widget.onLogout,
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(context.l10n.commonSignOut),
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
  final bool showGymCount;
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
    required this.showGymCount,
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
        Text(context.l10n.commonDashboard, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
            children: [
              _StatCard(label: context.l10n.commonMembers, value: '${members.length}', icon: Icons.people_alt, onTap: onMembersTap),
              const SizedBox(width: 16),
              _StatCard(label: context.l10n.commonTrainers, value: '${trainers.length}', icon: Icons.sports_gymnastics, onTap: onTrainersTap),
              if (showGymCount) ...[
                const SizedBox(width: 16),
                _StatCard(label: context.l10n.commonGyms, value: '${gyms.length}', icon: Icons.fitness_center, onTap: onGymsTap),
              ],
              const SizedBox(width: 16),
              _StatCard(label: context.l10n.commonMemberships, value: '${memberships.length}', icon: Icons.card_membership, onTap: onMembershipsTap),
              const SizedBox(width: 16),
              _StatCard(label: context.l10n.commonAccessLogs, value: context.l10n.commonView, icon: Icons.qr_code_scanner, onTap: onAccessLogsTap),
            ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  title: context.l10n.adminMembershipsPerMonthTitle,
                  onTap: onAnalyticsTap,
                  child: membershipsPerMonth.isEmpty
                      ? Text(context.l10n.adminNoReportData, style: const TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: membershipsPerMonth.take(6).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(context.l10n.adminReportLine(
                                item.month,
                                item.year,
                                item.count,
                              )),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: context.l10n.adminRevenuePerMonthTitle,
                  onTap: onPaymentsTap,
                  child: revenuePerMonth.isEmpty
                      ? Text(context.l10n.adminNoRevenueData, style: const TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: revenuePerMonth.take(6).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(context.l10n.adminRevenueLine(
                                item.month,
                                item.year,
                                item.revenue.toStringAsFixed(2),
                              )),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: context.l10n.adminTopTrainersTitle,
                  onTap: onAnalyticsTap,
                  child: topTrainers.isEmpty
                      ? Text(context.l10n.adminNoTrainerActivity, style: const TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: topTrainers.take(6).map((trainer) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(context.l10n.adminTrainerActivityLine(
                                trainer.trainerName,
                                trainer.bookingCount,
                              )),
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
  final VoidCallback onRefresh;
  final VoidCallback? onScanQr;
  final bool loading;

  const _MembersPanel({
    required this.members,
    required this.memberships,
    required this.onCreateMember,
    required this.onDeleteMember,
    required this.onRefresh,
    required this.onScanQr,
    required this.loading,
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
      setState(() => _statusMessage = context.l10n.adminMemberCreated);
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
          title: Text(context.l10n.adminDeleteMemberTitle),
          content: Text(context.l10n.adminDeleteMemberConfirmName(member.fullName)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
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
      setState(() => _statusMessage = context.l10n.adminMemberDeleted);
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      setState(() => _busy = false);
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
              Text(context.l10n.commonMembers, style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  if (widget.onScanQr != null) ...[
                    TextButton(
                      onPressed: _busy ? null : widget.onScanQr,
                      child: Text(context.l10n.adminScanQr),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AccentButton(
                    label: _busy ? context.l10n.commonWorking : context.l10n.adminAddMember,
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
            hintText: context.l10n.adminSearchMembersHint,
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
                    child: widget.loading
                        ? const Center(child: CircularProgressIndicator())
                        : members.isEmpty
                            ? Center(child: Text(context.l10n.adminNoMembersFound))
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
                                  child: Text(context.l10n.commonView),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: _busy ? null : () => _confirmDelete(member),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.red),
                                  child: Text(context.l10n.commonDelete),
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
        Text(context.l10n.commonAnalytics, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  title: context.l10n.adminMembershipGrowthTitle,
                  child: membershipsPerMonth.isEmpty
                      ? Text(context.l10n.adminNoMembershipData, style: const TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: membershipsPerMonth.take(8).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(context.l10n.adminReportLine(
                                item.month,
                                item.year,
                                item.count,
                              )),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: context.l10n.adminRevenueTrendTitle,
                  child: revenuePerMonth.isEmpty
                      ? Text(context.l10n.adminNoRevenueData, style: const TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: revenuePerMonth.take(8).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(context.l10n.adminRevenueLine(
                                item.month,
                                item.year,
                                item.revenue.toStringAsFixed(2),
                              )),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: context.l10n.adminTopTrainersTitle,
                  child: topTrainers.isEmpty
                      ? Text(context.l10n.adminNoTrainerActivity, style: const TextStyle(color: AppColors.muted))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: topTrainers.take(8).map((trainer) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(context.l10n.adminTrainerActivityLine(
                                trainer.trainerName,
                                trainer.bookingCount,
                              )),
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

  const _MembershipsCard({
    required this.memberships,
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
          Text(context.l10n.commonMemberships, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Expanded(
            child: memberships.isEmpty
                ? Center(child: Text(context.l10n.adminNoMembershipsFound))
                : ListView.separated(
                    itemCount: memberships.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final membership = memberships[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.adminMembershipLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(membership.status, style: const TextStyle(color: AppColors.accentDeep)),
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
        setState(() => _error = context.l10n.adminCreateRequiredFields);
        return false;
      }
      if (!email.contains('@')) {
        setState(() => _error = context.l10n.authEmailInvalid);
        return false;
      }
      if (password.length < 4) {
        setState(() => _error = context.l10n.adminPasswordMin(4));
        return false;
      }
    setState(() => _error = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.adminAddMember),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: context.l10n.authFullNameLabel),
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: context.l10n.authEmailLabel),
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: context.l10n.authPasswordLabel),
                obscureText: true,
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(hintText: context.l10n.authPhoneOptionalLabel),
              ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
        AccentButton(
          label: context.l10n.commonCreate,
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

class _AddTrainerDialog extends StatefulWidget {
  const _AddTrainerDialog();

  @override
  State<_AddTrainerDialog> createState() => _AddTrainerDialogState();
}

class _AddTrainerDialogState extends State<_AddTrainerDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _photoController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _error = context.l10n.adminCreateRequiredFields);
        return false;
      }
      if (!email.contains('@')) {
        setState(() => _error = context.l10n.authEmailInvalid);
        return false;
      }
      if (password.length < 6) {
        setState(() => _error = context.l10n.adminPasswordMin(6));
        return false;
      }
    final rate = _rateController.text.trim();
    final parsedRate = double.tryParse(rate);
      if (rate.isEmpty || parsedRate == null || parsedRate <= 0) {
        setState(() => _error = context.l10n.adminTrainerHourlyRateRequired);
        return false;
      }
    setState(() => _error = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.adminAddTrainer),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: context.l10n.authFullNameLabel),
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: context.l10n.authEmailLabel),
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: context.l10n.authPasswordLabel),
                obscureText: true,
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _photoController,
                decoration: InputDecoration(hintText: context.l10n.adminTrainerPhotoUrlHint),
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _rateController,
                decoration: InputDecoration(hintText: context.l10n.adminTrainerHourlyRateHint),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(hintText: context.l10n.adminTrainerDescriptionHint),
              ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
        AccentButton(
          label: context.l10n.commonCreate,
          onPressed: () {
            if (_validate()) {
              Navigator.of(context).pop(
                _AddTrainerResult(
                  fullName: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                  photoUrl: _photoController.text.trim().isEmpty ? null : _photoController.text.trim(),
                  hourlyRate: double.parse(_rateController.text.trim()),
                  bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _AddTrainerResult {
  final String fullName;
  final String email;
  final String password;
  final String? photoUrl;
  final double hourlyRate;
  final String? bio;

  const _AddTrainerResult({
    required this.fullName,
    required this.email,
    required this.password,
    this.photoUrl,
    required this.hourlyRate,
    this.bio,
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
        Text(context.l10n.commonMembers, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.adminSearchAllHint,
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
                  items: [
                    DropdownMenuItem(
                        value: 'all',
                        child: Text(context.l10n.commonAll,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'gyms',
                        child: Text(context.l10n.commonGyms,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'members',
                        child: Text(context.l10n.commonMembers,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'trainers',
                        child: Text(context.l10n.commonTrainers,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                  labelText: context.l10n.commonType,
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
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.l10n.adminAllGyms, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  labelText: context.l10n.commonGym,
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
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.l10n.adminAllCities, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  labelText: context.l10n.commonCity,
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
                  items: [
                    DropdownMenuItem(
                        value: 'all',
                        child: Text(context.l10n.adminAllStatuses,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'active',
                        child: Text(context.l10n.commonActive,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'inactive',
                        child: Text(context.l10n.commonInactive,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                  labelText: context.l10n.commonStatus,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            AccentButton(label: context.l10n.commonSearch, onPressed: _runSearch),
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
                    ? Center(child: Text(context.l10n.commonNoResults))
                    : ListView(
                        children: [
                          if (showGyms) _SearchSectionTitle(title: context.l10n.commonGyms, count: results.gyms.length),
                          if (showGyms)
                            ...results.gyms.map((gym) => _GymSearchRow(gym: gym)),
                          if (showMembers) _SearchSectionTitle(title: context.l10n.commonMembers, count: results.members.length),
                          if (showMembers)
                            ...results.members.map((member) => _MemberSearchRow(member: member)),
                          if (showTrainers) _SearchSectionTitle(title: context.l10n.commonTrainers, count: results.trainers.length),
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
                  Text(context.l10n.adminHoursLabel(gym.workHours ?? ''),
                      style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleBadge(
                  color: gym.isActive ? AppColors.green : AppColors.red,
                  label: gym.isActive ? context.l10n.commonActive : context.l10n.commonInactive),
              const SizedBox(height: 6),
              Text(context.l10n.adminMembersCount(gym.memberCount),
                  style: const TextStyle(color: AppColors.muted)),
              Text(context.l10n.adminTrainersCount(gym.trainerCount),
                  style: const TextStyle(color: AppColors.muted)),
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
                      ? [Text(context.l10n.adminNoMemberships, style: const TextStyle(color: AppColors.muted))]
                      : memberships
                          .map((m) => CircleBadge(color: AppColors.accentDeep, label: '${m.gymName} • ${m.status}'))
                          .toList(),
                ),
              ],
            ),
          ),
          Text(
            AppDateTimeFormat.date(member.createdAtUtc),
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
    final gymsLabel = trainer.gyms.isEmpty ? context.l10n.adminNoGyms : trainer.gyms.join(', ');
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
                  Text(context.l10n.adminTrainerRate(trainer.hourlyRate!.toStringAsFixed(0)),
                      style: const TextStyle(color: AppColors.muted)),
                Text(gymsLabel, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleBadge(
                  color: trainer.isActive ? AppColors.green : AppColors.red,
                  label: trainer.isActive ? context.l10n.commonActive : context.l10n.commonInactive),
              const SizedBox(height: 6),
              Text(context.l10n.adminTrainerUpcoming(trainer.upcomingSessions),
                  style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainersPanel extends StatefulWidget {
  final List<Trainer> trainers;
  final bool canManage;
  final VoidCallback? onRefresh;

  const _TrainersPanel({
    required this.trainers,
    required this.canManage,
    this.onRefresh,
  });

  @override
  State<_TrainersPanel> createState() => _TrainersPanelState();
}

class _TrainersPanelState extends State<_TrainersPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FitCityApi _api = FitCityApi.instance;
  String? _statusMessage;
  bool _busy = false;

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

  Future<void> _openAddTrainerDialog() async {
    final result = await showDialog<_AddTrainerResult>(
      context: context,
      builder: (context) => const _AddTrainerDialog(),
    );
    if (result == null) {
      return;
    }
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    try {
      await _api.createGymTrainer(
        email: result.email,
        fullName: result.fullName,
        password: result.password,
        photoUrl: result.photoUrl,
        hourlyRate: result.hourlyRate,
        bio: result.bio,
      );
      widget.onRefresh?.call();
      setState(() => _statusMessage = context.l10n.adminTrainerAdded);
    } on FitCityApiException catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    } catch (error) {
      setState(() => _statusMessage = context.l10n.errorsGeneric);
    } finally {
      setState(() => _busy = false);
    }
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
            Text(context.l10n.commonTrainers, style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Text(context.l10n.adminTrainersActive(trainers.length),
                    style: const TextStyle(color: AppColors.muted)),
                if (widget.canManage) ...[
                  const SizedBox(width: 12),
                  AccentButton(
                    label: _busy ? context.l10n.commonWorking : context.l10n.adminAddTrainer,
                    onPressed: _busy ? null : _openAddTrainerDialog,
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.adminSearchTrainerHint,
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: trainers.isEmpty
                ? Center(child: Text(context.l10n.adminNoTrainersFound))
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
                                  trainer.certifications ?? context.l10n.adminNoCertifications,
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          if (trainer.hourlyRate != null)
                            Text(
                              context.l10n.adminTrainerRate(trainer.hourlyRate!.toStringAsFixed(0)),
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          if (trainer.hourlyRate != null) const SizedBox(width: 12),
                          Text(trainer.isActive ? context.l10n.commonActive : context.l10n.commonInactive,
                              style: TextStyle(color: trainer.isActive ? AppColors.green : AppColors.red)),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => _openTrainerDetail(trainer),
                            child: Text(context.l10n.commonView),
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
  final Future<void> Function() onRefresh;

  const _GymsPanel({required this.gyms, required this.onRefresh});

  @override
  State<_GymsPanel> createState() => _GymsPanelState();
}

class _GymsPanelState extends State<_GymsPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _creating = false;
  String? _statusMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateGymDialog() async {
    final payload = await showDialog<_CreateGymPayload>(
      context: context,
      builder: (context) => _CreateGymDialog(existingGyms: widget.gyms),
    );
    if (payload == null) {
      return;
    }
    setState(() {
      _creating = true;
      _statusMessage = null;
    });
    try {
      await _api.createGym(
        name: payload.name,
        address: payload.address,
        city: payload.city,
        latitude: payload.latitude,
        longitude: payload.longitude,
        phoneNumber: payload.phoneNumber,
        description: payload.description,
        workHours: payload.workHours,
      );
      await widget.onRefresh();
      if (mounted) {
        setState(() => _statusMessage = context.l10n.adminGymCreated);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _statusMessage = mapApiError(context, error));
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
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

  String _formatGymLocation(Gym gym) {
    final parts = [gym.address, gym.city].where((item) => item.trim().isNotEmpty).toList();
    if (parts.isEmpty) {
      return context.l10n.adminGymLocationMissing;
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final gyms = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.commonGyms, style: Theme.of(context).textTheme.titleMedium),
            AccentButton(
              label: _creating ? context.l10n.commonWorking : context.l10n.adminAddGymPlus,
              onPressed: _creating ? null : _openCreateGymDialog,
              width: 160,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.adminSearchGymsHint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
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
            child: gyms.isEmpty
                ? Center(child: Text(context.l10n.adminNoGymsFound))
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
                                  Text(_formatGymLocation(gym), style: const TextStyle(color: AppColors.muted)),
                                ],
                              ),
                            ),
                          Text(
                            gym.isActive ? context.l10n.commonActive : context.l10n.commonInactive,
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

class _PaymentsPanel extends StatefulWidget {
  const _PaymentsPanel();

  @override
  State<_PaymentsPanel> createState() => _PaymentsPanelState();
}

class _PaymentsPanelState extends State<_PaymentsPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _queryController = TextEditingController();
  List<AdminPayment> _payments = [];
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.adminPayments(
        fromUtc: _fromDate,
        toUtc: _toDate,
        query: _queryController.text.trim().isEmpty ? null : _queryController.text.trim(),
      );
      setState(() => _payments = items);
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
    await _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.commonPayments, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: context.l10n.adminSearchPaymentsHint,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _loadPayments(),
              ),
            ),
            OutlinedButton(
              onPressed: () => _pickDate(isFrom: true),
              child: Text(_fromDate == null ? context.l10n.commonFromDate : AppDateTimeFormat.date(_fromDate)),
            ),
            OutlinedButton(
              onPressed: () => _pickDate(isFrom: false),
              child: Text(_toDate == null ? context.l10n.commonToDate : AppDateTimeFormat.date(_toDate)),
            ),
            TextButton(onPressed: _loadPayments, child: Text(context.l10n.commonRefresh)),
          ],
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
                    : _payments.isEmpty
                        ? Center(child: Text(context.l10n.adminNoPaymentsFound))
                        : ListView.separated(
                            itemCount: _payments.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final payment = _payments[index];
                              final when = AppDateTimeFormat.dateTime(payment.paidAtUtc);
                              return Row(
                                children: [
                                  const Icon(Icons.payments_outlined, color: AppColors.muted),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.memberName ?? context.l10n.commonMember,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          payment.gymName ?? context.l10n.commonGym,
                                          style: const TextStyle(color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(payment.type, style: const TextStyle(color: AppColors.muted)),
                                  const SizedBox(width: 12),
                                  Text(payment.method, style: const TextStyle(color: AppColors.muted)),
                                  const SizedBox(width: 12),
                                  Text(context.l10n.adminCurrencyKm(payment.amount.toStringAsFixed(2)),
                                      style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(payment.status, style: const TextStyle(color: AppColors.accentDeep)),
                                      Text(when, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
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

class _CreateGymPayload {
  final String name;
  final String? address;
  final String? city;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? description;
  final String? workHours;

  _CreateGymPayload({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.phoneNumber,
    this.description,
    this.workHours,
  });
}

class _GeoSearchResult {
  final String label;
  final LatLng location;
  final String? address;
  final String? city;

  const _GeoSearchResult({
    required this.label,
    required this.location,
    this.address,
    this.city,
  });
}

class _CreateGymDialog extends StatefulWidget {
  final List<Gym> existingGyms;

  const _CreateGymDialog({required this.existingGyms});

  @override
  State<_CreateGymDialog> createState() => _CreateGymDialogState();
}

class _CreateGymDialogState extends State<_CreateGymDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _workHoursController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng? _selectedLocation;
  List<_GeoSearchResult> _searchResults = [];
  bool _searching = false;
  String? _error;

  LatLng get _initialCenter {
    final withCoords = widget.existingGyms
        .where((g) => g.latitude != null && g.longitude != null)
        .map((g) => LatLng(g.latitude!, g.longitude!))
        .toList();
    if (withCoords.isNotEmpty) {
      return withCoords.first;
    }
    return const LatLng(0, 0);
  }

  double get _initialZoom => _selectedLocation == null ? 3 : 14;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _workHoursController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
      _searchResults = [];
    });
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&limit=5&addressdetails=1&q=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http.get(uri, headers: {'User-Agent': 'fitcity-app'});
      if (response.statusCode != 200) {
        throw Exception('Search failed');
      }
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      final results = data.map((item) {
        final map = item as Map<String, dynamic>;
        final lat = double.tryParse(map['lat']?.toString() ?? '');
        final lon = double.tryParse(map['lon']?.toString() ?? '');
        final display = map['display_name']?.toString() ?? query;
        final address = map['address'] as Map<String, dynamic>?;
        final city = address?['city']?.toString() ??
            address?['town']?.toString() ??
            address?['village']?.toString();
        if (lat == null || lon == null) {
          return null;
        }
        return _GeoSearchResult(
          label: display,
          location: LatLng(lat, lon),
          address: display,
          city: city,
        );
      }).whereType<_GeoSearchResult>().toList();
      setState(() => _searchResults = results);
      if (results.isNotEmpty) {
        _selectSearchResult(results.first);
      }
    } catch (_) {
      setState(() => _error = context.l10n.adminGymAddressSearchFailed);
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  void _selectSearchResult(_GeoSearchResult result) {
    setState(() {
      _selectedLocation = result.location;
      _addressController.text = result.address ?? _addressController.text;
      if (_cityController.text.trim().isEmpty && result.city != null) {
        _cityController.text = result.city!;
      }
    });
    _mapController.move(result.location, 15);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.adminGymNameRequired);
      return;
    }
    final location = _selectedLocation;
    if (location == null) {
      setState(() => _error = context.l10n.adminGymLocationRequired);
      return;
    }
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    Navigator.of(context).pop(
      _CreateGymPayload(
        name: name,
        address: address.isEmpty ? null : address,
        city: city.isEmpty ? null : city,
        latitude: location.latitude,
        longitude: location.longitude,
        phoneNumber: _emptyOrNull(_phoneController.text),
        description: _emptyOrNull(_descriptionController.text),
        workHours: _emptyOrNull(_workHoursController.text),
      ),
    );
  }

  String? _emptyOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final location = _selectedLocation;
    return AlertDialog(
      title: Text(context.l10n.adminAddGymTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: context.l10n.adminGymNameLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: context.l10n.adminGymPhoneLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: context.l10n.adminGymAddressLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(labelText: context.l10n.adminGymCityLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _workHoursController,
                    decoration: InputDecoration(labelText: context.l10n.adminGymWorkHoursLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: context.l10n.adminGymDescriptionLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(context.l10n.adminGymLocationLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: context.l10n.adminGymSearchAddressHint,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _searchAddress(),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _searching ? null : _searchAddress,
                  child: Text(_searching ? context.l10n.commonWorking : context.l10n.adminGymSearchAddressAction),
                ),
              ],
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return InkWell(
                      onTap: () => _selectSearchResult(result),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(result.label, style: const TextStyle(color: AppColors.ink)),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _initialZoom,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    onTap: (_, position) {
                      setState(() {
                        _selectedLocation = position;
                        _error = null;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'fitcity_flutter',
                    ),
                    if (location != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: location,
                            width: 48,
                            height: 48,
                            child: const Icon(Icons.location_on, color: AppColors.accentDeep, size: 42),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                location == null
                    ? context.l10n.adminGymLocationHint
                    : context.l10n.adminGymLocationLatLng(
                        location.latitude.toStringAsFixed(5),
                        location.longitude.toStringAsFixed(5),
                      ),
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
        AccentButton(label: context.l10n.adminCreateGym, onPressed: _submit, width: 160),
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
        final gyms = _isGymAdmin ? [await _api.adminGym()] : await _api.adminGyms();
        setState(() {
          _gyms = gyms;
          if (_selectedGym == null && gyms.isNotEmpty) {
            _selectedGym = gyms.first;
          }
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
          Text(context.l10n.adminAccessLogsTitle, style: Theme.of(context).textTheme.titleMedium),
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
                          labelText: context.l10n.commonGym,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  OutlinedButton(
                    onPressed: () => _pickDate(isFrom: true),
                    child: Text(_fromDate == null ? context.l10n.commonFromDate : AppDateTimeFormat.date(_fromDate)),
                  ),
                  OutlinedButton(
                    onPressed: () => _pickDate(isFrom: false),
                    child: Text(_toDate == null ? context.l10n.commonToDate : AppDateTimeFormat.date(_toDate)),
                  ),
                  SizedBox(
                    width: statusWidth,
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: [
                        DropdownMenuItem(value: 'all', child: Text(context.l10n.commonAll)),
                        DropdownMenuItem(value: 'granted', child: Text(context.l10n.adminAccessGranted)),
                        DropdownMenuItem(value: 'denied', child: Text(context.l10n.adminAccessDenied)),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _status = value);
                        _loadLogs();
                      },
                      decoration: InputDecoration(
                        labelText: context.l10n.commonStatus,
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
                          hintText: context.l10n.adminAccessLogSearchHint,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _loadLogs(),
                      ),
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
                        ? Center(
                            child: Text(context.l10n.adminNoAccessLogs, style: const TextStyle(color: AppColors.muted)))
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
                                      AppDateTimeFormat.dateTime(log.checkedAtUtc),
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
          title: Text(context.l10n.adminAccessLogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailHeaderRow(label: context.l10n.commonMember, value: log.memberName),
              _DetailHeaderRow(label: context.l10n.commonGym, value: log.gymName),
              _DetailHeaderRow(label: context.l10n.commonStatus, value: log.status),
              _DetailHeaderRow(label: context.l10n.commonReason, value: log.reason),
              _DetailHeaderRow(label: context.l10n.commonTime, value: AppDateTimeFormat.dateTime(log.checkedAtUtc)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonClose)),
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
  String _statusFilter = 'pending';
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
    if (_statusFilter != 'all') {
      items = items.where((r) => r.status.toLowerCase() == _statusFilter).toList();
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

  Future<void> _decideRequest(MembershipRequest request, bool approve, {String? rejectionReason}) async {
    setState(() {
      _statusMessage = null;
      _submitting = true;
    });
    try {
      final updated = await _api.decideMembershipRequest(
        requestId: request.id,
        approve: approve,
        rejectionReason: rejectionReason,
      );
      setState(() {
        _requests = _requests.map((item) => item.id == request.id ? updated : item).toList();
        _statusMessage =
            approve ? context.l10n.adminRequestApproved : context.l10n.adminRequestRejected;
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

  Future<String?> _promptRejectionReason() async {
    final defaultReason = context.l10n.adminDefaultRejectionReason;
    final controller = TextEditingController(text: defaultReason);
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.adminRejectMembershipTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.adminRejectionReason),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: defaultReason,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(context.l10n.commonCancel)),
            TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                child: Text(context.l10n.commonRejected)),
          ],
        );
      },
    );
    return result;
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
            Text(context.l10n.adminMembershipRequests, style: Theme.of(context).textTheme.titleMedium),
            Text(context.l10n.adminRecordsCount(items.length), style: const TextStyle(color: AppColors.muted)),
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
                Text(context.l10n.adminNotificationsLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                  hintText: context.l10n.adminSearchRequestsHint,
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
                items: [
                  DropdownMenuItem(value: 'all', child: Text(context.l10n.commonAll)),
                  DropdownMenuItem(value: 'pending', child: Text(context.l10n.commonPending)),
                  DropdownMenuItem(value: 'approved', child: Text(context.l10n.commonApproved)),
                  DropdownMenuItem(value: 'rejected', child: Text(context.l10n.commonRejected)),
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
                ? Center(child: Text(context.l10n.adminNoMembershipRequests))
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
                                    member?.fullName ?? context.l10n.commonMember,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    member?.email ?? context.l10n.commonGym,
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
                              onPressed: !canDecide
                                  ? null
                                  : () async {
                                      final reason = await _promptRejectionReason();
                                      if (reason == null) {
                                        return;
                                      }
                                      await _decideRequest(request, false, rejectionReason: reason);
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.red,
                                side: const BorderSide(color: AppColors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(context.l10n.commonRejected),
                            ),
                            const SizedBox(width: 8),
                            AccentButton(
                              label: _submitting ? context.l10n.commonUpdating : context.l10n.commonApprove,
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
        Text(context.l10n.commonNotifications, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.adminSearchNotificationsHint,
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
                ? Center(child: Text(context.l10n.adminNoNotifications))
                : ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Row(
                        children: [
                          CircleBadge(
                            color: item.isRead ? AppColors.muted : AppColors.accentDeep,
                            label: item.isRead ? context.l10n.notificationRead : context.l10n.notificationNew,
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
        title: Text(context.l10n.adminDeleteGymPlanTitle),
        content: Text(context.l10n.adminDeleteGymPlanConfirm(plan.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
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
            Text(context.l10n.adminReferenceData, style: Theme.of(context).textTheme.titleMedium),
            AccentButton(label: context.l10n.adminAddPlan, onPressed: () => _openPlanDialog()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.l10n.adminSearchPlansHint,
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
                  DropdownMenuItem<String?>(value: null, child: Text(context.l10n.adminAllGyms)),
                  ...widget.gyms.map((gym) => DropdownMenuItem<String?>(value: gym.id, child: Text(gym.name))),
                ],
                isExpanded: true,
                onChanged: (value) {
                  setState(() => _selectedGymId = value);
                  _loadPlans();
                },
                decoration: InputDecoration(
                  labelText: context.l10n.commonGym,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AccentButton(label: context.l10n.commonSearch, onPressed: _loadPlans),
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
                    ? Center(child: Text(context.l10n.adminNoGymPlans))
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
                                    Text(
                                        context.l10n.adminPlanLine(plan.gymName, plan.durationMonths),
                                        style: const TextStyle(color: AppColors.muted)),
                                    Text(
                                        context.l10n.adminPlanPrice(plan.price.toStringAsFixed(2)),
                                        style: const TextStyle(color: AppColors.muted)),
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
                                    label: plan.isActive ? context.l10n.commonActive : context.l10n.commonInactive,
                                  ),
                                  const SizedBox(height: 6),
                                  TextButton(
                                      onPressed: () => _openPlanDialog(plan: plan),
                                      child: Text(context.l10n.adminEdit)),
                                  TextButton(
                                    onPressed: () => _deletePlan(plan),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.red),
                                    child: Text(context.l10n.commonDelete),
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
      title: Text(widget.plan == null ? context.l10n.adminAddGymPlanTitle : context.l10n.adminEditGymPlanTitle),
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
                  labelText: context.l10n.commonGym,
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.commonName,
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
                  labelText: context.l10n.commonPriceKm,
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
                  labelText: context.l10n.commonDurationMonths,
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
                  labelText: context.l10n.commonDescription,
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: Text(context.l10n.commonActive),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(context.l10n.commonSave)),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return const AdminSettingsPanel();
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
                return _DetailError(message: context.l10n.adminMemberDetailNotFound);
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
                        child: Text(context.l10n.commonBack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailHeaderRow(label: context.l10n.commonEmail, value: detail.member.email),
                  _DetailHeaderRow(label: context.l10n.commonPhone, value: detail.member.phoneNumber ?? '-'),
                  _DetailHeaderRow(
                    label: context.l10n.adminMemberSince,
                    value: AppDateTimeFormat.dateTime(detail.member.createdAtUtc),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleBadge(
                        color: detail.qrStatus == 'Active' ? AppColors.green : AppColors.red,
                        label: context.l10n.adminQrStatus(detail.qrStatus),
                      ),
                      const SizedBox(width: 12),
                      Text(
                    detail.qrExpiresAtUtc == null
                        ? context.l10n.adminNoActiveQr
                        : context.l10n.adminQrExpires(AppDateTimeFormat.dateTime(detail.qrExpiresAtUtc)),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.lastAccessAtUtc == null
                        ? context.l10n.adminNoAccessLogsYet
                        : context.l10n.adminLastAccess(
                            AppDateTimeFormat.dateTime(detail.lastAccessAtUtc),
                            detail.lastAccessGymName ?? '-',
                          ),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DetailCard(
                            title: context.l10n.commonMemberships,
                            child: memberships.isEmpty
                                ? Text(context.l10n.adminNoMembershipsYet,
                                    style: const TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: memberships.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = memberships[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.status,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(AppDateTimeFormat.dateTime(item.endDateUtc),
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
                            title: context.l10n.bookingsTitle,
                            child: bookings.isEmpty
                                ? Text(context.l10n.adminNoBookingsYet,
                                    style: const TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: bookings.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = bookings[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.status.isEmpty ? context.l10n.commonUnknown : item.status} • ${item.trainerName.isNotEmpty ? item.trainerName : context.l10n.commonTrainer}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(AppDateTimeFormat.dateTime(item.startUtc),
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
                          child: Text(context.l10n.commonDelete),
                        ),
                      const Spacer(),
                      AccentButton(
                        label: context.l10n.commonClose,
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
                return _DetailError(message: context.l10n.adminTrainerDetailNotFound);
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
                        child: Text(context.l10n.commonBack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (detail.trainer.hourlyRate != null)
                    _DetailHeaderRow(
                      label: context.l10n.commonRate,
                      value: context.l10n.adminTrainerRate(detail.trainer.hourlyRate!.toStringAsFixed(0)),
                    ),
                  _DetailHeaderRow(label: context.l10n.commonBio, value: detail.trainer.bio ?? '-'),
                  _DetailHeaderRow(label: context.l10n.trainerCertifications, value: detail.trainer.certifications ?? '-'),
                  _DetailHeaderRow(
                      label: context.l10n.commonStatus,
                      value: detail.trainer.isActive ? context.l10n.commonActive : context.l10n.commonInactive),
                  const SizedBox(height: 12),
                  Text(context.l10n.commonGyms, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: detail.gyms.isEmpty
                        ? [
                            Text(context.l10n.adminNoGymAssociation,
                                style: const TextStyle(color: AppColors.muted))
                          ]
                        : detail.gyms.map((gym) => CircleBadge(color: AppColors.accentDeep, label: gym.name)).toList(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DetailCard(
                            title: context.l10n.profileSchedule,
                            child: detail.schedules.isEmpty
                                ? Text(context.l10n.adminNoScheduleEntries,
                                    style: const TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: detail.schedules.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = detail.schedules[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              AppDateTimeFormat.range(item.startUtc, item.endUtc),
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          CircleBadge(
                                            color: item.isAvailable ? AppColors.green : AppColors.red,
                                            label: item.isAvailable
                                                ? context.l10n.bookingSlotAvailable
                                                : context.l10n.bookingSlotBooked,
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
                            title: context.l10n.adminSessionsTitle,
                            child: detail.sessions.isEmpty
                                ? Text(context.l10n.adminNoSessionsRecorded,
                                    style: const TextStyle(color: AppColors.muted))
                                : ListView.separated(
                                    itemCount: detail.sessions.length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = detail.sessions[index];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.status,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(AppDateTimeFormat.dateTime(item.startUtc),
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
                        label: context.l10n.commonClose,
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

