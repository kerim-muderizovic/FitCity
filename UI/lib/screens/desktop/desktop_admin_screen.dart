import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

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

  final List<_AdminSection> _sections = const [
    _AdminSection('Manage gyms'),
    _AdminSection('Manage members'),
    _AdminSection('Membership requests'),
    _AdminSection('Payments'),
    _AdminSection('Settings'),
  ];

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
      final gyms = await _api.gyms();
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
              Text('FitCity Admin', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              for (var i = 0; i < _sections.length; i++) ...[
                _NavItem(
                  label: _sections[i].label,
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
          title: const Text('New membership request'),
          content: Text('You have ${pending.length} new membership request notification${pending.length == 1 ? '' : 's'}.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Later')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('View requests')),
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
                  'Sarajevo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
              const Positioned(left: 24, top: 30, child: _MapPin(label: 'G1')),
              const Positioned(right: 40, top: 28, child: _MapPin(label: 'G2')),
              const Positioned(left: 120, bottom: 26, child: _MapPin(label: 'G3')),
              const Positioned(right: 120, bottom: 42, child: _MapPin(label: 'G4')),
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
                        const Text('Active gyms'),
                        const SizedBox(height: 8),
                        Text('${gyms.length} total'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            AccentButton(label: '+ Add Gym', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Gym list', style: Theme.of(context).textTheme.titleMedium),
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
                          Text(gym.isActive ? 'Active' : 'Inactive', style: TextStyle(color: gym.isActive ? AppColors.green : AppColors.red)),
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
      setState(() => _statusMessage = isValid ? 'Membership valid.' : 'Membership invalid.');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  Future<void> _issueQr(Membership membership) async {
    try {
      final qr = await _api.issueQr(membership.id);
      setState(() => _statusMessage = 'QR issued: ${qr.token}');
    } catch (error) {
      setState(() => _statusMessage = error.toString());
    }
  }

  Future<void> _confirmDelete(Membership membership) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete member'),
          content: const Text('This will permanently delete the member if no related records exist. Continue?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
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
        _statusMessage = 'Member deleted.';
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
          title: const Text('Member Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User ID: ${membership.userId}'),
              Text('Gym ID: ${membership.gymId}'),
              Text('Status: ${membership.status}'),
              Text('Ends: ${membership.endDateUtc.toLocal()}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
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
            Text('Manage members', style: Theme.of(context).textTheme.titleMedium),
            Text('${memberships.length} records', style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by user, gym, status',
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
                ? const Center(child: Text('No memberships found.'))
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
                                  Text('User ${membership.userId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text('Gym ${membership.gymId}', style: const TextStyle(color: AppColors.muted)),
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
                              child: const Text('Validate'),
                            ),
                            const SizedBox(width: 8),
                            AccentButton(
                              label: 'Issue QR',
                              onPressed: () => _issueQr(membership),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _deleting ? null : () => _confirmDelete(membership),
                              style: TextButton.styleFrom(foregroundColor: AppColors.red),
                              child: Text(_deleting ? 'Deleting...' : 'Delete'),
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
  String _statusFilter = 'Pending';
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
    if (_statusFilter != 'All') {
      items = items.where((r) => r.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
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

  Future<void> _decideRequest(MembershipRequest request, bool approve) async {
    setState(() => _statusMessage = null);
    try {
      final updated = await _api.decideMembershipRequest(requestId: request.id, approve: approve);
      setState(() {
        _requests = _requests.map((item) => item.id == request.id ? updated : item).toList();
        _statusMessage = approve ? 'Request approved.' : 'Request rejected.';
      });
    } catch (error) {
      setState(() => _statusMessage = error.toString());
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
                  hintText: 'Search by user, gym, status',
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
                      final canDecide = request.status.toLowerCase() == 'pending';
                      return Row(
                        children: [
                          const Icon(Icons.assignment_ind_outlined, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User ${request.userId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('Gym ${request.gymId}', style: const TextStyle(color: AppColors.muted)),
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
                            label: 'Approve',
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
            'No payments endpoint is exposed in the API yet. This section is ready for future integration.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Recent payouts', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Gym Downtown - 230.00'),
              Text('Gym East - 180.00'),
              Text('Trainers total - 140.00'),
            ],
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
