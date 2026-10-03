import 'civic_location_platform.dart';

/// Represents a validated geographic location coordinate with accuracy.
class CivicLocation {
  final double latitude;
  final double longitude;
  final double accuracy;

  const CivicLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  /// Live Google Maps universal link that opens the exact pinpoint in Google Maps app or web
  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  /// Standard coordinates string
  String get coordinates => '$latitude, $longitude';
}

/// Service providing live Google Maps location fetching and Emergency SOS alert composition.
class CivicLocationService {
  /// Fetches real-time live GPS coordinates from the browser / device.
  static Future<CivicLocation?> getCurrentLocation() async {
    try {
      final raw = await CivicLocationPlatform.getLiveLocationString();
      if (raw.isEmpty) return null;

      final parts = raw.split(',');
      if (parts.length < 2) return null;

      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      final acc = parts.length > 2 ? double.tryParse(parts[2].trim()) ?? 15.0 : 15.0;

      if (lat == null || lng == null) return null;

      return CivicLocation(
        latitude: lat,
        longitude: lng,
        accuracy: acc,
      );
    } catch (_) {
      return null;
    }
  }

  /// Builds an emergency SOS message with the live Google Maps link if available.
  static String buildEmergencySosMessage({
    CivicLocation? location,
    String headline = '🚨 CIVIC EMERGENCY SOS',
    String situation = 'I require immediate legal first-aid and civilian support.',
  }) {
    if (location != null) {
      return '$headline: $situation\n\n'
          '📍 Live Google Maps Location:\n'
          '${location.googleMapsUrl}\n'
          '(Accuracy: within ${location.accuracy.round()} meters)\n\n'
          'Please monitor my safety and contact emergency services (112 / 15100).';
    }

    return '$headline: $situation\n\n'
        'Emergency beacon activated. Please contact local emergency services (112 / 15100).';
  }

  /// Builds a police encounter location alert with live Google Maps link.
  static String buildPoliceStopMessage({
    CivicLocation? location,
  }) {
    if (location != null) {
      return '🚨 POLICE STOP LOCATION ALERT: I am currently stopped for verification by authorities.\n\n'
          '📍 Live Google Maps Location:\n'
          '${location.googleMapsUrl}\n'
          '(Accuracy: within ${location.accuracy.round()} meters)\n\n'
          'Please monitor my situation. Contact 112 / 15100 if I do not check in.';
    }

    return '🚨 POLICE STOP LOCATION ALERT: I am currently stopped for verification by authorities.\n\n'
        'Please monitor my situation. Contact 112 / 15100 if I do not check in.';
  }
}
