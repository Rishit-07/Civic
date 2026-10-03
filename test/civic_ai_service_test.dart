import 'package:flutter_test/flutter_test.dart';
import 'package:civic/data/services/civic_ai_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    await AppPreferences.setGeminiApiKey('');
  });

  group('CivicAiService Comprehensive Legal Question Answering Tests', () {
    final aiService = CivicAiService.instance;


    test('Answers question about police taking vehicle keys', () async {
      final response = await aiService.analyzeQuery(
        query: 'Can traffic police take my car keys from the ignition?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Strictly Unlawful'));
      expect(verdict.directAnswer.toLowerCase(), contains('no'));
      expect(verdict.directAnswer.toLowerCase(), contains('snatch or remove keys'));
      expect(verdict.statutoryCitation, contains('Motor Vehicles Act'));
      expect(verdict.statutoryCitation, contains('Sec 126 BNS'));
      expect(verdict.citizenActionSteps.isNotEmpty, isTrue);
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
      expect(response.relatedCardId, equals('traffic_stop_default'));
    });

    test('Answers question about video recording police in public', () async {
      final response = await aiService.analyzeQuery(
        query: 'Can I record video of police officers in public?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Constitutional Right Protected'));
      expect(verdict.directAnswer.toLowerCase(), contains('yes'));
      expect(verdict.statutoryCitation, contains('Article 19(1)(a)'));
      expect(verdict.citizenActionSteps.isNotEmpty, isTrue);
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Answers question about police searching bag on street', () async {
      final response = await aiService.analyzeQuery(
        query: 'Can police search my backpack on the road?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.statutoryCitation, contains('100 CrPC'));
      expect(verdict.statutoryCitation, contains('105 BNSS'));
      expect(verdict.directAnswer, contains('reasonable suspicion'));
      expect(verdict.citizenActionSteps.any((s) => s.contains('Panchas')), isTrue);
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Answers question about home search without warrant', () async {
      final response = await aiService.analyzeQuery(
        query: 'Can police search my house without a warrant?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Unlawful Without Specific Ground'));
      expect(verdict.statutoryCitation, contains('165 CrPC'));
      expect(verdict.directAnswer, contains('CANNOT enter and search'));
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Answers question about arrest of women at night', () async {
      final response = await aiService.analyzeQuery(
        query: 'Can police arrest a woman after sunset?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Night Arrest Strictly Prohibited'));
      expect(verdict.statutoryCitation, contains('Sec 46(4)'));
      expect(verdict.directAnswer, contains('NO woman can be arrested'));
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Answers question about bribery by public servant', () async {
      final response = await aiService.analyzeQuery(
        query: 'What should I do if a police officer demands a bribe?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.statutoryCitation, contains('Prevention of Corruption Act'));
      expect(verdict.citizenActionSteps.any((s) => s.contains('1064')), isTrue);
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Answers question about landlord locking out tenant', () async {
      final response = await aiService.analyzeQuery(
        query: 'Landlord changed locks and cut electricity',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Unlawful Forceful Eviction'));
      expect(verdict.statutoryCitation, contains('Sec 430 IPC'));
      expect(verdict.citizenActionSteps.any((s) => s.contains('112')), isTrue);
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Answers question about cyber blackmail and leaked photos', () async {
      final response = await aiService.analyzeQuery(
        query: 'Someone is blackmailing me with leaked private photos',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.statutoryCitation, contains('Sec 66E'));
      expect(verdict.citizenActionSteps.any((s) => s.contains('1930')), isTrue);
      expect(verdict.citizenActionSteps.any((s) => s.contains('StopNCII')), isTrue);
      expect(verdict.criticalDonts.any((d) => d.contains('DO NOT transfer any extortion money')), isTrue);
    });

    test('Answers question about loan recovery agent harassment', () async {
      final response = await aiService.analyzeQuery(
        query: 'Loan recovery agents calling my contacts and threatening me',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.statutoryCitation, contains('RBI Circular'));
      expect(verdict.directAnswer, contains('CANNOT call you before 8 AM'));
      expect(verdict.citizenActionSteps.any((s) => s.contains('cms.rbi.org.in')), isTrue);
    });

    test('Answers question in Hindi: गाड़ी की चाबी निकाल ली', () async {
      final response = await aiService.analyzeQuery(
        query: 'ट्रैफिक पुलिस ने मेरी गाड़ी की चाबी निकाल ली',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Strictly Unlawful'));
      expect(verdict.directAnswer.toLowerCase(), contains('no'));
    });

    test('Analyzes uploaded traffic challan notice accurately', () async {
      final response = await aiService.analyzeQuery(
        query: '',
        attachmentName: 'e_challan_DL01AB1234.pdf',
        attachmentPath: '/storage/e_challan_DL01AB1234.pdf',
        attachmentType: 'document',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Verify Compounding Authority'));
      expect(verdict.statutoryCitation, contains('Motor Vehicles Act'));
      expect(verdict.citizenActionSteps.isNotEmpty, isTrue);
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
    });

    test('Smart domain-aware fallback provides structured verdict for general questions', () async {
      final response = await aiService.analyzeQuery(
        query: 'What are my fundamental rights if an inspector questions me on the street?',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.directAnswer.isNotEmpty, isTrue);
      expect(verdict.statutoryCitation.isNotEmpty, isTrue);
      expect(verdict.citizenActionSteps.length, greaterThanOrEqualTo(3));
      expect(verdict.criticalDonts.isNotEmpty, isTrue);
      expect(response.triageOptions, isNotNull);
    });

    test('Transcribed voice query with prefix resolves to exact statutory category', () async {
      final response = await aiService.analyzeQuery(
        query: '🎙️ Voice Query: police snatched my car keys from the ignition',
        audioPath: 'blob:http://localhost:8080/audio_123',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Strictly Unlawful'));
      expect(verdict.directAnswer.toLowerCase(), contains('no'));
      expect(verdict.directAnswer.toLowerCase(), contains('snatch or remove keys'));
      expect(verdict.statutoryCitation, contains('Motor Vehicles Act'));
      expect(response.relatedCardId, equals('traffic_stop_default'));
    });

    test('Untranscribed voice recording returns structured situation triage rather than generic text', () async {
      final response = await aiService.analyzeQuery(
        query: '🎙️ Voice Query: Question recorded at 9s duration',
        audioPath: 'blob:http://localhost:8080/audio_456',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Voice Note Recorded'));
      expect(verdict.directAnswer, contains('select the legal issue'));
      expect(response.triageOptions, isNotNull);
      expect(response.triageOptions!.length, greaterThanOrEqualTo(5));
      expect(response.triageOptions!.any((t) => t.contains('keys')), isTrue);
      expect(response.triageOptions!.any((t) => t.contains('phone')), isTrue);
      expect(response.triageOptions!.any((t) => t.contains('FIR')), isTrue);
    });

    test('Tapping triage clarification resolves directly to legal verdict', () async {
      final response = await aiService.analyzeQuery(
        query: 'Clarification: 🚗 Car keys taken by traffic police',
      );

      expect(response.verdict, isNotNull);
      final verdict = response.verdict!;
      expect(verdict.verdictTitle, contains('Strictly Unlawful'));
      expect(verdict.statutoryCitation, contains('Motor Vehicles Act'));
    });
  });
}
