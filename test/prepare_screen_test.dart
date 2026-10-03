import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/prepare_readiness_service.dart';
import 'package:civic/features/tabs/prepare/prepare_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'prepare_completed_lessons': ['lesson_police_stop'],
      'prepare_user_xp': 60,
      'prepare_featured_18_completed': false,
    });
    await PrepareReadinessService.init();
  });

  test('PrepareReadinessService initializes and computes readiness properly', () {
    expect(PrepareReadinessService.isLessonCompleted('lesson_police_stop'), isTrue);
    expect(PrepareReadinessService.isLessonCompleted('lesson_arrest_rights'), isFalse);
    expect(PrepareReadinessService.allLessons.length, greaterThanOrEqualTo(5));
    expect(PrepareReadinessService.dailyDrills.length, greaterThanOrEqualTo(3));

    final initialPct = PrepareReadinessService.getReadinessPercentage();
    expect(initialPct, greaterThan(0.0));
  });

  test('Marking lesson completed updates readiness and awards XP', () async {
    final prevXp = PrepareReadinessService.xpNotifier.value;
    await PrepareReadinessService.markLessonCompleted('lesson_arrest_rights');

    expect(PrepareReadinessService.isLessonCompleted('lesson_arrest_rights'), isTrue);
    expect(PrepareReadinessService.xpNotifier.value, equals(prevXp + 15));
  });

  test('Marking featured guide completed awards 50 XP and updates readiness', () async {
    final prevXp = PrepareReadinessService.xpNotifier.value;
    await PrepareReadinessService.markFeaturedCompleted();

    expect(PrepareReadinessService.featuredCompletedNotifier.value, isTrue);
    expect(PrepareReadinessService.xpNotifier.value, equals(prevXp + 50));
  });

  testWidgets('PrepareScreen renders without crashing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: PrepareScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PREPARE'), findsOneWidget);
    expect(find.text('Current Readiness'), findsOneWidget);
    expect(find.text('JUST TURNED 18?'), findsOneWidget);
    expect(find.text('DAILY LEGAL DRILL'), findsOneWidget);
  });
}
