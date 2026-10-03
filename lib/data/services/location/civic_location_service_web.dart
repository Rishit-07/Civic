import 'dart:async';
import 'dart:js_interop';

@JS('getCivicLocationAsync')
external JSPromise<JSString> _getCivicLocationAsync();

/// Web implementation of CivicLocationPlatform using browser Geolocation API via JS interop.
class CivicLocationPlatform {
  static Future<String> getLiveLocationString() async {
    try {
      final jsPromise = _getCivicLocationAsync();
      final jsStr = await jsPromise.toDart;
      return jsStr.toDart;
    } catch (e) {
      return '';
    }
  }

  static bool get isSupported => true;
}
