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
          'title': '[PENDING LAWYER REVIEW] $scLabel (${branch.toUpperCase()})',
          'roles': ['affected', 'accused', 'witness', 'parent'],
          'short_lines': [
            '[PENDING LAWYER REVIEW] Step 1: Remain calm and state your constitutional identity.',
            '[PENDING LAWYER REVIEW] Step 2: Request the official reason and authority under law.',
            '[PENDING LAWYER REVIEW] Step 3: Do not sign blank papers or admit unrecorded claims.',
            '[PENDING LAWYER REVIEW] Step 4: Contact immediate verified legal counsel or family.',
            '[PENDING LAWYER REVIEW] Step 5: Document all officer badges, dates, and locations.'
          ],
          'do': [
            '[PENDING LAWYER REVIEW] Maintain respectful but firm verbal communication.',
            '[PENDING LAWYER REVIEW] Demand written acknowledgment or receipt for all proceedings.',
            '[PENDING LAWYER REVIEW] Note down names, identification numbers, and contact details.'
          ],
          'dont': [
            '[PENDING LAWYER REVIEW] Do not offer unreceipted cash or informal compromises.',
            '[PENDING LAWYER REVIEW] Do not resist physical restraint with aggression.',
            '[PENDING LAWYER REVIEW] Do not surrender original identity credentials without formal seizure memo.'
          ],
          'legal_basis': [
            {
              'act': '[PENDING LAWYER REVIEW] Relevant Indian Statutory Code',
              'section': '[PENDING LAWYER REVIEW] Applicable Section',
              'status': '[PENDING LAWYER REVIEW]',
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
          'voice_script': '[PENDING LAWYER REVIEW] Immediate spoken guidance script for this situation.',
          'evidence_checklist': [
            '[PENDING LAWYER REVIEW] Note official badge/ID numbers and station name',
            '[PENDING LAWYER REVIEW] Retain digital timestamps, SMS alerts, and call logs',
            '[PENDING LAWYER REVIEW] Secure copy of written memo or receipt'
          ],
          'reviewed_by': '',
          'reviewed_on': null,
          'valid_until': null,
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
