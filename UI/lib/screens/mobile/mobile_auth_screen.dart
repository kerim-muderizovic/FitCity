import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mobile_app_bar.dart';

class MobileAuthScreen extends StatefulWidget {
  const MobileAuthScreen({super.key});

  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final _emailController = TextEditingController(text: 'user1@gym.local');
  final _passwordController = TextEditingController(text: 'user1pass');
  final _nameController = TextEditingController(text: 'Demo User');
  final _phoneController = TextEditingController(text: '060-000-000');
  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  FitCityApi get _api => FitCityApi.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (kDebugMode) {
      debugPrint('[MobileAuth] Submit ${_isRegister ? 'register' : 'login'}');
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isRegister) {
        await _api.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
      } else {
        await _api.loginMobile(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (kDebugMode) {
        debugPrint('[MobileAuth] Auth success, role=${_api.session.value?.user.role}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authenticated successfully.')),
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[MobileAuth] Auth failed: $error');
      }
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: 'FitCity Access'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FitCity Access', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Login'),
                    selected: !_isRegister,
                    onSelected: (_) => setState(() => _isRegister = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Register'),
                    selected: _isRegister,
                    onSelected: (_) => setState(() => _isRegister = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InputField(label: 'Email', controller: _emailController),
              const SizedBox(height: 12),
              _InputField(label: 'Password', controller: _passwordController, obscureText: true),
              if (_isRegister) ...[
                const SizedBox(height: 12),
                _InputField(label: 'Full name', controller: _nameController),
                const SizedBox(height: 12),
                _InputField(label: 'Phone number', controller: _phoneController),
              ],
              const SizedBox(height: 16),
              AccentButton(
                label: _loading ? 'Please wait...' : (_isRegister ? 'Create account' : 'Login'),
                onPressed: _loading ? null : _submit,
                width: double.infinity,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.red)),
              ],
              const SizedBox(height: 18),
              ValueListenableBuilder(
                valueListenable: _api.session,
                builder: (context, session, _) {
                  if (session == null) {
                    return const Text('Not authenticated yet.');
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current user', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(session.user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(session.user.email, style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 6),
                        Text('Role: ${session.user.role}', style: const TextStyle(color: AppColors.accentDeep)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const _InputField({required this.label, required this.controller, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
