import 'package:flutter/material.dart';
import '../../scenarios/situation_list_screen.dart';
import '../widgets/directory_detail_scaffold.dart';

class OfflineArchiveScreen extends StatelessWidget {
  const OfflineArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DirectoryDetailScaffold(
      category: 'Resources',
      badgeText: 'LOCAL STORAGE & OFFLINE VAULT',
      title: 'Offline Statutory Archive & Scenario Vault',
      subtitle:
          'CIVIC stores 28+ verified procedural legal cards locally on your device for instant offline access.',
      children: [
        DirectoryCard(
          title: 'Explore All 28+ Offline Scenario Cards',
          statute: 'Available 100% Offline without Internet',
          icon: Icons.folder_special_outlined,
          body:
              'Browse all categorized legal first-aid cards covering police encounters, tenant harassment, cyber scams, consumer disputes, domestic worker rights, and senior citizen maintenance.',
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SituationListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.library_books_rounded, size: 16),
              label: const Text('OPEN SCENARIO CATALOG'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17261F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const DirectoryCard(
          title: 'Offline Guarantee & Cache Architecture',
          statute: 'JSON Assets & SharedPreferences Engine',
          icon: Icons.offline_pin_rounded,
          body:
              'When you launch CIVIC, all core statutory cards, emergency helpline registries, and procedural action lists are loaded directly from encrypted local application bundles. You can use CIVIC in remote areas, basement holding cells, or during mobile network shutdowns.',
        ),
        const DirectoryCard(
          title: 'Automated Gazette Update Sync',
          statute: 'Background Manifest Verification',
          icon: Icons.sync_rounded,
          body:
              'Whenever an internet connection is detected, CIVIC automatically queries the central gazette manifest in the background. If statutory sections or court precedents have been updated, the local card index updates seamlessly without disrupting user activity.',
        ),
      ],
    );
  }
}
