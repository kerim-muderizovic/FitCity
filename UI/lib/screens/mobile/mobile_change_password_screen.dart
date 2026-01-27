import 'package:flutter/material.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';

class MobileChangePasswordScreen extends StatefulWidget {
  const MobileChangePasswordScreen({super.key});

  @override
  State<MobileChangePasswordScreen> createState() => _MobileChangePasswordScreenState();
}

class _MobileChangePasswordScreenState extends State<MobileChangePasswordScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentPassword = _currentController.text.trim();
    final newPassword = _newController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'All fields are required.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) {
        return;
      }
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'Change password'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update password', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: AppColors.red)),
              const SizedBox(height: 12),
              AccentButton(
                label: _saving ? 'Saving...' : 'Save changes',
                onPressed: _saving ? null : _submit,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
