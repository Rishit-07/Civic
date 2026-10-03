import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local persistent preferences service for CIVIC.
/// Manages first-launch completion, app language, and jurisdiction state choice.
class AppPreferences {
  static const String _keyFirstLaunchComplete = 'first_launch_complete';
  static const String _keySelectedLanguage = 'selected_language';
  static const String _keySelectedState = 'selected_state';
  static const String _keyStateCardDismissed = 'state_card_dismissed';

  static SharedPreferences? _prefs;

  // Notifiers for reactive UI updates
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');
  static final ValueNotifier<String> stateNotifier = ValueNotifier<String>('ALL');

  /// Initialize SharedPreferences and load cached values into memory.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    languageNotifier.value = selectedLanguage;
    stateNotifier.value = selectedState;
  }

  /// Whether the user has completed onboarding and sign-in.
  static bool get isFirstLaunchComplete {
    return _prefs?.getBool(_keyFirstLaunchComplete) ?? false;
  }

  static Future<void> setFirstLaunchComplete(bool value) async {
    await _prefs?.setBool(_keyFirstLaunchComplete, value);
  }

  /// Active app language ('en' for English, 'hi' for Hindi).
  static String get selectedLanguage {
    return _prefs?.getString(_keySelectedLanguage) ?? 'en';
  }

  static Future<void> setSelectedLanguage(String lang) async {
    await _prefs?.setString(_keySelectedLanguage, lang);
    languageNotifier.value = lang;
  }

  /// Selected legal jurisdiction state (e.g. 'ALL', 'DL', 'MH', 'KA', etc.).
  static String get selectedState {
    return _prefs?.getString(_keySelectedState) ?? 'ALL';
  }

  static Future<void> setSelectedState(String stateCode) async {
    await _prefs?.setString(_keySelectedState, stateCode);
    stateNotifier.value = stateCode;
  }

  /// Whether the "Choose your state" banner on Home has been dismissed.
  static bool get isStateCardDismissed {
    return _prefs?.getBool(_keyStateCardDismissed) ?? false;
  }

  static Future<void> setStateCardDismissed(bool value) async {
    await _prefs?.setBool(_keyStateCardDismissed, value);
  }

  /// Reset all stored preferences (useful for tests or app reset).
  static Future<void> clear() async {
    await _prefs?.clear();
    languageNotifier.value = 'en';
    stateNotifier.value = 'ALL';
  }
}
