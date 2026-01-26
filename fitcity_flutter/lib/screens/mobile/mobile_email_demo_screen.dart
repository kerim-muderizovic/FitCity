import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/common.dart';

class MobileEmailDemoScreen extends StatefulWidget {
  const MobileEmailDemoScreen({super.key});

  @override
  State<MobileEmailDemoScreen> createState() => _MobileEmailDemoScreenState();
}

class _MobileEmailDemoScreenState extends State<MobileEmailDemoScreen> {
  final TextEditingController _toController = TextEditingController(text: 'user1@gym.local');
  final TextEditingController _subjectController = TextEditingController(text: 'Welcome to FitCity');
  final TextEditingController _bodyController = TextEditingController(
    text: 'Hi! This is a demo email. The real service sends via FitCity.Notifications.Api.',
  );
  String? _statusMessage;

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendDemo() {
    setState(() => _statusMessage = 'Queued demo email to ${_toController.text}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Email Demo'),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email Demo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _toController,
                decoration: InputDecoration(
                  labelText: 'To',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              AccentButton(label: 'Send demo email', onPressed: _sendDemo, width: double.infinity),
              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
              ],
              const SizedBox(height: 12),
              const Text(
                'This screen is a mock. Real emails are sent by FitCity.Notifications.Api via RabbitMQ.',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
