class SpeechRecognitionService {
  static bool startListening({
    String lang = 'en-IN',
    void Function(String text)? onResult,
    void Function(String text)? onEnd,
  }) => false;

  static String stopListening() => '';
  static String getTranscript() => '';
  static bool get isSupported => false;
}
