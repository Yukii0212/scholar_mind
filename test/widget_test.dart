import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/auth/providers/auth_provider.dart';
import 'package:scholar_mind/features/auth/screens/login_screen.dart';

class FakeAuthController extends AuthController {
  @override
  FutureOr<void> build() {}
}

void main() {
  testWidgets('login screen offers Google sign-in', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('ScholarMind'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
