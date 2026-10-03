import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/core/config/app_config.dart';
import 'package:civic/data/services/app_preferences.dart';
import 'package:civic/data/services/gemini_ai_service.dart';

void main() {


  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  group('GeminiAiService & AppPreferences Integration Tests', () {
    test('generateLegalAnswer returns null safely when no API key is configured', () async {
      await AppPreferences.setGeminiApiKey('');
      expect(AppPreferences.geminiApiKey, isEmpty);

      final result = await GeminiAiService.instance.generateLegalAnswer(
        query: 'What are my rights at a police checkpoint?',
      );

      // Must return null to trigger seamless fallback to on-device legal rules
      expect(result, isNull);
    });

    test('AppPreferences correctly saves and notifies Gemini API key and model', () async {
      expect(AppPreferences.geminiApiKey, equals(AppConfig.geminiApiKey));
      expect(AppPreferences.geminiModel, equals('gemini-3.8-flash'));

      await AppPreferences.setGeminiApiKey('AIzaSyTestKey12345');
      await AppPreferences.setGeminiModel('gemini-3.6-flash');

      expect(AppPreferences.geminiApiKey, equals('AIzaSyTestKey12345'));
      expect(AppPreferences.geminiModel, equals('gemini-3.6-flash'));
      expect(AppPreferences.geminiApiKeyNotifier.value, equals('AIzaSyTestKey12345'));


      await AppPreferences.setGeminiApiKey('');
      expect(AppPreferences.geminiApiKey, isEmpty);
      expect(AppPreferences.geminiApiKeyNotifier.value, isNull);
    });
  });
}
