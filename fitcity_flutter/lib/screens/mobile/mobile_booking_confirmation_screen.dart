import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_bookings_screen.dart';
import 'mobile_chat_screen.dart';

class MobileBookingConfirmationScreen extends StatefulWidget {
  final Booking booking;
  final String? trainerName;
  final String? gymName;

  const MobileBookingConfirmationScreen({
    super.key,
    required this.booking,
    this.trainerName,
    this.gymName,
  });

  @override
  State<MobileBookingConfirmationScreen> createState() => _MobileBookingConfirmationScreenState();
}

class _MobileBookingConfirmationScreenState extends State<MobileBookingConfirmationScreen> {
  final FitCityApi _api = FitCityApi.instance;
  String? _statusMessage;

  Future<void> _startChat() async {
    try {
      final trainer = await _api.trainerById(widget.booking.trainerId);
      final existing = await _findExistingConversation(trainer.userId);
      final created = existing ??
          await _api.createConversation(
            otherUserId: trainer.userId,
            title: 'Chat with ${trainer.userName}',
          );
      if (!mounted) {
        return;
      }
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
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MobileChatDetailScreen(conversation: conversation)),
      );
    } catch (error) {
      setState(() => _statusMessage = error.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Booking confirmed'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.bookings),
      body: RoleGate(
        allowedRoles: const {'User'},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking confirmed', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleBadge(color: AppColors.green, label: widget.booking.status),
                      const SizedBox(height: 8),
                      _Row(label: 'Trainer', value: widget.trainerName ?? widget.booking.trainerId),
                      _Row(label: 'Gym', value: widget.gymName ?? widget.booking.gymId ?? '-'),
                      _Row(label: 'Start', value: widget.booking.startUtc.toLocal().toString()),
                      _Row(label: 'End', value: widget.booking.endUtc.toLocal().toString()),
                      _Row(label: 'Payment', value: widget.booking.paymentMethod),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AccentButton(
                  label: 'View upcoming bookings',
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MobileBookingsScreen()),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _startChat,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentDeep,
                    side: const BorderSide(color: AppColors.accentDeep),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chat with trainer'),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
