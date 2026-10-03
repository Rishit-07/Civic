import 'package:flutter_test/flutter_test.dart';
import 'package:civic/data/services/location/civic_location_service.dart';

void main() {
  group('CivicLocationService Live Google Maps Tests', () {
    test('CivicLocation formats correct Google Maps live location URL', () {
      const loc = CivicLocation(
        latitude: 19.0760,
        longitude: 72.8777,
        accuracy: 12.0,
      );

      expect(
        loc.googleMapsUrl,
        equals('https://www.google.com/maps/search/?api=1&query=19.076,72.8777'),
      );
      expect(loc.coordinates, equals('19.076, 72.8777'));
    });

    test('buildEmergencySosMessage embeds live Google Maps link when location available', () {
      const loc = CivicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        accuracy: 8.5,
      );

      final msg = CivicLocationService.buildEmergencySosMessage(location: loc);
      expect(msg, contains('Live Google Maps Location:'));
      expect(msg, contains('https://www.google.com/maps/search/?api=1&query=28.6139,77.209'));
      expect(msg, contains('Accuracy: within 9 meters'));
      expect(msg, contains('112 / 15100'));
    });

    test('buildPoliceStopMessage embeds live Google Maps link for traffic stop alerts', () {
      const loc = CivicLocation(
        latitude: 12.9716,
        longitude: 77.5946,
        accuracy: 15.0,
      );

      final msg = CivicLocationService.buildPoliceStopMessage(location: loc);
      expect(msg, contains('POLICE STOP LOCATION ALERT'));
      expect(msg, contains('Live Google Maps Location:'));
      expect(msg, contains('https://www.google.com/maps/search/?api=1&query=12.9716,77.5946'));
      expect(msg, contains('Accuracy: within 15 meters'));
    });

    test('Fallback message when location is unavailable does not crash or use fake coordinates', () {
      final emergencyMsg = CivicLocationService.buildEmergencySosMessage(location: null);
      expect(emergencyMsg, contains('CIVIC EMERGENCY SOS'));
      expect(emergencyMsg, isNot(contains('28.6139')));
      expect(emergencyMsg, contains('112 / 15100'));

      final stopMsg = CivicLocationService.buildPoliceStopMessage(location: null);
      expect(stopMsg, contains('POLICE STOP LOCATION ALERT'));
      expect(stopMsg, isNot(contains('28.6139')));
    });
  });
}
