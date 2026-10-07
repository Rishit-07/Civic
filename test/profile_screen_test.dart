import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic/data/services/app_preferences.dart';
import 'package:civic/features/profile/profile_screen.dart';
import 'package:civic/features/profile/edit_profile_screen.dart';
import 'package:civic/features/profile/citizen_qr_pass_screen.dart';
import 'package:civic/features/tabs/home/home_screen.dart';

// Transparent 1x1 PNG for mocking image network calls in tests
final Uint8List _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  set findProxy(String Function(Uri url)? f) {}
  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) => _openUrl(url);
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) => _openUrl(url);

  Future<HttpClientRequest> _openUrl(Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentPng.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Stream<List<int>> asBroadcastStream({
    void Function(StreamSubscription<List<int>> subscription)? onListen,
    void Function(StreamSubscription<List<int>> subscription)? onCancel,
  }) => Stream.value(_transparentPng);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    await AppPreferences.clear();
  });

  group('ProfileScreen Tests', () {
    testWidgets('ProfileScreen renders citizen identity, stats mosaic, and vault controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and titles
      expect(find.text('Citizen Profile'), findsOneWidget);
      expect(find.text('CIVIC ID • VAULT #8841'), findsOneWidget);
      expect(find.text('ON-DEVICE SECURE'), findsOneWidget);
      expect(find.text('OFFLINE VERIFIED CITIZEN'), findsOneWidget);

      // Default clean user name & handle
      expect(find.text('Citizen'), findsOneWidget);
      expect(find.text('@citizen.civic'), findsOneWidget);

      // Action buttons
      expect(find.text('EDIT PROFILE'), findsOneWidget);
      expect(find.text('CITIZEN QR'), findsOneWidget);

      // Digital Rights Card stats
      expect(find.text('DIGITAL RIGHTS CARD'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      expect(find.text('GUIDES CACHED'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('SOS CONTACTS'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('ZERO TELEMETRY'), findsOneWidget);

      // Safety controls
      expect(find.text('VAULT & SAFETY CONTROL'), findsOneWidget);
      expect(find.text('Emergency SOS Contacts'), findsOneWidget);
      expect(find.text('Legal Jurisdiction'), findsOneWidget);
      expect(find.text('Document Locker'), findsOneWidget);
      expect(find.text('Primary Language'), findsOneWidget);
      expect(find.text('Zero-Knowledge Vault'), findsOneWidget);
    });

    testWidgets('Tapping CITIZEN QR navigates to CitizenQrPassScreen with offline token and controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final qrBtn = find.text('CITIZEN QR');
      expect(qrBtn, findsOneWidget);

      await tester.tap(qrBtn);
      await tester.pumpAndSettle();

      // Verify CitizenQrPassScreen contents
      expect(find.text('CITIZEN QR PASS'), findsOneWidget);
      expect(find.text('SECURE TOKEN V2.4'), findsOneWidget);
      expect(find.text('Offline Citizen QR Pass'), findsOneWidget);
      expect(find.text('CIVIC GUARDIAN PROTOCOL'), findsOneWidget);
      expect(find.text('OFFLINE VERIFIED'), findsOneWidget);
      expect(find.text('#8841-IN'), findsOneWidget);

      // Verify embedded constitutional claim badges
      expect(find.text('Masked DigiLocker ID'), findsOneWidget);
      expect(find.text('Emergency SOS Trigger'), findsOneWidget);
      expect(find.text('CrPC / BNS Rights Active'), findsOneWidget);

      // Verify action buttons
      expect(find.text('ADD TO GOOGLE WALLET / WIDGET'), findsOneWidget);
      expect(find.text('SHARE TOKEN'), findsOneWidget);
      expect(find.text('REGENERATE'), findsOneWidget);
      expect(find.text('PREVIEW OFFICER INSPECTION VIEW'), findsOneWidget);

      // Test Mode tab switching
      final sosTab = find.text('SOS VCARD');
      expect(sosTab, findsOneWidget);
      await tester.tap(sosTab);
      await tester.pumpAndSettle();

      // Test Officer Inspection Preview modal
      final previewBtn = find.text('PREVIEW OFFICER INSPECTION VIEW');
      await tester.ensureVisible(previewBtn);
      await tester.tap(previewBtn);
      await tester.pumpAndSettle();

      expect(find.text('What An Officer Sees When Scanning Your Pass'), findsOneWidget);
      expect(find.text('STATUTORY IDENTITY CERTIFICATE'), findsOneWidget);
      expect(find.text('DUTY OFFICER STATUTORY NOTICE'), findsOneWidget);

      // Return back from inspection preview
      final returnBtn = find.text('RETURN TO CITIZEN PASS');
      expect(returnBtn, findsOneWidget);
      await tester.tap(returnBtn);
      await tester.pumpAndSettle();

      expect(find.text('What An Officer Sees When Scanning Your Pass'), findsNothing);
    });

    testWidgets('EditProfileScreen renders form fields and saves citizen identity locally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EDIT PROFILE'), findsOneWidget);
      expect(find.text('CHANGE CARICATURE'), findsOneWidget);
      expect(find.text('CITIZEN IDENTITY'), findsOneWidget);
      expect(find.text('STATUTORY ID'), findsOneWidget);
      expect(find.text('LEGAL FULL NAME'), findsOneWidget);
      expect(find.text('CIVIC ID HANDLE'), findsOneWidget);
      expect(find.text('PRIMARY LEGAL JURISDICTION'), findsOneWidget);
      expect(find.text('PREFERRED STATUTORY LANGUAGE'), findsOneWidget);
      expect(find.text('EMERGENCY SAFEGUARDS'), findsOneWidget);

      // Verify initial name
      final nameField = find.widgetWithText(TextField, 'Citizen');
      expect(nameField, findsOneWidget);

      // Change name
      await tester.enterText(nameField, 'Vikramaditya Roy');
      await tester.pumpAndSettle();

      // Scroll down to save button
      final saveBtn = find.text('SAVE PROFILE CHANGES');
      expect(saveBtn, findsOneWidget);
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify stored name in local preferences
      expect(AppPreferences.profileFullName, 'Vikramaditya Roy');
    });

    testWidgets('Home screen profile avatar circle navigates to ProfileScreen on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the profile avatar circle in top-right of home screen
      final profileAvatarFinder = find.byWidgetPredicate((widget) {
        if (widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
            widget.child is Image) {
          return true;
        }
        return false;
      });

      expect(profileAvatarFinder, findsWidgets);

      // Tap the top-most profile avatar button
      await tester.tap(profileAvatarFinder.first);
      await tester.pumpAndSettle();

      // Should have pushed ProfileScreen
      expect(find.text('Citizen Profile'), findsOneWidget);
      expect(find.text('OFFLINE VERIFIED CITIZEN'), findsOneWidget);
    });

    testWidgets('CitizenQrPassScreen standalone renders modes and Google Wallet token modal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CitizenQrPassScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CITIZEN QR PASS'), findsOneWidget);
      expect(find.text('GPS LIVE DISPATCH'), findsOneWidget);
      expect(find.text('112 POLICE'), findsOneWidget);
      expect(find.text('15100 NALSA'), findsOneWidget);
      expect(find.text('MVA §130'), findsOneWidget);

      // Switch to CRYPTO PROOF tab
      final cryptoTab = find.text('CRYPTO PROOF');
      expect(cryptoTab, findsOneWidget);
      await tester.tap(cryptoTab);
      await tester.pumpAndSettle();

      // Tap ADD TO GOOGLE WALLET / WIDGET
      final walletBtn = find.text('ADD TO GOOGLE WALLET / WIDGET');
      await tester.ensureVisible(walletBtn);
      await tester.tap(walletBtn);
      await tester.pumpAndSettle();

      expect(find.text('WALLET PASS READY'), findsOneWidget);
      expect(find.text('TOKEN COPIED TO CLIPBOARD'), findsOneWidget);

      // Dismiss wallet modal
      final doneBtn = find.text('DONE');
      expect(doneBtn, findsOneWidget);
      await tester.tap(doneBtn);
      await tester.pumpAndSettle();

      expect(find.text('WALLET PASS READY'), findsNothing);
    });

    testWidgets('Long-pressing CITIZEN QR opens quick offline QR popup dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final qrBtn = find.text('CITIZEN QR');
      expect(qrBtn, findsOneWidget);

      // Long press
      await tester.longPress(qrBtn);
      await tester.pumpAndSettle();

      expect(find.text('OFFLINE CITIZEN QR'), findsOneWidget);
      expect(find.text('OPEN FULL PASS SCREEN'), findsOneWidget);

      final dismissBtn = find.text('DISMISS');
      expect(dismissBtn, findsOneWidget);
      await tester.tap(dismissBtn);
      await tester.pumpAndSettle();

      expect(find.text('OFFLINE CITIZEN QR'), findsNothing);
    });
  });
}
