import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/fitcity_models.dart';
import '../screens/desktop/desktop_admin_login_screen.dart';
import '../screens/desktop/desktop_shell_screen.dart';
import '../screens/mobile/mobile_auth_screen.dart';
import '../screens/mobile/mobile_gym_list_screen.dart';
import '../screens/mobile/mobile_schedule_screen.dart';
import '../services/fitcity_api.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';

enum AuthAppKind { mobile, desktop }

class AuthBootstrap extends StatefulWidget {
  final AuthAppKind kind;
  final String? forcedRole;

  const AuthBootstrap({super.key, required this.kind, this.forcedRole});

  @override
  State<AuthBootstrap> createState() => _AuthBootstrapState();
}

class _AuthBootstrapState extends State<AuthBootstrap> {
  bool _ready = false;
  late final VoidCallback _sessionListener;

  @override
  void initState() {
    super.initState();
    _sessionListener = () {
      final userId = FitCityApi.instance.session.value?.user.id;
      LocaleController.instance.applyForUser(userId);
    };
    FitCityApi.instance.session.addListener(_sessionListener);
    _init();
  }

  @override
  void dispose() {
    FitCityApi.instance.session.removeListener(_sessionListener);
    super.dispose();
  }

  Future<void> _init() async {
    if (kDebugMode) {
      debugPrint('[AuthBootstrap] Initializing auth state...');
    }
    await FitCityApi.instance.init();
    await LocaleController.instance.applyForUser(FitCityApi.instance.session.value?.user.id);
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const _AuthLoadingScreen();
    }
    switch (widget.kind) {
      case AuthAppKind.desktop:
        return DesktopAuthGate(forcedRole: widget.forcedRole);
      case AuthAppKind.mobile:
      default:
        return const MobileAuthGate();
    }
  }
}

class AuthGate extends StatelessWidget {
  final FitCityApi api;
  final Widget unauthenticated;
  final Widget Function(AuthSession session) authenticatedBuilder;
  final bool Function(AuthSession session)? allowSession;
  final String debugLabel;

  const AuthGate({
    super.key,
    required this.api,
    required this.unauthenticated,
    required this.authenticatedBuilder,
    this.allowSession,
    this.debugLabel = 'AuthGate',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthSession?>(
      valueListenable: api.session,
      builder: (context, session, _) {
        if (session == null) {
          if (kDebugMode) {
            debugPrint('[$debugLabel] No session -> show login');
          }
          return unauthenticated;
        }
        if (allowSession != null && !allowSession!(session)) {
          if (kDebugMode) {
            debugPrint('[$debugLabel] Session role not allowed (${session.user.role}) -> clearing');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (api.session.value == session) {
              api.session.value = null;
            }
          });
          return unauthenticated;
        }
        if (kDebugMode) {
          debugPrint('[$debugLabel] Authenticated as ${session.user.role} -> show app');
        }
        return authenticatedBuilder(session);
      },
    );
  }
}

class MobileAuthGate extends StatelessWidget {
  const MobileAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      api: FitCityApi.instance,
      unauthenticated: const MobileAuthScreen(),
      allowSession: (session) => session.user.role == 'User' || session.user.role == 'Trainer',
      authenticatedBuilder: (session) {
        if (session.user.role == 'Trainer') {
          return const MobileScheduleScreen();
        }
        return const MobileGymListScreen();
      },
      debugLabel: 'MobileAuthGate',
    );
  }
}

class DesktopAuthGate extends StatelessWidget {
  final String? forcedRole;

  const DesktopAuthGate({super.key, this.forcedRole});

  bool _isAdminRole(String? role) {
    return role == 'CentralAdministrator' || role == 'GymAdministrator';
  }

  bool _matchesForcedRole(String? role) {
    if (forcedRole == null) {
      return _isAdminRole(role);
    }
    return role == forcedRole;
  }

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      api: FitCityApi.instance,
      unauthenticated: DesktopAdminLoginScreen(forcedRole: forcedRole),
      allowSession: (session) => _matchesForcedRole(session.user.role),
      authenticatedBuilder: (_) => DesktopShellScreen(forcedRole: forcedRole),
      debugLabel: 'DesktopAuthGate',
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
