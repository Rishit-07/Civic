import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/app_preferences.dart';
import 'package:civic/features/tabs/ask/ask_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'selected_language': 'en',
      'selected_state': 'DL',
      'first_launch_complete': true,
    });
    await AppPreferences.init();
  });

  testWidgets('AskScreen renders complete Neo-Constructivist AI legal interface', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AskScreen(),
      ),
    );
    await tester.pump();

    // Verify Emergency SOS top bar
    expect(find.text('EMERGENCY SOS'), findsOneWidget);
    expect(find.text('call 112'), findsOneWidget);
    expect(find.text('gavel 15100'), findsOneWidget);

    // Verify Header Bar
    expect(find.text('CIVIC'), findsOneWidget);
    expect(find.text('Ask'), findsOneWidget);

    // Verify Editorial Header & Intro Card
    expect(find.text('ASK'), findsOneWidget);
    expect(find.text('PLAIN-LANGUAGE HELP, FROM REVIEWED SOURCES'), findsOneWidget);
    expect(find.text('Statutory Verification Active'), findsOneWidget);
    expect(
      find.text('Ask in plain words about traffic stops, workplace disputes, police checks, or consumer rights.'),
      findsOneWidget,
    );

    // Verify Suggested Prompts Carousel
    expect(find.text('SUGGESTED PROMPTS'), findsOneWidget);
    expect(find.text('I was stopped by police'), findsOneWidget);
    expect(find.text('I\'m being ragged'), findsOneWidget);
    expect(find.text('Hotel refused us a room'), findsOneWidget);
    expect(find.text('I lost money on UPI'), findsOneWidget);

    // Verify Conversation Feed
    expect(find.text('A traffic cop took my phone and is reading my WhatsApp chats. Is this legal?'), findsOneWidget);
    expect(find.text('EMERGENCY SAFEGUARD'), findsOneWidget);
    expect(find.text('CALL 112'), findsOneWidget);
    expect(find.text('SHARE GPS'), findsOneWidget);

    // Verify AI Verdict Bubble
    expect(find.text('CIVIC STATUTORY AI'), findsOneWidget);
    expect(find.text('Statutory Verdict: Strictly Unlawful'), findsOneWidget);
    expect(find.text('OPEN FULL GUIDE'), findsOneWidget);
    expect(find.text('COPY ADVICE'), findsOneWidget);

    // Verify Clarifying Triage Options
    expect(find.text('CONTEXT CLARIFICATION'), findsOneWidget);
    expect(find.text('🚗 Stopped in personal car'), findsOneWidget);
    expect(find.text('🛵 Riding two-wheeler'), findsOneWidget);

    // Verify Floating Bottom Input
    expect(find.text('⚖️ Legal information, not legal advice. Chats aren\'t saved.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
  });

  testWidgets('Submitting a question generates statutory AI response', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AskScreen(),
      ),
    );
    await tester.pump();

    // Type a legal question into the chat input
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Hotel refused us a room');
    await tester.pump();

    // Tap Send
    final sendButton = find.byIcon(Icons.arrow_upward_rounded);
    await tester.tap(sendButton);
    await tester.pump();

    // Verify loading indicator is displayed while AI deliberates
    expect(find.text('Consulting BNSS & Constitutional Statutes...'), findsOneWidget);

    // Wait for AI response to resolve
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify AI response for hotel refusal is added
    expect(find.text('Hotel Accommodation & Privacy Rights of Consenting Adults'), findsOneWidget);
    expect(find.text('Statutory Verdict: Unlawful Moral Policing'), findsOneWidget);
  });
}
