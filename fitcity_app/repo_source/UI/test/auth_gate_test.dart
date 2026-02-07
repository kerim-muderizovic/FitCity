import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcity_flutter/data/fitcity_models.dart';
import 'package:fitcity_flutter/services/fitcity_api.dart';
import 'package:fitcity_flutter/widgets/auth_gate.dart';

void main() {
  setUp(() {
    FitCityApi.instance.session.value = null;
  });

  tearDown(() {
    FitCityApi.instance.session.value = null;
  });

  testWidgets('MobileAuthGate shows login when signed out', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MobileAuthGate()));
    expect(find.text('FitCity Access'), findsWidgets);
  });

  testWidgets('MobileAuthGate shows gym list for User role', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MobileAuthGate()));
    FitCityApi.instance.session.value = _session(role: 'User');
    await tester.pump();
    expect(find.text('Gyms in Sarajevo'), findsOneWidget);
  });

  testWidgets('MobileAuthGate shows schedule for Trainer role', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MobileAuthGate()));
    FitCityApi.instance.session.value = _session(role: 'Trainer');
    await tester.pump();
    expect(find.text('Schedule'), findsWidgets);
  });

  testWidgets('MobileAuthGate clears non-mobile roles', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MobileAuthGate()));
    FitCityApi.instance.session.value = _session(role: 'GymAdministrator');
    await tester.pump();
    await tester.pump();
    expect(FitCityApi.instance.session.value, isNull);
    expect(find.text('FitCity Access'), findsWidgets);
  });
}

AuthSession _session({required String role}) {
  return AuthSession(
    auth: AuthResponse(accessToken: 'token', expiresAtUtc: DateTime.now().toUtc()),
    user: CurrentUser(id: 'u1', email: 'user@fitcity.local', fullName: 'Demo User', role: role),
  );
}
