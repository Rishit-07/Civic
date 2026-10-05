import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/app_preferences.dart';
import 'package:civic/data/repositories/content_repository.dart';
import 'package:civic/features/scenarios/situation_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    await ContentRepository.instance.loadCategories();
  });

  group('SituationListScreen Pagination & Role Perspective Tests', () {
    testWidgets('Renders Category and Role filter chips correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SituationListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and emergency banner
      expect(find.text('Legal Encounters'), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);

      // Check Category Chips
      expect(find.text('All'), findsWidgets);
      expect(find.text('Police'), findsWidgets);
      expect(find.text('Campus'), findsWidgets);

      // Check Role Chips
      expect(find.text('All Roles'), findsWidgets);
      expect(find.text('Victim / Affected'), findsOneWidget);
      expect(find.text('Accused / Suspect'), findsOneWidget);
      expect(find.text('Witness / Bystander'), findsOneWidget);
      expect(find.text('Parent / Guardian'), findsOneWidget);
    });

    testWidgets('Selecting a category displays paginated scenarios and controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SituationListScreen(initialCategoryId: 'police_criminal'),
        ),
      );
      await tester.pumpAndSettle();

      // Police has 14 scenarios -> at 5 per page, there are 3 pages
      expect(find.text('POLICE PROTOCOLS (14)'), findsOneWidget);
      expect(find.text('PAGE 1 OF 3'), findsOneWidget);
      expect(find.text('14 protocols total'), findsOneWidget);
      expect(find.text('PREV'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);

      // Tap NEXT to paginate to page 2
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('PAGE 2 OF 3'), findsOneWidget);
    });

    testWidgets('Filtering by Role updates scenario counts and list',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SituationListScreen(initialCategoryId: 'police_criminal'),
        ),
      );
      await tester.pumpAndSettle();

      // Initial count for All Roles is 14
      expect(find.text('POLICE PROTOCOLS (14)'), findsOneWidget);

      // Tap Accused / Suspect chip
      await tester.tap(find.text('Accused / Suspect'));
      await tester.pumpAndSettle();

      // Should persist in AppPreferences
      expect(AppPreferences.selectedRole, equals('accused'));
      expect(find.textContaining('POLICE PROTOCOLS'), findsOneWidget);
    });

    testWidgets('Tapping role badge opens Citizen Identity & Perspective modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SituationListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the top right role badge
      final guestModeFinder = find.text('Guest Mode');
      expect(guestModeFinder, findsOneWidget);

      await tester.tap(guestModeFinder);
      await tester.pumpAndSettle();

      // Verify bottom sheet modal opened
      expect(find.text('CITIZEN IDENTITY & PERSPECTIVE'), findsOneWidget);
      expect(find.text('GUEST MODE'), findsOneWidget);
      expect(find.text('SELECT YOUR LEGAL ROLE PERSPECTIVE'), findsOneWidget);
      expect(find.text('All Roles (Overview)'), findsOneWidget);
      expect(find.text('Affected Victim / Aggrieved Person'), findsOneWidget);
      expect(find.text('Accused / Suspect / Named Citizen'), findsOneWidget);

      // Select Accused / Suspect from modal
      await tester.tap(find.text('Accused / Suspect / Named Citizen'));
      await tester.pumpAndSettle();

      expect(AppPreferences.selectedRole, equals('accused'));
    });
  });
}
