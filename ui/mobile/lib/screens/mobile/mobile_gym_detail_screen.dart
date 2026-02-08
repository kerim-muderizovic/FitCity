import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../services/notifications_socket.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/stripe_checkout.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import 'mobile_active_membership_screen.dart';
import 'mobile_booking_screen.dart';
import 'mobile_chat_screen.dart';
import 'mobile_gym_list_screen.dart';
import 'mobile_qr_screen.dart';
import 'mobile_trainer_detail_screen.dart';

class MobileGymDetailScreen extends StatefulWidget {
  final Gym? gym;
  final String? gymId;

  const MobileGymDetailScreen({super.key, this.gym, this.gymId});

  @override
  State<MobileGymDetailScreen> createState() => _MobileGymDetailScreenState();
}

class _MobileGymDetailScreenState extends State<MobileGymDetailScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final GymSelectionStore _selection = GymSelectionStore.instance;
  Gym? _gym;
  List<Trainer> _trainers = [];
  List<Review> _reviews = [];
  int _photoIndex = 0;
  bool _loading = true;
  bool _requesting = false;
  bool _paying = false;
  bool _membershipCheckoutPending = false;
  String? _error;
  String? _statusMessage;
  MembershipRequest? _membershipRequest;
  Membership? _activeMembership;
  Timer? _membershipRefreshTimer;
  String _membershipPaymentMethod = 'Card';
  DateTime? _membershipLastUpdatedUtc;
  late final void Function(Map<String, dynamic>) _notificationHandler;

  @override
  void initState() {
    super.initState();
    _notificationHandler = _handleNotification;
    _loadData();
    _startMembershipRefresh();
  }

  @override
  void dispose() {
    _membershipRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Gym? gym = widget.gym;
      if (gym == null && widget.gymId != null) {
        gym = await _api.gymById(widget.gymId!);
      }
      if (gym == null) {
        final gyms = await _api.gyms();
        if (gyms.isNotEmpty) {
          gym = gyms.first;
        }
      }
      if (gym == null) {
        setState(() {
          _error = 'No gyms available.';
          _loading = false;
        });
        return;
      }
      final trainers = await _api.trainersByGym(gym.id);
      final reviews = trainers.isNotEmpty ? await _api.reviewsForTrainer(trainers.first.id) : <Review>[];
      setState(() {
        _gym = gym;
        _trainers = trainers;
        _reviews = reviews;
      });
      if (gym != null) {
        _selection.selectGym(gym);
        await _loadMembershipState(gym.id);
      }
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _startMembershipRefresh() {
    _membershipRefreshTimer?.cancel();
    _membershipRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final session = _api.session.value;
      final gym = _gym;
      if (!mounted || session == null || session.user.role != 'User' || gym == null) {
        return;
      }
      await _loadMembershipState(gym.id);
    });
  }

  Future<void> _loadMembershipState(String gymId) async {
    final session = _api.session.value;
    if (session == null || session.user.role != 'User') {
      return;
    }
    try {
      final memberships = await _api.memberships();
      final now = DateTime.now().toUtc();
      final active = memberships.firstWhere(
        (item) => item.gymId == gymId && item.status == 'Active' && item.endDateUtc.isAfter(now),
        orElse: () => Membership(
          id: '',
          userId: '',
          gymId: '',
          startDateUtc: now,
          endDateUtc: now,
          status: '',
        ),
      );
        final requests = await _api.membershipRequests(gymId: gymId);
        final wasActive = _activeMembership != null;
        setState(() {
          _activeMembership = active.id.isEmpty ? null : active;
          _membershipRequest = requests.isNotEmpty ? requests.first : null;
          _membershipLastUpdatedUtc = DateTime.now().toUtc();
        });
        if (_membershipCheckoutPending && !wasActive && _activeMembership != null) {
          _membershipCheckoutPending = false;
          if (mounted) {
            _showMembershipPaymentSuccess();
          }
        }
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    }
  }

  Future<void> _startChat(Trainer trainer) async {
    try {
      final existing = await _findExistingConversation(trainer.userId);
      final created = existing ??
          await _api.createConversation(
            otherUserId: trainer.userId,
            title: context.l10n.bookingChatWithName(trainer.userName),
          );
      final conversation = existing ??
          Conversation(
            id: created.id,
            title: created.title,
            createdAtUtc: created.createdAtUtc,
            updatedAtUtc: created.updatedAtUtc,
            lastMessageAtUtc: created.lastMessageAtUtc,
            memberId: created.memberId,
            trainerId: created.trainerId,
            otherUserId: trainer.userId,
            otherUserName: trainer.userName,
            otherUserRole: 'Trainer',
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MobileChatDetailScreen(conversation: conversation)),
      );
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    }
  }

  Future<Conversation?> _findExistingConversation(String trainerUserId) async {
    final conversations = await _api.myConversations();
    for (final convo in conversations) {
      if (convo.otherUserId == trainerUserId) {
        return convo;
      }
    }
    return null;
  }

  Future<void> _requestMembership() async {
    if (_gym == null) {
      return;
    }
    if (_api.session.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.gymDetailSignInToRequest)),
      );
      return;
    }
    try {
      setState(() => _requesting = true);
      final request = await _api.requestMembership(gymId: _gym!.id);
      setState(() => _membershipRequest = request);
      await _loadMembershipState(_gym!.id);
      await _connectNotificationSocket();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.gymDetailMembershipRequest(request.status))),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapApiError(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  Future<void> _payMembershipRequest() async {
    final request = _membershipRequest;
    if (_gym == null || request == null) {
      return;
    }
    final method = await _selectMembershipPaymentMethod();
    if (method == null) {
      return;
    }
    if (method == 'Manual') {
      await _manualPayMembership(request.id);
      return;
    }
    if (method.toLowerCase() == 'paypal') {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paymentPayPalUnavailable)),
      );
      return;
    }
    setState(() {
      _membershipPaymentMethod = method;
      _paying = true;
    });
    try {
      final response = await _api.createMembershipCheckout(requestId: request.id);
      final launched = await launchStripeCheckout(
        context,
        response.url,
        invalidUrlMessage: context.l10n.paymentInvalidCheckoutUrl,
        launchFailedMessage: context.l10n.paymentLaunchFailed,
      );
      if (!launched) {
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() => _membershipCheckoutPending = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paymentOpenBrowser)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapApiError(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  Future<void> _manualPayMembership(String requestId) async {
    setState(() => _paying = true);
    try {
      final response = await _api.manualPayMembershipRequest(requestId: requestId);
      await _loadMembershipState(_gym!.id);
      if (!mounted) {
        return;
      }
      final qr = response.qr;
      if (qr != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MobileQrScreen(
              issue: qr,
              gymName: _gym?.name,
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapApiError(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  void _showMembershipPaymentSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 6), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          title: Text(context.l10n.membershipPaymentSuccessTitle),
          content: Text(context.l10n.paymentConfirmed),
        );
      },
    );
  }

  Future<void> _showQrPass() async {
    final membership = _activeMembership;
    if (membership == null) {
      return;
    }
    try {
      final issue = await _api.issueQr(membership.id);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MobileQrScreen(
            issue: issue,
            gymName: _gym?.name,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapApiError(context, error))),
      );
    }
  }

  Future<void> _connectNotificationSocket() async {
    final session = _api.session.value;
    if (session == null || session.user.role != 'User') {
      return;
    }
    final socket = NotificationsSocketService.instance;
    await socket.connect();
    socket.onNotificationNew(_notificationHandler);
  }

  void _handleNotification(Map<String, dynamic> payload) {
    final notification = AppNotification.fromJson(payload);
    final category = (notification.category ?? '').toLowerCase();
    if (category != 'membership') {
      return;
    }
    final message = notification.message.toLowerCase();
    if (!message.contains('approved') && !message.contains('rejected')) {
      return;
    }
    final gym = _gym;
    if (gym == null) {
      return;
    }
    _loadMembershipState(gym.id);
  }

  Future<String?> _selectMembershipPaymentMethod() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(context.l10n.paymentChooseMethod, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(context.l10n.paymentUseStripe),
                onTap: () => Navigator.of(context).pop('Card'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(context.l10n.paymentMarkPaid),
                onTap: () => Navigator.of(context).pop('Manual'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(context.l10n.gymDetailPayPal),
                onTap: () => Navigator.of(context).pop('PayPal'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = _gym;
    final role = _api.session.value?.user.role;
    final isTrainer = role == 'Trainer';
    final membership = _activeMembership;
    final request = _membershipRequest;
    final requestStatus = request?.status.toLowerCase();
    final paymentStatus = request?.paymentStatus.toLowerCase();
    return Scaffold(
      appBar: buildMobileAppBar(context, title: gym?.name ?? 'Gym'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.gyms),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.red)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gym?.name ?? 'Gym', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const CurrentGymIndicator(),
                        const SizedBox(height: 12),
                        _GymPhotoCarousel(
                          photos: _photoUrlsFor(gym),
                          onIndexChanged: (index) => setState(() => _photoIndex = index),
                        ),
                        if (_photoUrlsFor(gym).length > 1) ...[
                          const SizedBox(height: 8),
                          _PhotoDots(count: _photoUrlsFor(gym).length, activeIndex: _photoIndex),
                        ],
                        const SizedBox(height: 12),
                        Text(gym?.address ?? '', style: Theme.of(context).textTheme.bodyMedium),
                        if ((gym?.workHours ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(context.l10n.gymDetailHoursLabel(gym!.workHours!),
                              style: const TextStyle(color: AppColors.muted)),
                        ],
                        if ((gym?.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(gym!.description!, style: const TextStyle(color: AppColors.muted)),
                        ],
                        const SizedBox(height: 16),
                        Text(context.l10n.gymDetailTrainersTitle, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        if (_trainers.isEmpty)
                          Text(context.l10n.gymDetailNoTrainers,
                              style: const TextStyle(color: AppColors.muted))
                        else
                          Wrap(
                            spacing: 8,
                            children: _trainers
                                .map((trainer) => _TrainerAvatar(
                                      name: trainer.userName,
                                      photoUrl: trainer.photoUrl,
                                      hourlyRate: trainer.hourlyRate,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => MobileTrainerDetailScreen(trainerId: trainer.id),
                                          ),
                                        );
                                      },
                                      onChat: isTrainer ? null : () => _startChat(trainer),
                                    ))
                                .toList(),
                          ),
                        if (_statusMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
                        ],
                        const SizedBox(height: 16),
                        Text(context.l10n.gymDetailReviewsTitle, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (_reviews.isEmpty)
                          Text(context.l10n.gymDetailNoReviews, style: const TextStyle(color: AppColors.muted))
                        else
                          Column(
                            children: _reviews
                                .map(
                                  (review) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        StarRow(rating: review.rating),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            review.comment ?? 'Trainer review',
                                            style: const TextStyle(color: AppColors.muted),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 18),
                        if (!isTrainer) ...[
                          if (membership != null) ...[
                            Text(
                              'Member until ${AppDateTimeFormat.dateTime(membership.endDateUtc)}',
                              style: const TextStyle(color: AppColors.accentDeep),
                            ),
                            const SizedBox(height: 8),
                            AccentButton(label: 'Show QR pass', onPressed: _showQrPass, width: double.infinity),
                          ] else if (requestStatus == 'rejected') ...[
                            Text(
                              request?.rejectionReason?.isNotEmpty == true
                                  ? request!.rejectionReason!
                                  : 'Membership request was rejected.',
                              style: const TextStyle(color: AppColors.red),
                            ),
                            const SizedBox(height: 8),
                            AccentButton(
                              label: _requesting ? 'Requesting...' : 'Request membership',
                              onPressed: _requesting ? null : _requestMembership,
                              width: double.infinity,
                            ),
                          ] else if (requestStatus == 'pending') ...[
                            Text(context.l10n.gymDetailWaitingApproval,
                                style: const TextStyle(color: AppColors.accentDeep)),
                            const SizedBox(height: 8),
                            AccentButton(label: 'Request membership', onPressed: null, width: double.infinity),
                            ] else if (requestStatus == 'approved' && paymentStatus == 'unpaid') ...[
                              Text(context.l10n.gymDetailApprovedPaymentRequired,
                                  style: const TextStyle(color: AppColors.accentDeep)),
                              const SizedBox(height: 8),
                              AccentButton(
                                label: _paying ? 'Processing...' : 'Pay membership',
                                onPressed: _paying ? null : _payMembershipRequest,
                                width: double.infinity,
                              ),
                              if (_membershipCheckoutPending) ...[
                                const SizedBox(height: 8),
                                Text(context.l10n.paymentPendingConfirmation,
                                    style: const TextStyle(color: AppColors.accentDeep)),
                              ],
                            ] else ...[
                            AccentButton(
                              label: _requesting ? 'Requesting...' : 'Request membership',
                              onPressed: _requesting ? null : _requestMembership,
                              width: double.infinity,
                            ),
                          ],
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const MobileActiveMembershipScreen())),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentDeep,
                              side: const BorderSide(color: AppColors.accentDeep),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(context.l10n.gymDetailViewMemberships),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const MobileBookingScreen())),
                            child: Text(context.l10n.gymDetailBookTrainer,
                                style: const TextStyle(color: AppColors.accentDeep)),
                          ),
                          const SizedBox(height: 4),
                        ],
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const MobileGymListScreen())),
                          child: Text(context.l10n.gymDetailSwitchGym,
                              style: const TextStyle(color: AppColors.accentDeep)),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _TrainerAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double? hourlyRate;
  final VoidCallback? onTap;
  final VoidCallback? onChat;

  const _TrainerAvatar({required this.name, this.photoUrl, this.hourlyRate, this.onTap, this.onChat});

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.slate,
              child: url == null || url.isEmpty
                  ? const Icon(Icons.person, color: AppColors.muted)
                  : ClipOval(
                      child: Image.network(
                        url,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.muted),
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            if (hourlyRate != null)
              Text(
                '${hourlyRate!.toStringAsFixed(0)} KM/hr',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            if (onChat != null)
              TextButton(
                onPressed: onChat,
                child: Text(context.l10n.gymDetailChat,
                    style: const TextStyle(color: AppColors.accentDeep, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _GymPhotoCarousel extends StatefulWidget {
  final List<String> photos;
  final ValueChanged<int> onIndexChanged;

  const _GymPhotoCarousel({required this.photos, required this.onIndexChanged});

  @override
  State<_GymPhotoCarousel> createState() => _GymPhotoCarouselState();
}

class _GymPhotoCarouselState extends State<_GymPhotoCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _controller,
          itemCount: photos.isEmpty ? 1 : photos.length,
          onPageChanged: widget.onIndexChanged,
          itemBuilder: (context, index) {
            if (photos.isEmpty) {
              return Container(
                color: AppColors.slate,
                child: const Center(child: Icon(Icons.fitness_center, size: 48, color: AppColors.muted)),
              );
            }
            final url = photos[index];
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.slate,
                child: const Center(child: Icon(Icons.fitness_center, size: 48, color: AppColors.muted)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhotoDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PhotoDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: isActive ? 10 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentDeep : AppColors.slate,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

List<String> _photoUrlsFor(Gym? gym) {
  if (gym == null) {
    return [];
  }
  final urls = <String>[];
  if (gym.photoUrls.isNotEmpty) {
    urls.addAll(gym.photoUrls);
  }
  if (gym.photoUrl != null && gym.photoUrl!.isNotEmpty && !urls.contains(gym.photoUrl)) {
    urls.add(gym.photoUrl!);
  }
  return urls;
}
