import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
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
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _statusMessage;

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendDemo() {
    setState(() => _statusMessage = context.l10n.emailDemoQueued(_toController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.emailDemoTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.emailDemoTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _toController,
                decoration: InputDecoration(
                  labelText: context.l10n.emailDemoToLabel,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: context.l10n.emailDemoSubjectLabel,
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
                  labelText: context.l10n.emailDemoMessageLabel,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              AccentButton(label: context.l10n.emailDemoSend, onPressed: _sendDemo, width: double.infinity),
              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                Text(_statusMessage!, style: const TextStyle(color: AppColors.accentDeep)),
              ],
              const SizedBox(height: 12),
              Text(
                context.l10n.emailDemoDisclaimer,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
