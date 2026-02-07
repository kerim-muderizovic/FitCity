import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/admin_settings_panel.dart';
import '../../widgets/common.dart';
import '../../widgets/language_selector.dart';

class DesktopAdminScreen extends StatefulWidget {
  const DesktopAdminScreen({super.key});

  @override
  State<DesktopAdminScreen> createState() => _DesktopAdminScreenState();
}

class _DesktopAdminScreenState extends State<DesktopAdminScreen> {
  final FitCityApi _api = FitCityApi.instance;
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;
  List<Gym> _gyms = [];
  List<Membership> _memberships = [];
  List<MembershipRequest> _membershipRequests = [];
  List<AppNotification> _notifications = [];
  bool _shownRequestAlert = false;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final gyms = await _api.adminGyms();
      final memberships = await _api.memberships();
      final requests = await _api.membershipRequests();
      final notifications = await _api.notifications();
      setState(() {
        _gyms = gyms;
        _memberships = memberships;
        _membershipRequests = requests;
        _notifications = notifications;
      });
      await _maybeShowRequestPopup(notifications);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      _AdminSection(context.l10n.adminSectionManageGyms),
      _AdminSection(context.l10n.adminSectionManageMembers),
      _AdminSection(context.l10n.adminSectionMembershipRequests),
      _AdminSection(context.l10n.adminSectionPayments),
      _AdminSection(context.l10n.adminSectionSettings),
    ];
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.red)))
            : _buildSectionContent(context);
    return Row(
      children: [
        Container(
          width: 220,
          color: AppColors.paper,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.adminLoginTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              for (var i = 0; i < sections.length; i++) ...[
                _NavItem(
                  label: sections[i].label,
                  selected: _selectedIndex == i,
                  onTap: () => setState(() => _selectedIndex = i),
                ),
                const SizedBox(height: 10),
              ],
            ],
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
    );
  }

  Widget _buildSectionContent(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _GymsPanel(gyms: _gyms);
      case 1:
        return _MembersPanel(memberships: _memberships);
      case 2:
        return _RequestsPanel(requests: _membershipRequests, notifications: _notifications);
      case 3:
        return const _PaymentsPanel();
      case 4:
        return const _SettingsPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _maybeShowRequestPopup(List<AppNotification> notifications) async {
    if (_shownRequestAlert || !mounted) {
      return;
    }
    final pending = notifications
        .where((n) => !n.isRead && (n.category ?? '').toLowerCase() == 'membership_request')
        .toList();
    if (pending.isEmpty) {
      return;
    }
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
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.adminViewRequests)),
          ],
        );
      },
    );
    if (!mounted) {
      return;
    }
    if (view == true) {
      setState(() => _selectedIndex = 2);
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
}

class _AdminSection {
  final String label;

  const _AdminSection(this.label);
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.ink : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _GymsPanel extends StatelessWidget {
  final List<Gym> gyms;

  const _GymsPanel({required this.gyms});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF3FB6FF), Color(0xFF6A86FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  context.l10n.adminDashboardCity,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
              Positioned(left: 24, top: 30, child: _MapPin(label: context.l10n.adminMapPinLabel('G1'))),
              Positioned(right: 40, top: 28, child: _MapPin(label: context.l10n.adminMapPinLabel('G2'))),
              Positioned(left: 120, bottom: 26, child: _MapPin(label: context.l10n.adminMapPinLabel('G3'))),
              Positioned(right: 120, bottom: 42, child: _MapPin(label: context.l10n.adminMapPinLabel('G4'))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: gyms.isEmpty ? 0.2 : 0.6,
                            strokeWidth: 10,
                            backgroundColor: AppColors.slate,
                            color: AppColors.sky,
                          ),
                          Center(child: Text('${(gyms.isEmpty ? 20 : 60)}%')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.adminActiveGyms),
                        const SizedBox(height: 8),
                        Text(context.l10n.adminTotalGyms(gyms.length)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            AccentButton(label: context.l10n.adminAddGymPlus, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(context.l10n.adminGymListTitle, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 10),
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
                                Text('${gym.address}, ${gym.city}', style: const TextStyle(color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Text(gym.isActive ? context.l10n.commonActive : context.l10n.commonInactive,
                              style: TextStyle(color: gym.isActive ? AppColors.green : AppColors.red)),
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

class _MembersPanel extends StatefulWidget {
  final List<Membership> memberships;

  const _MembersPanel({required this.memberships});

  @override
  State<_MembersPanel> createState() => _MembersPanelState();
}

class _MembersPanelState extends State<_MembersPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _searchController = TextEditingController();
  late List<Membership> _memberships;
  String? _statusMessage;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _memberships = List.of(widget.memberships);
  }

  @override
  void didUpdateWidget(covariant _MembersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memberships != widget.memberships) {
      _memberships = List.of(widget.memberships);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Membership> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _memberships;
    }
    return _memberships.where((membership) {
      return membership.userId.toLowerCase().contains(query) ||
          membership.gymId.toLowerCase().contains(query) ||
          membership.status.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _validateMembership(Membership membership) async {
    try {
      final isValid = await _api.validateMembership(membership.id);
      setState(() => _statusMessage =
          isValid ? context.l10n.adminMembershipValid : context.l10n.adminMembershipInvalid);
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  Future<void> _issueQr(Membership membership) async {
    try {
      final qr = await _api.issueQr(membership.id);
      setState(() => _statusMessage = context.l10n.adminQrIssued(qr.token));
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  Future<void> _confirmDelete(Membership membership) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.adminDeleteMemberTitle),
          content: Text(context.l10n.adminDeleteMemberConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _deleteMember(membership.userId);
    }
  }

  Future<void> _deleteMember(String memberId) async {
    setState(() {
      _deleting = true;
      _statusMessage = null;
    });
    try {
      await _api.deleteMember(memberId);
      setState(() {
        _memberships.removeWhere((m) => m.userId == memberId);
        _statusMessage = context.l10n.adminMemberDeleted;
      });
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    } finally {
      setState(() => _deleting = false);
    }
  }

  void _showDetails(Membership membership) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.adminMemberDetails),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.adminMembershipStatus(membership.status)),
              Text(context.l10n.adminMembershipEnds(AppDateTimeFormat.dateTime(membership.endDateUtc))),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonClose))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberships = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.adminManageMembers, style: Theme.of(context).textTheme.titleMedium),
            Text(context.l10n.adminRecordsCount(memberships.length),
                style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 12),
      TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.adminSearchMembershipsHint,
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
            child: memberships.isEmpty
                ? Center(child: Text(context.l10n.adminNoMembershipsFound))
                : ListView.separated(
                    itemCount: memberships.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final membership = memberships[index];
                      return InkWell(
                        onTap: () => _showDetails(membership),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.muted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(context.l10n.adminMemberLabel,
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            Text(membership.status, style: const TextStyle(color: AppColors.accentDeep)),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => _validateMembership(membership),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accentDeep,
                                side: const BorderSide(color: AppColors.accentDeep),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(context.l10n.adminValidate),
                            ),
                            const SizedBox(width: 8),
                            AccentButton(
                              label: context.l10n.membershipIssueQr,
                              onPressed: () => _issueQr(membership),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _deleting ? null : () => _confirmDelete(membership),
                              style: TextButton.styleFrom(foregroundColor: AppColors.red),
                              child: Text(_deleting ? context.l10n.commonDeleting : context.l10n.commonDelete),
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
}

class _RequestsPanel extends StatefulWidget {
  final List<MembershipRequest> requests;
  final List<AppNotification> notifications;

  const _RequestsPanel({required this.requests, required this.notifications});

  @override
  State<_RequestsPanel> createState() => _RequestsPanelState();
}

class _RequestsPanelState extends State<_RequestsPanel> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _searchController = TextEditingController();
  late List<MembershipRequest> _requests;
  late List<AppNotification> _notifications;
  String _statusFilter = 'pending';
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _requests = List.of(widget.requests);
    _notifications = List.of(widget.notifications);
  }

  @override
  void didUpdateWidget(covariant _RequestsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests) {
      _requests = List.of(widget.requests);
    }
    if (oldWidget.notifications != widget.notifications) {
      _notifications = List.of(widget.notifications);
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
      return request.userId.toLowerCase().contains(query) ||
          request.gymId.toLowerCase().contains(query) ||
          request.status.toLowerCase().contains(query) ||
          request.paymentStatus.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _decideRequest(MembershipRequest request, bool approve, {String? rejectionReason}) async {
    setState(() => _statusMessage = null);
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
    } catch (error) {
      setState(() => _statusMessage = error.toString());
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
                  border: OutlineInputBorder(),
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
                      final canDecide = request.status.toLowerCase() == 'pending';
                      return Row(
                        children: [
                          const Icon(Icons.assignment_ind_outlined, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.l10n.adminMembershipRequestLabel,
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
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
                              label: context.l10n.commonApprove,
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
        Text(context.l10n.adminPaymentsTitle, style: Theme.of(context).textTheme.titleMedium),
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return const AdminSettingsPanel();
  }
}

class _MapPin extends StatelessWidget {
  final String label;

  const _MapPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: Text(label, style: const TextStyle(color: AppColors.sky)),
    );
  }
}
