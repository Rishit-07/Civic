import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:civic/data/models/content_models.dart';
import 'package:civic/data/repositories/content_repository.dart';
import '../tools/import_cards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Domain 1: Schema Validation for All Generated Cards', () {
    test('Every generated card in assets/content/cards/*.json deserializes cleanly', () {
      final dir = Directory('assets/content/cards');
      expect(dir.existsSync(), isTrue, reason: 'assets/content/cards directory must exist');

      final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      expect(files.length, greaterThanOrEqualTo(100),
          reason: 'Expected 100+ generated cards across all categories and branches');

      for (final file in files) {
        final content = file.readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;

        // Verify deserialization
        final card = CardModel.fromJson(json);
        expect(card.id, isNotEmpty);
        expect(card.category, isNotEmpty);
        expect(card.scenario, isNotEmpty);
        expect(card.branch, isNotEmpty);
        expect(card.title, isNotEmpty);

        // Strict 7-line short lines limit invariant
        expect(card.shortLines.length, lessThanOrEqualTo(7),
            reason: 'Card ${card.id} exceeds the strict 7-line limit');

        // Verify pending lawyer review markers on placeholder content
        if (card.reviewedBy.isEmpty) {
          expect(card.status, equals('placeholder'));
          expect(card.voiceScript, contains('[PENDING LAWYER REVIEW]'));
          for (final line in card.shortLines) {
            expect(line, contains('[PENDING LAWYER REVIEW]'));
          }
        }
      }
    });

    test('Master index.json covers 8 categories and 44+ scenarios', () {
      final indexFile = File('assets/content/index.json');
      expect(indexFile.existsSync(), isTrue);

      final indexData = jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
      final categories = (indexData['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(categories.length, equals(8));

      int totalScenarios = 0;
      for (final cat in categories) {
        expect(cat.scenarios, isNotEmpty);
        totalScenarios += cat.scenarios.length;
        for (final sc in cat.scenarios) {
          expect(sc.id, isNotEmpty);
          expect(sc.label, isNotEmpty);
          expect(sc.branches, contains('default'),
              reason: 'Scenario ${sc.id} must include at least the "default" branch');
        }
      }

      expect(totalScenarios, greaterThanOrEqualTo(44));
    });
  });

  group('Domain 2: Short Lines 7-Line Invariant', () {
    test('CardModel.fromJson throws ArgumentError when short_lines exceeds 7', () {
      final invalidJson = {
        'id': 'test_card_overflow',
        'category': 'TEST',
        'scenario': 'test',
        'branch': 'default',
        'title': 'Test Overflow',
        'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
        'roles': ['affected'],
        'short_lines': [
          'Line 1',
          'Line 2',
          'Line 3',
          'Line 4',
          'Line 5',
          'Line 6',
          'Line 7',
          'Line 8 - INVARIANT VIOLATION',
        ],
        'voice_script': 'Script',
        'do': [],
        'dont': [],
        'legal_basis': [],
        'helplines': [],
        'evidence_checklist': [],
        'language': 'en',
        'reviewed_by': '',
        'reviewed_on': DateTime.now().toIso8601String(),
        'valid_until': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'risk_tier': 2,
      };

      expect(() => CardModel.fromJson(invalidJson), throwsA(isA<FormatException>()));
    });

    test('CardModel accepts up to exactly 7 short lines', () {
      final validJson = {
        'id': 'test_card_valid',
        'category': 'TEST',
        'scenario': 'test',
        'branch': 'default',
        'title': 'Test Valid',
        'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
        'roles': ['affected'],
        'short_lines': [
          'Line 1',
          'Line 2',
          'Line 3',
          'Line 4',
          'Line 5',
          'Line 6',
          'Line 7',
        ],
        'voice_script': 'Script',
        'do': [],
        'dont': [],
        'legal_basis': [],
        'helplines': [],
        'evidence_checklist': [],
        'language': 'en',
        'reviewed_by': '',
        'reviewed_on': DateTime.now().toIso8601String(),
        'valid_until': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'risk_tier': 2,
      };

      final card = CardModel.fromJson(validJson);
      expect(card.shortLines.length, equals(7));
    });
  });

  group('Domain 3: Legal Safety Gates (Release vs Debug)', () {
    final unreviewedCard = CardModel(
      id: 'unreviewed_card',
      category: 'TEST',
      scenario: 'test',
      branch: 'default',
      title: '[PENDING LAWYER REVIEW] Unreviewed Test',
      appliesTo: const AppliesTo(),
      roles: const ['affected'],
      shortLines: const ['[PENDING LAWYER REVIEW] Step 1'],
      voiceScript: '[PENDING LAWYER REVIEW] Script',
      doList: const [],
      dontList: const [],
      legalBasis: const [],
      helplines: const [],
      evidenceChecklist: const [],
      language: 'en',
      reviewedBy: '', // UNREVIEWED
      reviewedOn: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 100)),
      riskTier: 2,
    );

    final draftedCard = CardModel(
      id: 'drafted_card',
      category: 'TEST',
      scenario: 'test',
      branch: 'default',
      title: 'Drafted Content Test',
      appliesTo: const AppliesTo(),
      roles: const ['affected'],
      shortLines: const ['Custom draft step 1'],
      voiceScript: 'Draft voice script',
      doList: const [],
      dontList: const [],
      legalBasis: const [],
      helplines: const [],
      evidenceChecklist: const [],
      language: 'en',
      reviewedBy: '', // UNREVIEWED but drafted content
      reviewedOn: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 100)),
      riskTier: 2,
    );

    final reviewedCard = CardModel(
      id: 'reviewed_card',
      category: 'TEST',
      scenario: 'test',
      branch: 'default',
      title: 'Reviewed Test',
      appliesTo: const AppliesTo(),
      roles: const ['affected'],
      shortLines: const ['Step 1'],
      voiceScript: 'Script',
      doList: const [],
      dontList: const [],
      legalBasis: const [],
      helplines: const [],
      evidenceChecklist: const [],
      language: 'en',
      reviewedBy: 'Advocate Verma, High Court Bar',
      reviewedOn: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 180)),
      riskTier: 2,
    );

    final expiredCard = CardModel(
      id: 'expired_card',
      category: 'TEST',
      scenario: 'test',
      branch: 'default',
      title: 'Expired Test',
      appliesTo: const AppliesTo(),
      roles: const ['affected'],
      shortLines: const ['Step 1'],
      voiceScript: 'Script',
      doList: const [],
      dontList: const [],
      legalBasis: const [],
      helplines: const [],
      evidenceChecklist: const [],
      language: 'en',
      reviewedBy: 'Advocate Verma',
      reviewedOn: DateTime.now().subtract(const Duration(days: 400)),
      validUntil: DateTime.now().subtract(const Duration(days: 10)), // EXPIRED
      riskTier: 2,
    );

    test('Release Mode: strictly hides unreviewed or expired cards', () {
      final releaseRepo = ContentRepository(isReleaseModeOverride: true);

      expect(releaseRepo.canDisplayCard(unreviewedCard), isFalse,
          reason: 'Unreviewed cards must be strictly hidden in release builds');
      expect(releaseRepo.canDisplayCard(draftedCard), isFalse,
          reason: 'Drafted unreviewed cards must be strictly hidden in release builds');
      expect(releaseRepo.canDisplayCard(expiredCard), isFalse,
          reason: 'Expired cards must be strictly hidden in release builds');
      expect(releaseRepo.canDisplayCard(reviewedCard), isTrue,
          reason: 'Valid lawyer-reviewed cards can be displayed in release builds');
    });

    test('Debug Mode: displays all cards (for review and testing)', () {
      final debugRepo = ContentRepository(isReleaseModeOverride: false);

      expect(debugRepo.canDisplayCard(unreviewedCard), isTrue,
          reason: 'Debug mode allows viewing placeholder cards with warning banner');
      expect(debugRepo.canDisplayCard(draftedCard), isTrue);
      expect(debugRepo.canDisplayCard(expiredCard), isTrue,
          reason: 'Debug mode allows viewing expired cards with warning banner');
      expect(debugRepo.canDisplayCard(reviewedCard), isTrue);
    });

    test('Status getter accurately classifies card lifecycle', () {
      expect(unreviewedCard.status, equals('placeholder'));
      expect(draftedCard.status, equals('drafted'));
      expect(reviewedCard.status, equals('reviewed'));
      expect(expiredCard.status, equals('expired'));
    });
  });

  group('Domain 4: Demographic and Regional Filtering', () {
    final nationalMinorCard = CardModel(
      id: 'minor_card',
      category: 'CAMPUS',
      scenario: 'ragging_victim',
      branch: 'minor_school',
      title: 'School Ragging Under 18',
      appliesTo: const AppliesTo(
        states: ['ALL'],
        ageMin: 0,
        userTypes: ['student'],
      ),
      roles: const ['affected'],
      shortLines: const ['Report to school authority'],
      voiceScript: '',
      doList: const [],
      dontList: const [],
      legalBasis: const [],
      helplines: const [],
      evidenceChecklist: const [],
      language: 'en',
      reviewedBy: '',
      reviewedOn: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 100)),
      riskTier: 2,
    );

    final delhiTenantCard = CardModel(
      id: 'delhi_tenant_card',
      category: 'HOUSING',
      scenario: 'landlord_entry_without_notice',
      branch: 'default',
      title: 'Delhi Rent Control Notice Rules',
      appliesTo: const AppliesTo(
        states: ['DL'],
        ageMin: 18,
        userTypes: ['tenant'],
      ),
      roles: const ['affected'],
      shortLines: const ['Cite Delhi Rent Control Act'],
      voiceScript: '',
      doList: const [],
      dontList: const [],
      legalBasis: const [],
      helplines: const [],
      evidenceChecklist: const [],
      language: 'en',
      reviewedBy: '',
      reviewedOn: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 100)),
      riskTier: 2,
    );

    final repo = ContentRepository(isReleaseModeOverride: false);
    final List<CardModel> cardList = [nationalMinorCard, delhiTenantCard];

    test('Filter by State', () {
      final delhiCards = repo.filterCards(cardList, state: 'DL');
      expect(delhiCards.length, equals(2), reason: 'National card applies to all states, DL card applies to DL');

      final mumbaiCards = repo.filterCards(cardList, state: 'MH');
      expect(mumbaiCards.length, equals(1));
      expect(mumbaiCards.first.id, equals('minor_card'));
    });

    test('Filter by Age', () {
      final minorCards = repo.filterCards(cardList, age: 16);
      expect(minorCards.length, equals(1));
      expect(minorCards.first.id, equals('minor_card'));

      final adultCards = repo.filterCards(cardList, age: 25);
      expect(adultCards.length, equals(2));
    });

    test('Filter by User Type', () {
      final studentCards = repo.filterCards(cardList, userType: 'student');
      expect(studentCards.length, equals(1));
      expect(studentCards.first.id, equals('minor_card'));

      final tenantCards = repo.filterCards(cardList, userType: 'tenant');
      expect(tenantCards.length, equals(1));
      expect(tenantCards.first.id, equals('delhi_tenant_card'));
    });
  });

  group('Domain 5: CSV Bulk Importer Validation', () {
    test('Valid CSV parses and creates CardModel without errors', () {
      const csvData = '''
id,category,scenario,branch,title,short_lines,what_to_say,roles,do,dont,legal_basis,helplines,evidence_checklist,states,age_min,user_types,risk_tier,reviewed_by,reviewed_on,valid_until
traffic_stop_valid,POLICE & CRIMINAL,traffic_stop,valid_test,Traffic Stop Valid,Step 1|Step 2|Step 3,Calm statement,affected|witness,Keep calm,Do not argue,BNS:::Sec 100:::In Force:::https://indiacode.nic.in,112,Badge photo,all,18,driver,1,Advocate Sharma,2026-10-01,2027-10-01
''';

      final result = processCardCsv(csvData);
      expect(result.errors, isEmpty);
      expect(result.successCount, equals(1));
      expect(result.cards.length, equals(1));

      final card = result.cards.first;
      expect(card.id, equals('traffic_stop_valid'));
      expect(card.shortLines.length, equals(3));
      expect(card.reviewedBy, equals('Advocate Sharma'));
      expect(card.status, equals('reviewed'));
    });

    test('CSV row with 8 short lines is strictly REJECTED with error log', () {
      const csvOverflow = '''
id,category,scenario,branch,title,short_lines,what_to_say,roles,do,dont,legal_basis,helplines,evidence_checklist,states,age_min,user_types,risk_tier,reviewed_by,reviewed_on,valid_until
traffic_stop_overflow,POLICE & CRIMINAL,traffic_stop,overflow,Traffic Overflow,1|2|3|4|5|6|7|8,Script,affected,Do,Dont,Legal,112,Evidence,all,18,driver,1,Advocate,2026-10-01,2027-10-01
''';

      final result = processCardCsv(csvOverflow);
      expect(result.successCount, equals(0));
      expect(result.errors.length, equals(1));
      expect(result.errors.first, contains('maximum allowed is 7'));
    });

    test('CSV parser correctly handles multiline and escaped quotes', () {
      const csvQuoted = '''
id,category,scenario,branch,title,short_lines
card_quoted,POLICE,traffic,branch,"Title with ""quotes"" and
newline",Step 1|Step 2
''';

      final rows = parseCsv(csvQuoted);
      expect(rows.length, equals(2));
      expect(rows[1][4], contains('quotes'));
      expect(rows[1][4], contains('\n'));
    });
  });

  group('Domain 6: Helpline Registry Integrity', () {
    test('assets/content/helplines.json contains mandatory emergency numbers 112 and 15100', () {
      final helplinesFile = File('assets/content/helplines.json');
      expect(helplinesFile.existsSync(), isTrue);

      final list = (jsonDecode(helplinesFile.readAsStringSync()) as List<dynamic>)
          .map((e) => HelplineModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, greaterThanOrEqualTo(6));

      // National Emergency 112 check
      final h112 = list.firstWhere((h) => h.id == '112');
      expect(h112.number, equals('112'));
      expect(h112.description, isNotEmpty);

      // Tele-Law 15100 check
      final h15100 = list.firstWhere((h) => h.id == '15100');
      expect(h15100.number, equals('15100'));

      // Childline 1098 check
      final h1098 = list.firstWhere((h) => h.id == '1098');
      expect(h1098.number, equals('1098'));

      // Cybercrime 1930 check
      final h1930 = list.firstWhere((h) => h.id == '1930');
      expect(h1930.number, equals('1930'));
    });
  });
}
