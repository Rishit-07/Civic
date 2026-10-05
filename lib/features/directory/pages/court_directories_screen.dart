import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/directory_detail_scaffold.dart';

class CourtDirectoriesScreen extends StatelessWidget {
  const CourtDirectoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DirectoryDetailScaffold(
      category: 'Resources',
      badgeText: 'JUDICIAL INFRASTRUCTURE',
      title: 'Indian Court Directories & e-Courts Portal',
      subtitle:
          'Registry contacts, e-filing portals, and case status lookup services across the Indian judicial hierarchy.',
      children: [
        DirectoryCard(
          title: 'Supreme Court of India',
          statute: 'Tilak Marg, New Delhi 110001 · Phone: 011-23388922',
          icon: Icons.account_balance_rounded,
          body:
              'Apex court of the Republic of India. Exercises original, appellate, and advisory jurisdiction under Articles 32, 131, 136, and 143 of the Constitution.\nWeb: main.sci.gov.in',
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'https://main.sci.gov.in'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Supreme Court portal URL copied'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.link, size: 16),
              label: const Text('COPY SCI PORTAL'),
            ),
          ],
        ),
        DirectoryCard(
          title: 'High Courts of India (25 Jurisdictions)',
          statute: 'Principal High Courts & Circuit Benches',
          icon: Icons.gavel_rounded,
          body:
              'High Courts exercise constitutional writ jurisdiction under Article 226 for the enforcement of fundamental rights and statutory remedies:\n• Delhi High Court (delhihighcourt.nic.in)\n• Bombay High Court (bombayhighcourt.nic.in)\n• Madras High Court (hcmadras.tn.nic.in)\n• Calcutta High Court (calcuttahighcourt.gov.in)\n• Allahabad High Court (allahabadhighcourt.in)\n• Karnataka High Court (karnatakahiighcourt.kar.nic.in)',
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'https://ecourts.gov.in'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('e-Courts National Portal link copied'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.travel_explore_rounded, size: 16),
              label: const Text('OPEN e-COURTS SERVICES'),
            ),
          ],
        ),
        const DirectoryCard(
          title: 'District & Subordinate Courts (e-Courts Services)',
          statute: 'National Judicial Data Grid (NJDG) · ecourts.gov.in',
          icon: Icons.location_city_rounded,
          body:
              'Track case status, view daily cause lists, and download certified bail orders and judgments using your 16-character CNR number (Case Number Record) via the eCourts Services mobile app or portal.',
        ),
      ],
    );
  }
}
