import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/app_preferences.dart';
import 'package:civic/features/splash_loading/loading_screen.dart';
import 'package:civic/features/onboarding/onboarding_screen.dart';
import 'package:civic/features/auth/sign_in_screen.dart';
import 'package:civic/features/navigation/main_tab_scaffold.dart';
import 'package:civic/features/scenarios/situation_list_screen.dart';
import 'package:civic/features/tabs/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  group('Navigation Flow Domain 1: AppPreferences Service', () {
    test('Default preference values are initialized correctly', () {
      expect(AppPreferences.isFirstLaunchComplete, isFalse);
      expect(AppPreferences.selectedLanguage, equals('en'));
      expect(AppPreferences.selectedState, equals('ALL'));
      expect(AppPreferences.isStateCardDismissed, isFalse);
    });

    test('Updating preferences persists values and updates notifiers', () async {
      await AppPreferences.setFirstLaunchComplete(true);
      expect(AppPreferences.isFirstLaunchComplete, isTrue);

      await AppPreferences.setSelectedLanguage('hi');
      expect(AppPreferences.selectedLanguage, equals('hi'));
      expect(AppPreferences.languageNotifier.value, equals('hi'));

      await AppPreferences.setSelectedState('DL');
      expect(AppPreferences.selectedState, equals('DL'));
      expect(AppPreferences.stateNotifier.value, equals('DL'));

      await AppPreferences.setStateCardDismissed(true);
      expect(AppPreferences.isStateCardDismissed, isTrue);
    });
  });

  group('Navigation Flow Domain 2: Splash (LoadingScreen) Routing', () {
    testWidgets('First-launch user advances from Splash to Landing (OnboardingScreen)',
        (WidgetTester tester) async {
      await AppPreferences.setFirstLaunchComplete(false);

      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingScreen(),
        ),
      );

      // Verify splash screen displays logo and loading indicators
      expect(find.text('CIVIC'), findsOneWidget);
      expect(find.text('INITIALIZING GUIDES...'), findsOneWidget);

      // Fast-forward past the 2-second animation + delay
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Destination must be OnboardingScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(MainTabScaffold), findsNothing);
    });

    testWidgets('Returning user skips Landing and Sign In, going Splash -> Home directly',
        (WidgetTester tester) async {
      await AppPreferences.setFirstLaunchComplete(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingScreen(),
        ),
      );

      // Fast-forward past the 2-second splash duration + delay + transition
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));

      // Destination must be MainTabScaffold (Home)
      expect(find.byType(MainTabScaffold), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(SignInScreen), findsNothing);
    });
  });

  group('Navigation Flow Domain 3: Landing (OnboardingScreen) Features', () {
    testWidgets('Landing screen displays language chip, SKIP link, and emergency link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Verify top-bar brand pill and language switcher
      expect(find.text('CIVIC'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);

      // Verify emergency link is present on slide 1
      expect(find.text('In trouble right now? Get help'), findsOneWidget);

      // Tap Hindi language chip and verify language toggles
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();

      expect(AppPreferences.selectedLanguage, equals('hi'));
      expect(find.text('छोड़ें'), findsOneWidget); // Hindi SKIP
      expect(find.text('जानिए'), findsOneWidget); // Hindi KNOW
    });

    testWidgets('Slide 3 displays GET STARTED button and educational legal disclaimer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Drag to slide 2
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('PREPARE'), findsOneWidget);

      // Drag to slide 3
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('ACT'), findsOneWidget);

      // Verify "GET STARTED" button is present on slide 3
      expect(find.text('GET STARTED'), findsOneWidget);

      // Verify disclaimer line is present under the button
      expect(
        find.text('CIVIC provides legal information, not attorney representation. In emergencies, call 112.'),
        findsOneWidget,
      );
    });

    testWidgets('Emergency link opens SituationListScreen directly with zero sign-in',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      final emergencyLink = find.text('In trouble right now? Get help');
      expect(emergencyLink, findsOneWidget);

      await tester.tap(emergencyLink);
      await tester.pumpAndSettle();

      // Must open SituationListScreen directly without requiring sign-in
      expect(find.byType(SituationListScreen), findsOneWidget);
      expect(find.byType(SignInScreen), findsNothing);
    });
  });

  group('Navigation Flow Domain 4: Sign In Screen & First Launch Completion', () {
    testWidgets('Sign In screen sets first_launch_complete and navigates to Home',
        (WidgetTester tester) async {
      expect(AppPreferences.isFirstLaunchComplete, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      final guestButton = find.text('Continue without account');
      expect(guestButton, findsOneWidget);

      // Ensure button is visible before tapping
      await tester.ensureVisible(guestButton);
      await tester.pumpAndSettle();

      // Tap guest entry
      await tester.tap(guestButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Must complete first launch and arrive on MainTabScaffold
      expect(AppPreferences.isFirstLaunchComplete, isTrue);
      expect(find.byType(MainTabScaffold), findsOneWidget);
    });
  });

  group('Navigation Flow Domain 5: Home Screen Jurisdiction State Picker', () {
    testWidgets('Home screen displays state selector chip and allows changing state',
        (WidgetTester tester) async {
      await AppPreferences.setSelectedState('ALL');

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify jurisdiction state chip is shown in header
      expect(find.text('ALL-INDIA'), findsOneWidget);

      // Tap state chip to open bottom sheet
      await tester.tap(find.text('ALL-INDIA'));
      await tester.pumpAndSettle();

      // Bottom sheet is shown with list of states
      expect(find.text('SELECT JURISDICTION'), findsOneWidget);
      expect(find.text('Delhi NCT'), findsOneWidget);

      // Select Delhi NCT
      await tester.tap(find.text('Delhi NCT'));
      await tester.pumpAndSettle();

      // State is updated to DL
      expect(AppPreferences.selectedState, equals('DL'));
      expect(find.text('DL'), findsOneWidget);
    });
  });
}
