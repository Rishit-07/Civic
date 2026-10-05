import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/content/index.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final categories = data['categories'] as List<dynamic>;

  int totalScenarios = 0;
  int totalBranches = 0;

  for (final cat in categories) {
    final scenarios = cat['scenarios'] as List<dynamic>;
    totalScenarios += scenarios.length;
    int branchesCount = 0;
    for (final sc in scenarios) {
      branchesCount += (sc['branches'] as List<dynamic>).length;
    }
    totalBranches += branchesCount;
    print('${cat['id']} | ${cat['label']} -> ${scenarios.length} scenarios, $branchesCount branches');
    for (final sc in scenarios) {
      print('   - ${sc['id']}: ${sc['label']} (${(sc['branches'] as List).join(', ')})');
    }
  }
  print('\nTOTAL: ${categories.length} categories, $totalScenarios scenarios, $totalBranches card branches');
}
