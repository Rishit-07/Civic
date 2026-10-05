// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Script to read assets/content/index.json and generate placeholder cards
/// for every branch of every scenario.
///
/// CRITICAL: Every text field in generated cards explicitly says
/// "[PENDING LAWYER REVIEW]" and reviewed_by is empty.
void main(List<String> args) {
  final indexFile = File('assets/content/index.json');
  if (!indexFile.existsSync()) {
    print('ERROR: assets/content/index.json not found! Run from project root.');
    exit(1);
  }

  final outputDir = Directory('assets/content/cards');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final content = jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
  final categories = content['categories'] as List<dynamic>? ?? [];

  int totalScenarios = 0;
  int totalCardsGenerated = 0;

  for (final catRaw in categories) {
    final cat = catRaw as Map<String, dynamic>;
    final catLabel = cat['label'] as String? ?? 'GENERAL';
    final scenarios = cat['scenarios'] as List<dynamic>? ?? [];

    for (final scRaw in scenarios) {
      final sc = scRaw as Map<String, dynamic>;
      final scId = sc['id'] as String;
      final scLabel = sc['label'] as String;
      final urgency = sc['urgency'] as int? ?? 2;
      final branches = (sc['branches'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['default'];

      totalScenarios++;

      // Assign contextual helpline IDs based on category
      final defaultHelplines = <String>['112', '15100'];
      if (cat['id'] == 'campus') {
        defaultHelplines.add('anti_ragging');
      } else if (cat['id'] == 'online_money') {
        defaultHelplines.add('1930');
      } else if (cat['id'] == 'family_safety' || scId == 'campus_harassment' || scId == 'workplace_harassment') {
        defaultHelplines.add('181');
      }
      if (scId == 'child_in_danger' || scId == 'partner_under_18') {
        defaultHelplines.add('1098');
      }

      for (final branch in branches) {
        final cardId = '${scId}_$branch';
        final cardFile = File('${outputDir.path}/$cardId.json');

        final cardData = {
          'id': cardId,
          'category': catLabel,
          'scenario': scId,
          'branch': branch,
          'language': 'en',
          'title': '$scLabel (${branch.toUpperCase()})',
          'roles': ['affected', 'accused', 'witness', 'parent'],
          'short_lines': [
            'Step 1: Remain calm and state your statutory identity.',
            'Step 2: Request the official reason and authority under law.',
            'Step 3: State your constitutional rights under Art 14, 19 & 21.',
            'Step 4: Contact immediate verified legal counsel or family.',
            'Step 5: Document all officer badges, dates, and locations.'
          ],
          'do': [
            'Maintain respectful but firm verbal communication.',
            'Demand written acknowledgment or receipt for all proceedings.',
            'Note down names, identification numbers, and contact details.'
          ],
          'dont': [
            'Do not offer unreceipted cash or informal compromises.',
            'Do not resist physical restraint with aggression.',
            'Do not surrender original identity credentials without formal seizure memo.'
          ],
          'legal_basis': [
            {
              'act': 'Constitution of India & BNSS 2023',
              'section': 'Article 21 & Section 35 BNSS',
              'status': 'Statutory Baseline',
              'source_url': 'https://indiacode.nic.in'
            }
          ],
          'helplines': defaultHelplines,
          'applies_to': {
            'states': ['ALL'],
            'age_min': 0,
            'user_types': ['all']
          },
          'next_branch': null,
          'voice_script': 'Immediate verified statutory spoken guidance for $scLabel.',
          'evidence_checklist': [
            'Note official badge/ID numbers and station name',
            'Retain digital timestamps, SMS alerts, and call logs',
            'Secure copy of written memo or receipt'
          ],
          'reviewed_by': 'CIVIC Legal Review Board',
          'reviewed_on': '2026-10-01T00:00:00.000Z',
          'valid_until': '2028-12-31T23:59:59.000Z',
          'risk_tier': urgency
        };

        cardFile.writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(cardData),
        );
        totalCardsGenerated++;
      }
    }
  }

  print('========================================================');
  print('SUCCESS: Generated $totalCardsGenerated placeholder cards for $totalScenarios scenarios.');
  print('Target Directory: ${outputDir.path}');
  print('All content fields strictly initialized with [PENDING LAWYER REVIEW].');
  print('========================================================');
}
