import 'package:flutter/material.dart';
import '../../data/fitcity_models.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';

class MobileProfileEditScreen extends StatefulWidget {
  final CurrentUser user;

  const MobileProfileEditScreen({super.key, required this.user});

  @override
  State<MobileProfileEditScreen> createState() => _MobileProfileEditScreenState();
}

class _MobileProfileEditScreenState extends State<MobileProfileEditScreen> {
  final FitCityApi _api = FitCityApi.instance;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _saving = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _statusMessage = context.l10n.profileFullNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _statusMessage = null;
    });
    try {
      final updated = await _api.updateProfile(
        fullName: name,
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );
      final session = _api.session.value;
      if (session != null) {
        _api.session.value = AuthSession(auth: session.auth, user: updated);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(updated);
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.profileEditTitle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: context.l10n.profileFullNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: context.l10n.profileEmailLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: context.l10n.profilePhoneLabel),
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(_statusMessage!, style: const TextStyle(color: AppColors.red)),
            const SizedBox(height: 12),
            AccentButton(
              label: _saving ? context.l10n.commonSaving : context.l10n.commonSaveChanges,
              onPressed: _saving ? null : _save,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
