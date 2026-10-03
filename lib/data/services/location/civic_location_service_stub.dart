import 'dart:async';

/// Stub implementation of CivicLocationPlatform for VM / testing environments.
class CivicLocationPlatform {
  static Future<String> getLiveLocationString() async {
    return '';
  }

  static bool get isSupported => false;
}
