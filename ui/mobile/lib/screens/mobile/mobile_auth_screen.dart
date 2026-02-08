import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../screens/mobile/mobile_gym_list_screen.dart';
import '../../screens/mobile/mobile_schedule_screen.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/mobile_app_bar.dart';

class MobileAuthScreen extends StatefulWidget {
  final bool managedByAuthGate;

  const MobileAuthScreen({
    super.key,
    this.managedByAuthGate = false,
  });

  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _submitAttempted = false;
  bool _canSubmit = false;
  String? _error;

  FitCityApi get _api => FitCityApi.instance;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refreshCanSubmit);
    _passwordController.addListener(_refreshCanSubmit);
    _confirmController.addListener(_refreshCanSubmit);
    _nameController.addListener(_refreshCanSubmit);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _refreshCanSubmit() {
    final valid = _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        (!_isRegister || _validateConfirm(_confirmController.text) == null) &&
        (!_isRegister || _validateName(_nameController.text) == null);
    if (valid != _canSubmit && mounted) {
      setState(() => _canSubmit = valid);
    }
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return context.l10n.authEmailRequired;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return context.l10n.authEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return context.l10n.authPasswordRequired;
    }
    if (value.length < 8) {
      return context.l10n.authPasswordTooShort;
    }
    return null;
  }

  String? _validateConfirm(String value) {
    if (!_isRegister) {
      return null;
    }
    if (value.isEmpty) {
      return context.l10n.authConfirmPasswordRequired;
    }
    if (value != _passwordController.text) {
      return context.l10n.authPasswordMismatch;
    }
    return null;
  }

  String? _validateName(String value) {
    if (!_isRegister) {
      return null;
    }
    if (value.trim().isEmpty) {
      return context.l10n.authFullNameRequired;
    }
    return null;
  }

  String? _maybeError(String? error, String value) {
    if (_submitAttempted || value.isNotEmpty) {
      return error;
    }
    return null;
  }

  void _redirectAfterSuccess() {
    if (!mounted || widget.managedByAuthGate) {
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
      return;
    }

    final role = _api.session.value?.user.role;
    final destination = role == 'Trainer' ? const MobileScheduleScreen() : const MobileGymListScreen();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() => _submitAttempted = true);
      return;
    }
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
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
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
          SnackBar(content: Text(context.l10n.authSuccessSnackbar)),
        );
        _redirectAfterSuccess();
      }
    } on FitCityApiException catch (error) {
      if (kDebugMode) {
        debugPrint('[MobileAuth] Auth failed: $error');
      }
      setState(() => _error = mapApiError(context, error));
    } catch (_) {
      setState(() => _error = context.l10n.authAuthenticationFailed);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.authAccessTitle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.authAccessTitle, style: Theme.of(context).textTheme.titleMedium),
                  const LanguageSelector(compact: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: Text(context.l10n.authLogin),
                    selected: !_isRegister,
                    onSelected: (_) {
                      setState(() => _isRegister = false);
                      _refreshCanSubmit();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(context.l10n.authRegister),
                    selected: _isRegister,
                    onSelected: (_) {
                      setState(() => _isRegister = true);
                      _refreshCanSubmit();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InputField(
                label: context.l10n.authEmailLabel,
                controller: _emailController,
                errorText: _maybeError(_validateEmail(_emailController.text), _emailController.text),
              ),
              const SizedBox(height: 12),
              _InputField(
                label: context.l10n.authPasswordLabel,
                controller: _passwordController,
                obscureText: true,
                errorText: _maybeError(_validatePassword(_passwordController.text), _passwordController.text),
              ),
              if (_isRegister) ...[
                const SizedBox(height: 12),
                _InputField(
                  label: context.l10n.authConfirmPasswordLabel,
                  controller: _confirmController,
                  obscureText: true,
                  errorText: _maybeError(_validateConfirm(_confirmController.text), _confirmController.text),
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: context.l10n.authFullNameLabel,
                  controller: _nameController,
                  errorText: _maybeError(_validateName(_nameController.text), _nameController.text),
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: context.l10n.authPhoneOptionalLabel,
                  controller: _phoneController,
                ),
              ],
              const SizedBox(height: 16),
              AccentButton(
                label: _loading
                    ? context.l10n.authPleaseWait
                    : (_isRegister ? context.l10n.authCreateAccount : context.l10n.authLogin),
                onPressed: _loading || !_canSubmit ? null : _submit,
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
                    return Text(context.l10n.authNotAuthenticatedYet);
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
                        Text(context.l10n.authCurrentUser, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(session.user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(session.user.email, style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 6),
                        Text(context.l10n.commonRoleLabel(session.user.role),
                            style: const TextStyle(color: AppColors.accentDeep)),
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
  final String? errorText;

  const _InputField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
