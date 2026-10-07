import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

/// Centralized local persistent preferences service for CIVIC.
/// Manages first-launch completion, app language, and jurisdiction state choice.
class AppPreferences {
  static const String _keyFirstLaunchComplete = 'first_launch_complete';
  static const String _keySelectedLanguage = 'selected_language';
  static const String _keySelectedState = 'selected_state';
  static const String _keySelectedRole = 'selected_user_role';
  static const String _keyStateCardDismissed = 'state_card_dismissed';

  static SharedPreferences? _prefs;

  // Notifiers for reactive UI updates
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');
  static final ValueNotifier<String> stateNotifier = ValueNotifier<String>('ALL');
  static final ValueNotifier<String> roleNotifier = ValueNotifier<String>('all');

  /// Initialize SharedPreferences and load cached values into memory.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    languageNotifier.value = selectedLanguage;
    stateNotifier.value = selectedState;
    roleNotifier.value = selectedRole;
    geminiApiKeyNotifier.value = geminiApiKey.isEmpty ? null : geminiApiKey;
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

  static const String _keyGeminiApiKey = 'gemini_api_key';
  static const String _keyGeminiModel = 'gemini_model';

  static final ValueNotifier<String?> geminiApiKeyNotifier = ValueNotifier<String?>(null);

  /// Get configured Gemini API key (or build-time environment variable, or local AppConfig).
  static String get geminiApiKey {
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    final stored = _prefs?.getString(_keyGeminiApiKey);
    if (stored != null) return stored.trim();
    return AppConfig.geminiApiKey;
  }

  static Future<void> setGeminiApiKey(String key) async {
    await _prefs?.setString(_keyGeminiApiKey, key.trim());
    geminiApiKeyNotifier.value = key.trim().isEmpty ? null : key.trim();
  }

  /// Active Gemini model name (default: gemini-3.8-flash).
  static String get geminiModel {
    return _prefs?.getString(_keyGeminiModel) ?? 'gemini-3.8-flash';
  }


  static Future<void> setGeminiModel(String model) async {
    await _prefs?.setString(_keyGeminiModel, model.trim());
  }

  /// Whether the "Choose your state" banner on Home has been dismissed.
  static bool get isStateCardDismissed {
    return _prefs?.getBool(_keyStateCardDismissed) ?? false;
  }

  static Future<void> setStateCardDismissed(bool value) async {
    await _prefs?.setBool(_keyStateCardDismissed, value);
  }

  /// Selected legal capacity/role (e.g. 'all', 'affected', 'accused', 'witness', 'parent').
  static String get selectedRole {
    return _prefs?.getString(_keySelectedRole) ?? 'all';
  }

  static Future<void> setSelectedRole(String role) async {
    await _prefs?.setString(_keySelectedRole, role.toLowerCase().trim());
    roleNotifier.value = role.toLowerCase().trim();
  }

  // Citizen Profile Preferences
  static const String _keyProfileFullName = 'profile_full_name';
  static const String _keyProfileHandle = 'profile_handle';
  static const String _keyProfileJurisdiction = 'profile_jurisdiction';
  static const String _keyProfileDistrict = 'profile_district';
  static const String _keyProfileAvatarVariant = 'profile_avatar_variant';
  static const String _keyProfileAvatarUrl = 'profile_avatar_url';
  static const String _keyProfileLanguages = 'profile_languages';
  static const String _keyProfileSosKin = 'profile_sos_kin';
  static const String _keyProfileSosCounsel = 'profile_sos_counsel';
  static const String _keyProfileZeroKnowledgeVault = 'profile_zero_knowledge_vault';
  static const String _keyProfileVaultLocked = 'profile_vault_locked';

  static const String _keyProfileCitizenRegId = 'civic_profile_citizen_reg_id';
  static final ValueNotifier<int> profileRevisionNotifier = ValueNotifier<int>(0);

  static String get profileCitizenRegId {
    return _prefs?.getString(_keyProfileCitizenRegId) ?? '#8841-IN';
  }

  static Future<void> setProfileCitizenRegId(String regId) async {
    await _prefs?.setString(_keyProfileCitizenRegId, regId.trim());
    profileRevisionNotifier.value++;
  }

  static String get profileFullName {
    return _prefs?.getString(_keyProfileFullName) ?? 'Citizen';
  }

  static Future<void> setProfileFullName(String name) async {
    await _prefs?.setString(_keyProfileFullName, name.trim());
    profileRevisionNotifier.value++;
  }

  static String get profileHandle {
    final stored = _prefs?.getString(_keyProfileHandle);
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    final name = profileFullName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    if (name.isNotEmpty && name != 'citizen') return '$name.civic';
    return 'citizen.civic';
  }

  static Future<void> setProfileHandle(String handle) async {
    await _prefs?.setString(_keyProfileHandle, handle.trim());
    profileRevisionNotifier.value++;
  }

  static String get profileJurisdiction {
    return _prefs?.getString(_keyProfileJurisdiction) ?? 'Pan-India (BNS & BNSS 2024 active)';
  }

  static Future<void> setProfileJurisdiction(String jurisdiction) async {
    await _prefs?.setString(_keyProfileJurisdiction, jurisdiction);
    profileRevisionNotifier.value++;
  }

  static String get profileDistrict {
    return _prefs?.getString(_keyProfileDistrict) ?? 'All Districts';
  }

  static Future<void> setProfileDistrict(String district) async {
    await _prefs?.setString(_keyProfileDistrict, district.trim());
    profileRevisionNotifier.value++;
  }

  static String get profileAvatarVariant {
    return _prefs?.getString(_keyProfileAvatarVariant) ?? 'orange';
  }

  static Future<void> setProfileAvatarVariant(String variant) async {
    await _prefs?.setString(_keyProfileAvatarVariant, variant);
    profileRevisionNotifier.value++;
  }

  static String get profileAvatarUrl {
    return _prefs?.getString(_keyProfileAvatarUrl) ?? '';
  }

  static Future<void> setProfileAvatarUrl(String url) async {
    await _prefs?.setString(_keyProfileAvatarUrl, url);
    profileRevisionNotifier.value++;
  }

  static List<String> get profileLanguages {
    return _prefs?.getStringList(_keyProfileLanguages) ?? ['en', 'hi'];
  }

  static Future<void> setProfileLanguages(List<String> langs) async {
    await _prefs?.setStringList(_keyProfileLanguages, langs);
    profileRevisionNotifier.value++;
  }

  static String get profileSosKin {
    return _prefs?.getString(_keyProfileSosKin) ?? '';
  }

  static Future<void> setProfileSosKin(String contact) async {
    await _prefs?.setString(_keyProfileSosKin, contact.trim());
    profileRevisionNotifier.value++;
  }

  static String get profileSosCounsel {
    return _prefs?.getString(_keyProfileSosCounsel) ?? '';
  }

  static Future<void> setProfileSosCounsel(String contact) async {
    await _prefs?.setString(_keyProfileSosCounsel, contact.trim());
    profileRevisionNotifier.value++;
  }

  static bool get profileZeroKnowledgeVault {
    return _prefs?.getBool(_keyProfileZeroKnowledgeVault) ?? true;
  }

  static Future<void> setProfileZeroKnowledgeVault(bool enabled) async {
    await _prefs?.setBool(_keyProfileZeroKnowledgeVault, enabled);
    profileRevisionNotifier.value++;
  }

  static bool get profileVaultLocked {
    return _prefs?.getBool(_keyProfileVaultLocked) ?? false;
  }

  static Future<void> setProfileVaultLocked(bool locked) async {
    await _prefs?.setBool(_keyProfileVaultLocked, locked);
    profileRevisionNotifier.value++;
  }

  /// Reset all stored preferences (useful for tests or app reset).
  static Future<void> clear() async {
    await _prefs?.clear();
    languageNotifier.value = 'en';
    stateNotifier.value = 'ALL';
    roleNotifier.value = 'all';
    profileRevisionNotifier.value++;
  }
}
