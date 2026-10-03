import 'dart:js_interop';

@JS('startCivicSpeech')
external bool _startCivicSpeech([JSString? lang]);

@JS('stopCivicSpeech')
external JSString _stopCivicSpeech();

@JS('civicSpeechTranscript')
external JSString? get _civicSpeechTranscript;

class SpeechRecognitionService {
  static bool startListening({
    String lang = 'en-IN',
    void Function(String text)? onResult,
    void Function(String text)? onEnd,
  }) {
    try {
      return _startCivicSpeech(lang.toJS);
    } catch (e) {
      return false;
    }
  }

  static String stopListening() {
    try {
      final jsStr = _stopCivicSpeech();
      return jsStr.toDart;
    } catch (e) {
      return '';
    }
  }

  static String getTranscript() {
    try {
      return _civicSpeechTranscript?.toDart ?? '';
    } catch (e) {
      return '';
    }
  }

  static bool get isSupported => true;
}
