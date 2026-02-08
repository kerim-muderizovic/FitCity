import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common.dart';
import '../../widgets/language_selector.dart';

class DesktopAdminLoginScreen extends StatefulWidget {
  final String? forcedRole;

  const DesktopAdminLoginScreen({super.key, this.forcedRole});

  @override
  State<DesktopAdminLoginScreen> createState() => _DesktopAdminLoginScreenState();
}

class _DesktopAdminLoginScreenState extends State<DesktopAdminLoginScreen> {
  final FitCityApi _api = FitCityApi.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitting = false;
  bool _submitAttempted = false;
  bool _canSubmit = false;
  String? _error;

  bool get _requireCentral => widget.forcedRole == 'CentralAdministrator';
  bool get _requireGym => widget.forcedRole == 'GymAdministrator';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refreshCanSubmit);
    _passwordController.addListener(_refreshCanSubmit);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _refreshCanSubmit() {
    final valid = _validateEmail(_emailController.text) == null && _validatePassword(_passwordController.text) == null;
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
    return null;
  }

  String? _maybeError(String? error, String value) {
    if (_submitAttempted || value.isNotEmpty) {
      return error;
    }
    return null;
  }

  bool _isAdminRole(String? role) {
    return role == 'CentralAdministrator' || role == 'GymAdministrator';
  }

  bool _matchesForcedRole(String? role) {
    if (widget.forcedRole == null) {
      return _isAdminRole(role);
    }
    return role == widget.forcedRole;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() => _submitAttempted = true);
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (kDebugMode) {
      debugPrint('[DesktopAuth] Submit login (${_requireCentral ? 'central' : _requireGym ? 'gym' : 'admin'})');
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_requireCentral) {
        await _api.loginCentralAdmin(email: email, password: password);
      } else if (_requireGym) {
        await _api.loginGymAdmin(email: email, password: password);
      } else {
        await _api.loginAdmin(email: email, password: password);
      }
      final role = _api.session.value?.user.role;
      if (kDebugMode) {
        debugPrint('[DesktopAuth] Auth success, role=$role');
      }
      if (!_matchesForcedRole(role)) {
        _api.session.value = null;
        setState(() => _error = context.l10n.adminAccessRequired);
        return;
      }
    } on FitCityApiException catch (error) {
      if (kDebugMode) {
        debugPrint('[DesktopAuth] Auth failed: $error');
      }
      setState(() => _error = mapApiError(context, error));
    } catch (_) {
      setState(() => _error = context.l10n.authLoginFailed);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = _requireCentral
        ? context.l10n.adminRoleCentral
        : _requireGym
            ? context.l10n.adminRoleGym
            : context.l10n.adminRoleAdministrator;
    return Scaffold(
      body: Container(
        color: AppColors.paper,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.adminLoginTitle, style: Theme.of(context).textTheme.titleMedium),
                      const LanguageSelector(compact: true),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.adminLoginSubtitle(roleLabel),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: context.l10n.authEmailLabel,
                      errorText: _maybeError(_validateEmail(_emailController.text), _emailController.text),
                      filled: true,
                      fillColor: AppColors.slate,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.authPasswordLabel,
                      errorText: _maybeError(_validatePassword(_passwordController.text), _passwordController.text),
                      filled: true,
                      fillColor: AppColors.slate,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: AppColors.red)),
                  ],
                  const SizedBox(height: 16),
                  AccentButton(
                    label: _submitting ? context.l10n.adminSigningIn : context.l10n.commonSignIn,
                    onPressed: _submitting || !_canSubmit ? null : _submit,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
