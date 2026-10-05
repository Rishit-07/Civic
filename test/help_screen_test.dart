import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/app_preferences.dart';
import 'package:civic/features/tabs/help/help_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'selected_language': 'en',
      'selected_state': 'DL',
      'first_launch_complete': true,
    });
    await AppPreferences.init();
  });

  testWidgets('HelpScreen renders all sections, helplines, cards, and sign out button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: HelpScreen(),
      ),
    );
    await tester.pump();

    // Verify Emergency SOS top bar
    expect(find.text('EMERGENCY SOS'), findsOneWidget);
    expect(find.text('112'), findsWidgets);
    expect(find.text('15100'), findsWidgets);

    // Verify Header and Hero
    expect(find.text('CIVIC'), findsWidgets);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('HELP'), findsOneWidget);
    expect(find.text('WHO TO CALL, WHAT TO DO NEXT'), findsOneWidget);

    // Verify Verified Helplines
    expect(find.text('VERIFIED HELPLINES'), findsOneWidget);
    expect(find.text('Emergency Police & Medical'), findsOneWidget);
    expect(find.text('National Free Legal Aid (NALSA)'), findsOneWidget);
    expect(find.text('Childline Protection'), findsOneWidget);
    expect(find.text('National Women Helpline'), findsOneWidget);
    expect(find.text('Cyber Crime Helpline'), findsOneWidget);
    expect(find.text('Anti-Ragging Helpline'), findsOneWidget);

    // Verify After an Incident Section (2x2 Grid)
    expect(find.text('AFTER AN INCIDENT'), findsOneWidget);
    expect(find.text('Explain my challan'), findsOneWidget);
    expect(find.text('Draft complaint letter'), findsOneWidget);
    expect(find.text('Find legal aid near me'), findsOneWidget);
    expect(find.text('Ask a question'), findsOneWidget);

    // Verify Geo-Directory Section
    expect(find.text('GEO-DIRECTORY'), findsOneWidget);
    expect(find.text('Legal Aid Offices & Portals'), findsOneWidget);

    // Verify Settings & App Info Section
    expect(find.text('SETTINGS & APP INFO'), findsOneWidget);
    expect(find.text('Settings & Offline Storage'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Privacy & On-Device Security'), findsOneWidget);
    expect(find.text('Report an Error or Statutory Update'), findsOneWidget);
    expect(find.text('About CIVIC'), findsOneWidget);

    // Verify Sign Out button
    expect(find.text('Sign Out of CIVIC'), findsOneWidget);
    expect(find.text('Return to Login / Onboarding screen'), findsOneWidget);

    // Verify Footer
    expect(find.text('WORKS 100% OFFLINE • NO THIRD-PARTY TRACKING'), findsOneWidget);
  });

  testWidgets('Tapping Sign Out of CIVIC displays confirmation dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: HelpScreen(),
      ),
    );
    await tester.pump();

    // Scroll to Sign Out button
    final signOutFinder = find.text('Sign Out of CIVIC');
    await tester.scrollUntilVisible(
      signOutFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    // Tap Sign Out
    await tester.tap(signOutFinder);
    await tester.pump();

    // Verify confirmation dialog shows
    expect(find.text('Sign Out of CIVIC?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
