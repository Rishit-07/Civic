// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:civic/data/models/content_models.dart';

/// Result of CSV processing containing count of valid rows, error list, and generated models.
class CsvImportResult {
  final int successCount;
  final List<String> errors;
  final List<CardModel> cards;

  const CsvImportResult({
    required this.successCount,
    required this.errors,
    required this.cards,
  });
}

/// Robust CSV parser handling multiline cells and quotes
List<List<String>> parseCsv(String input) {
  final rows = <List<String>>[];
  final currentCell = StringBuffer();
  var currentRow = <String>[];
  var insideQuotes = false;

  for (int i = 0; i < input.length; i++) {
    final char = input[i];
    final nextChar = (i + 1 < input.length) ? input[i + 1] : '';

    if (char == '"') {
      if (insideQuotes && nextChar == '"') {
        currentCell.write('"');
        i++; // skip escaped quote
      } else {
        insideQuotes = !insideQuotes;
      }
    } else if (char == ',' && !insideQuotes) {
      currentRow.add(currentCell.toString());
      currentCell.clear();
    } else if ((char == '\r' || char == '\n') && !insideQuotes) {
      if (char == '\r' && nextChar == '\n') {
        i++; // skip LF
      }
      currentRow.add(currentCell.toString());
      currentCell.clear();
      if (currentRow.any((c) => c.trim().isNotEmpty)) {
        rows.add(currentRow);
      }
      currentRow = <String>[];
    } else {
      currentCell.write(char);
    }
  }

  if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
    currentRow.add(currentCell.toString());
    if (currentRow.any((c) => c.trim().isNotEmpty)) {
      rows.add(currentRow);
    }
  }

  return rows;
}

/// Process CSV string and optionally write valid cards to [outputDirPath].
CsvImportResult processCardCsv(String csvContent, {String? outputDirPath}) {
  final rows = parseCsv(csvContent);
  if (rows.isEmpty) {
    return const CsvImportResult(
      successCount: 0,
      errors: ['CSV input is empty.'],
      cards: [],
    );
  }

  final header = rows.first.map((e) => e.trim().toLowerCase()).toList();
  final dataRows = rows.skip(1).toList();

  int successCount = 0;
  final errors = <String>[];
  final cards = <CardModel>[];

  Directory? outputDir;
  if (outputDirPath != null) {
    outputDir = Directory(outputDirPath);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
  }

  for (int i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    final rowNum = i + 2;

    if (row.every((cell) => cell.trim().isEmpty)) {
      continue;
    }

    try {
      final map = <String, String>{};
      for (int h = 0; h < header.length; h++) {
        map[header[h]] = h < row.length ? row[h].trim() : '';
      }

      final id = map['id'] ?? '';
      if (id.isEmpty) {
        errors.add('Row $rowNum: Missing required "id" field.');
        continue;
      }

      final category = map['category'] ?? 'GENERAL';
      final scenario = map['scenario'] ?? '';
      final branch = map['branch'] ?? 'default';

      if (scenario.isEmpty) {
        errors.add('Row $rowNum ($id): Missing required "scenario" field.');
        continue;
      }

      // Parse short_lines
      final rawShortLines = map['short_lines'] ?? '';
      final shortLines = rawShortLines.isNotEmpty
          ? rawShortLines.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : <String>[];

      // INVARIANT: Rejects rows with more than 7 short_lines
      if (shortLines.length > 7) {
        errors.add(
          'Row $rowNum ($id): REJECTED - short_lines has ${shortLines.length} items (maximum allowed is 7).',
        );
        continue;
      }

      // Parse list fields separated by pipe "|"
      List<String> parseList(String? key) {
        final val = map[key] ?? '';
        if (val.isEmpty) return [];
        return val.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      final roles = parseList('roles');
      final doList = parseList('do');
      final dontList = parseList('dont');
      final helplines = parseList('helplines');
      final evidenceChecklist = parseList('evidence_checklist');
      final states = parseList('states');
      final userTypes = parseList('user_types');

      // Parse Legal Basis
      final legalBasis = <Map<String, dynamic>>[];
      final rawLegal = map['legal_basis'] ?? '';
      if (rawLegal.isNotEmpty) {
        if (rawLegal.startsWith('[')) {
          try {
            final decoded = jsonDecode(rawLegal) as List<dynamic>;
            for (final item in decoded) {
              legalBasis.add(item as Map<String, dynamic>);
            }
          } catch (_) {
            errors.add('Row $rowNum ($id): Malformed JSON in legal_basis column.');
            continue;
          }
        } else {
          final items = rawLegal.split('|');
          for (final item in items) {
            final parts = item.split(':::').map((e) => e.trim()).toList();
            legalBasis.add({
              'act': parts.isNotEmpty ? parts[0] : 'Constitution of India',
              'section': parts.length > 1 ? parts[1] : 'Article 21',
              'status': parts.length > 2 ? parts[2] : 'Verified Statutory Code',
              'source_url': parts.length > 3 ? parts[3] : 'https://indiacode.nic.in',
            });
          }
        }
      }

      // Age minimum
      final ageMin = int.tryParse(map['age_min'] ?? '') ?? 0;

      // Risk tier
      final riskTier = int.tryParse(map['risk_tier'] ?? '') ?? 2;
      if (riskTier < 1 || riskTier > 3) {
        errors.add('Row $rowNum ($id): risk_tier must be 1, 2, or 3. Got: $riskTier.');
        continue;
      }

      // Parse Dates
      DateTime? parseDate(String? raw) {
        if (raw == null || raw.trim().isEmpty) return null;
        try {
          return DateTime.parse(raw.trim());
        } catch (_) {
          return null;
        }
      }

      final reviewedOn = parseDate(map['reviewed_on']);
      final validUntil = parseDate(map['valid_until']);

      final cardData = {
        'id': id,
        'category': category,
        'scenario_id': scenario,
        'branch': branch,
        'title': map['title'] ?? id.replaceAll('_', ' ').toUpperCase(),
        'applies_to': {
          'states': states.isEmpty ? ['all'] : states,
          'min_age': ageMin,
          'max_age': null,
          'user_types': userTypes.isEmpty ? ['all'] : userTypes,
        },
        'user_roles': roles.isEmpty ? ['affected', 'accused', 'witness', 'parent'] : roles,
        'short_lines': shortLines,
        'what_to_say': map['what_to_say'] ?? '',
        'do_list': doList,
        'dont_list': dontList,
        'legal_basis': legalBasis,
        'helpline_ids': helplines,
        'evidence_checklist': evidenceChecklist,
        'role_specific_advice': {},
        'language': 'en',
        'reviewed_by': map['reviewed_by'] ?? '',
        'reviewed_date': reviewedOn?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'valid_until': validUntil?.toIso8601String() ??
            DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'version': 1,
      };

      final cardModel = CardModel.fromJson(cardData);
      cards.add(cardModel);

      if (outputDir != null) {
        final outFile = File('${outputDir.path}/$id.json');
        outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(cardData));
      }

      successCount++;
    } catch (e) {
      errors.add('Row $rowNum: Unhandled exception during row processing: $e');
    }
  }

  return CsvImportResult(
    successCount: successCount,
    errors: errors,
    cards: cards,
  );
}

/// CLI runner
void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tools/import_cards.dart <path_to_csv_file>');
    print('Example: dart run tools/import_cards.dart data/reviewed_cards.csv');
    return;
  }

  final csvFile = File(args[0]);
  if (!csvFile.existsSync()) {
    print('ERROR: File not found: ${args[0]}');
    exit(1);
  }

  final content = csvFile.readAsStringSync();
  print('========================================================');
  print('CIVIC BULK CARD IMPORTER');
  print('Input: ${csvFile.path}');
  print('========================================================\n');

  final result = processCardCsv(content, outputDirPath: 'assets/content/cards');

  print('IMPORT SUMMARY:');
  print('--------------------------------------------------------');
  print('Successfully imported: ${result.successCount} cards');
  print('Failed / Rejected:     ${result.errors.length} rows');

  if (result.errors.isNotEmpty) {
    print('\nERROR LOG:');
    for (final err in result.errors) {
      print('  • $err');
    }
    print('\nPlease fix errors in CSV and re-run.');
  } else {
    print('\nALL ROWS VALIDATED AND IMPORTED SUCCESSFULLY.');
  }
}
