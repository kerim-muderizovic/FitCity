import 'package:flutter/material.dart';
import '../../services/fitcity_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'desktop_shell_screen.dart';

class DesktopAdminLoginScreen extends StatefulWidget {
  final String? forcedRole;

  const DesktopAdminLoginScreen({super.key, this.forcedRole});

  @override
  State<DesktopAdminLoginScreen> createState() => _DesktopAdminLoginScreenState();
}

class _DesktopAdminLoginScreenState extends State<DesktopAdminLoginScreen> {
  final FitCityApi _api = FitCityApi.instance;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _submitting = false;
  String? _error;

  bool get _requireCentral => widget.forcedRole == 'CentralAdministrator';
  bool get _requireGym => widget.forcedRole == 'GymAdministrator';

  @override
  void initState() {
    super.initState();
    final defaultEmail = _requireCentral ? 'central@fitcity.local' : 'admin.downtown@fitcity.local';
    final defaultPassword = _requireCentral ? 'central' : 'gymadmin1';
    _emailController = TextEditingController(text: defaultEmail);
    _passwordController = TextEditingController(text: defaultPassword);
    _redirectIfAuthenticated();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  void _redirectIfAuthenticated() {
    final session = _api.session.value;
    if (session == null || !_matchesForcedRole(session.user.role)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DesktopShellScreen(forcedRole: widget.forcedRole)),
      );
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter both email and password.');
      return;
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
        await _api.login(email: email, password: password);
      }
      final role = _api.session.value?.user.role;
      if (!_matchesForcedRole(role)) {
        _api.session.value = null;
        setState(() => _error = 'Admin access required for this workspace.');
        return;
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DesktopShellScreen(forcedRole: widget.forcedRole)),
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = _requireCentral
        ? 'Central Administrator'
        : _requireGym
            ? 'Gym Administrator'
            : 'Administrator';
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
                  Text('FitCity Admin', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in with a $roleLabel account to continue.',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                      labelText: 'Password',
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
                    label: _submitting ? 'Signing in...' : 'Sign in',
                    onPressed: _submitting ? null : _submit,
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
