import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/content/index.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final categories = data['categories'] as List<dynamic>;

  int totalScenarios = 0;
  int totalBranches = 0;
  final missingCards = <String>[];
  final unreviewedCards = <String>[];

  for (final cat in categories) {
    final scenarios = cat['scenarios'] as List<dynamic>;
    totalScenarios += scenarios.length;
    for (final sc in scenarios) {
      for (final branch in sc['branches'] as List<dynamic>) {
        totalBranches++;
        final cardId = '${sc['id']}_$branch';
        final cardFile = File('assets/content/cards/$cardId.json');
        if (!cardFile.existsSync()) {
          missingCards.add(cardId);
        } else {
          final cardData = jsonDecode(cardFile.readAsStringSync()) as Map<String, dynamic>;
          final reviewedBy = (cardData['reviewed_by'] as String? ?? '').trim();
          if (reviewedBy.isEmpty) {
            unreviewedCards.add(cardId);
          }
        }
      }
    }
  }

  print('AUDIT SUMMARY:');
  print('Categories: ${categories.length}');
  print('Total Scenarios: $totalScenarios');
  print('Total Card Branches: $totalBranches');
  print('Missing Card Files: ${missingCards.length}');
  if (missingCards.isNotEmpty) {
    print('Missing: $missingCards');
  }
  print('Unreviewed Cards: ${unreviewedCards.length}');
  if (unreviewedCards.isNotEmpty) {
    print('Unreviewed: $unreviewedCards');
  }
}
