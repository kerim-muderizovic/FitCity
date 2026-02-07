import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../l10n/l10n.dart';
import '../../services/chat_socket.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/error_mapper.dart';
import '../../utils/stripe_checkout.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';

class MobileChatScreen extends StatefulWidget {
  const MobileChatScreen({super.key});

  @override
  State<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends State<MobileChatScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final ChatSocketService _socket = ChatSocketService.instance;
  List<Conversation> _conversations = [];
  bool _loading = true;
  String? _error;
  late final void Function(Map<String, dynamic>) _messageHandler;

  @override
  void initState() {
    super.initState();
    _messageHandler = _handleMessage;
    _loadConversations();
    _connectSocket();
  }

  @override
  void dispose() {
    _socket.offMessageNew(_messageHandler);
    super.dispose();
  }

  Future<void> _connectSocket() async {
    await _socket.connect();
    _socket.onMessageNew(_messageHandler);
  }

  void _handleMessage(Map<String, dynamic> payload) {
    final messageJson = payload['message'];
    final conversationId = payload['conversationId']?.toString();
    if (messageJson is! Map || conversationId == null) {
      return;
    }
    final message = Message.fromJson(Map<String, dynamic>.from(messageJson as Map));
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) {
      _loadConversations();
      return;
    }
    final current = _conversations[index];
    final isMe = _api.session.value?.user.id == message.senderUserId;
    final updated = Conversation(
      id: current.id,
      title: current.title,
      createdAtUtc: current.createdAtUtc,
      updatedAtUtc: current.updatedAtUtc,
      lastMessageAtUtc: message.sentAtUtc ?? current.lastMessageAtUtc,
      memberId: current.memberId,
      trainerId: current.trainerId,
      otherUserId: current.otherUserId,
      otherUserName: current.otherUserName,
      otherUserRole: current.otherUserRole,
      lastMessage: message.content,
      unreadCount: isMe ? current.unreadCount : current.unreadCount + 1,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _conversations[index] = updated;
      _conversations.sort(_sortByLastMessage);
    });
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final conversations = await _api.myConversations();
      conversations.sort(_sortByLastMessage);
      setState(() => _conversations = conversations);
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _loading = false);
    }
  }

  int _sortByLastMessage(Conversation a, Conversation b) {
    final aTime = a.lastMessageAtUtc ?? a.updatedAtUtc ?? a.createdAtUtc;
    final bTime = b.lastMessageAtUtc ?? b.updatedAtUtc ?? b.createdAtUtc;
    if (aTime == null && bTime == null) {
      return 0;
    }
    if (aTime == null) {
      return 1;
    }
    if (bTime == null) {
      return -1;
    }
    return bTime.compareTo(aTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.chatTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.chat),
      body: RoleGate(
        allowedRoles: const {'User', 'Trainer'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.red))))
                else if (_conversations.isEmpty)
                  Expanded(
                      child: Center(
                          child: Text(context.l10n.chatNoConversations,
                              style: const TextStyle(color: AppColors.muted))))
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _conversations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final convo = _conversations[index];
                        return _ConversationTile(
                          conversation: convo,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MobileChatDetailScreen(conversation: convo)),
                            );
                            _loadConversations();
                          },
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

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = conversation.otherUserName ?? 'Chat';
    final lastMessage = conversation.lastMessage ?? 'No messages yet.';
    final time = conversation.lastMessageAtUtc ?? conversation.updatedAtUtc ?? conversation.createdAtUtc;
    final timeLabel = time == null ? '' : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: AppColors.slate, child: Icon(Icons.person, color: AppColors.muted)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeLabel, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                if (conversation.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentDeep,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${conversation.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MobileChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const MobileChatDetailScreen({super.key, required this.conversation});

  @override
  State<MobileChatDetailScreen> createState() => _MobileChatDetailScreenState();
}

  class _MobileChatDetailScreenState extends State<MobileChatDetailScreen> {
    final FitCityApi _api = FitCityApi.instance;
    final ChatSocketService _socket = ChatSocketService.instance;
    final TextEditingController _messageController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    List<Message> _messages = [];
    Booking? _latestBooking;
    Booking? _pendingPayment;
    bool _loading = true;
    bool _sending = false;
    bool _paying = false;
    bool _paymentPending = false;
    String? _error;
    String? _paymentError;
    late final void Function(Map<String, dynamic>) _messageHandler;

    @override
    void initState() {
      super.initState();
      _messageHandler = _handleIncomingMessage;
      _loadMessages();
      _loadPendingPayment();
      _setupSocket();
    }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socket.offMessageNew(_messageHandler);
    _socket.leaveConversation(widget.conversation.id);
    super.dispose();
  }

  Future<void> _setupSocket() async {
    await _socket.connect();
    _socket.onMessageNew(_messageHandler);
    await _socket.joinConversation(widget.conversation.id);
  }

  void _handleIncomingMessage(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId']?.toString();
    if (conversationId != widget.conversation.id) {
      return;
    }
    final messageJson = payload['message'];
    if (messageJson is! Map) {
      return;
    }
    final incoming = Message.fromJson(Map<String, dynamic>.from(messageJson as Map));
    if (!mounted) {
      return;
    }
    setState(() {
      _messages.removeWhere((m) => _isPendingMatch(m, incoming));
      _messages.add(incoming);
    });
    _scrollToBottom();
  }

    Future<void> _loadMessages({DateTime? before}) async {
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final messages = await _api.messages(widget.conversation.id, beforeUtc: before, take: 50);
        setState(() {
          if (before == null) {
            _messages = messages;
          } else {
            _messages = [...messages, ..._messages];
          }
        });
        await _api.markConversationRead(widget.conversation.id);
        _scrollToBottom();
      } catch (error) {
        setState(() => _error = mapApiError(context, error));
      } finally {
        setState(() => _loading = false);
      }
    }

    Future<void> _loadPendingPayment() async {
      final session = _api.session.value;
      if (session == null || session.user.role != 'User') {
        setState(() {
          _latestBooking = null;
          _pendingPayment = null;
        });
        return;
      }
      try {
        final bookings = await _api.bookings(status: 'upcoming');
        final trainerUserId = widget.conversation.trainerId;
        final related = bookings.where((b) => b.trainerUserId == trainerUserId).toList();
        related.sort((a, b) => b.startUtc.compareTo(a.startUtc));
        final latest = related.isNotEmpty ? related.first : null;
        final pending = related.firstWhere(
          (b) => (b.paymentMethod.toLowerCase() == 'card' || b.paymentMethod.toLowerCase() == 'paypal')
              && b.paymentStatus.toLowerCase() == 'unpaid',
          orElse: () => Booking(
            id: '',
            userId: '',
            trainerId: '',
            trainerUserId: '',
            trainerName: '',
            startUtc: DateTime.now().toUtc(),
            endUtc: DateTime.now().toUtc(),
            status: '',
            paymentMethod: '',
            paymentStatus: '',
            price: 0,
          ),
        );
        setState(() {
          _latestBooking = latest;
          _pendingPayment = pending.id.isEmpty ? null : pending;
        });
      } catch (error) {
        setState(() => _paymentError = mapApiError(context, error));
      }
    }

    Future<void> _payBooking() async {
      final booking = _pendingPayment;
      if (booking == null || booking.id.isEmpty) {
        return;
      }
      final method = await _selectPaymentMethod();
      if (method == null) {
        return;
      }
      if (method == 'Manual') {
        await _manualPayBooking(booking.id);
        return;
      }
      setState(() {
        _paying = true;
        _paymentError = null;
      });
      try {
        final response = await _api.createBookingCheckout(booking.id);
        final launched = await launchStripeCheckout(
          context,
          response.url,
          invalidUrlMessage: context.l10n.paymentInvalidCheckoutUrl,
          launchFailedMessage: context.l10n.paymentLaunchFailed,
        );
        if (!launched) {
          return;
        }
        if (mounted) {
          setState(() => _paymentPending = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.paymentOpenBrowser)),
          );
        }
        await _pollBookingPayment();
      } catch (error) {
        setState(() => _paymentError = mapApiError(context, error));
      } finally {
        setState(() => _paying = false);
      }
    }

    Future<void> _manualPayBooking(String bookingId) async {
      setState(() {
        _paying = true;
        _paymentError = null;
      });
      try {
        final updated = await _api.manualPayBooking(bookingId);
        setState(() => _pendingPayment = updated.paymentStatus.toLowerCase() == 'paid' ? null : updated);
        await _loadMessages();
        await _loadPendingPayment();
      } catch (error) {
        setState(() => _paymentError = mapApiError(context, error));
      } finally {
        setState(() => _paying = false);
      }
    }

    Future<String?> _selectPaymentMethod() async {
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
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }
    Future<void> _pollBookingPayment() async {
      for (var i = 0; i < 12; i += 1) {
        await Future.delayed(const Duration(seconds: 5));
        if (!mounted) {
          return;
        }
        await _loadPendingPayment();
        if (_pendingPayment == null && _latestBooking != null && _latestBooking!.paymentStatus.toLowerCase() == 'paid') {
          setState(() => _paymentPending = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.paymentConfirmed)),
            );
          }
          return;
        }
      }
      if (mounted) {
        setState(() => _paymentPending = false);
      }
    }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final session = _api.session.value;
    if (session == null) {
      return;
    }
    setState(() {
      _sending = true;
      _messageController.clear();
    });
    final optimistic = Message(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderUserId: session.user.id,
      senderRole: session.user.role,
      content: text,
      sentAtUtc: DateTime.now().toUtc(),
    );
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    try {
      if (_socket.isConnected) {
        await _socket.sendMessage(widget.conversation.id, text);
      } else {
        final sent = await _api.sendMessage(conversationId: widget.conversation.id, content: text);
        setState(() {
          _messages.removeWhere((m) => m.id == optimistic.id);
          _messages.add(sent);
        });
        _scrollToBottom();
      }
    } catch (error) {
      setState(() => _error = mapApiError(context, error));
    } finally {
      setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  bool _isPendingMatch(Message local, Message incoming) {
    if (!local.id.startsWith('local-')) {
      return false;
    }
    if (local.senderUserId != incoming.senderUserId) {
      return false;
    }
    if (local.content != incoming.content) {
      return false;
    }
    final localTime = local.sentAtUtc;
    final incomingTime = incoming.sentAtUtc;
    if (localTime == null || incomingTime == null) {
      return false;
    }
    return incomingTime.difference(localTime).inSeconds.abs() <= 5;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.conversation.otherUserName ?? 'Chat';
    return Scaffold(
      appBar: buildMobileAppBar(context, title: name),
      body: Column(
          children: [
            if (_latestBooking != null) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payment, color: AppColors.accentDeep),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.chatPaymentDetails,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            '${_latestBooking!.trainerName} - ${AppDateTimeFormat.dateTime(_latestBooking!.startUtc)}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                          Text(
                            '${_latestBooking!.price.toStringAsFixed(0)} KM - Payment: ${_latestBooking!.paymentMethod}${_latestBooking!.paymentMethod.toLowerCase() == 'card' && _latestBooking!.paymentStatus.toLowerCase() == 'paid' ? ' (Paid)' : ''}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (_pendingPayment != null)
                      AccentButton(
                        label: _paying ? 'Paying...' : 'Pay',
                        onPressed: _paying ? null : _payBooking,
                        width: 90,
                      ),
                  ],
                ),
              ),
              if (_paymentPending)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(context.l10n.paymentPendingConfirmation,
                      style: const TextStyle(color: AppColors.accentDeep)),
                ),
              if (_paymentError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(_paymentError!, style: const TextStyle(color: AppColors.red)),
                ),
            ],
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.red))))
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = _api.session.value?.user.id == message.senderUserId;
                  return _ChatBubble(
                    text: message.content,
                    isMe: isMe,
                    time: message.sentAtUtc?.toLocal(),
                  );
                },
              ),
            ),
          if (!_loading && _messages.length >= 50)
            TextButton(
              onPressed: () => _loadMessages(before: _messages.first.sentAtUtc),
              child: Text(context.l10n.chatLoadEarlier),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _sending ? AppColors.slate : AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: _sending ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? time;

  const _ChatBubble({required this.text, required this.isMe, this.time});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppColors.accent : Colors.white;
    final textColor = isMe ? Colors.white : AppColors.ink;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final timeLabel = time == null ? '' : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: textColor)),
            if (timeLabel.isNotEmpty)
              Text(timeLabel, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

