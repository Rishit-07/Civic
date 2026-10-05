import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Legal & Trust',
      badgeText: 'TERMS OF SERVICE',
      title: 'CIVIC Terms of Use & Platform Boundaries',
      subtitle:
          'Operating terms, lawful civic defense licensing, and jurisdictional parameters governing application use.',
      children: [
        DirectoryCard(
          title: '1. Informational Legal First-Aid Resource',
          statute: 'Advocates Act 1961 Compliance',
          icon: Icons.info_outline_rounded,
          body:
              'CIVIC provides automated statutory information, procedural flowcharts, and emergency directories for citizen self-defense and awareness. It is not licensed to practice law and does not establish an attorney-client relationship under Bar Council of India regulations.',
        ),
        DirectoryCard(
          title: '2. Lawful Personal Defense Licensing',
          statute: 'Non-Commercial Permitted Use',
          icon: Icons.verified_user_outlined,
          body:
              'Citizens are granted a revocable, non-exclusive, non-transferable license to use CIVIC for personal emergency preparedness and non-violent assertion of statutory rights. CIVIC may not be used to obstruct lawful public order, transmit false reports, or impersonate law enforcement personnel.',
        ),
        DirectoryCard(
          title: '3. User Content & Evidentiary Vault Rights',
          statute: 'Exclusive User Ownership of Local Notes',
          icon: Icons.folder_shared_outlined,
          body:
              'All incident notes, timestamps, officer details, and audio recordings created by users remain their sole intellectual and personal property. CIVIC exercises no ownership, control, or licensing rights over your personal incident notes.',
        ),
        DirectoryCard(
          title: '4. Limitation of Liability & Immediate Peril',
          statute: 'Emergency Disclaimer',
          icon: Icons.warning_amber_rounded,
          body:
              'In active armed encounters, medical emergencies, or violent physical attacks, citizens must immediately call 112 or local emergency services. CIVIC assumes no liability for damages arising from inability to connect or delays in public authority response.',
        ),
        DirectoryCard(
          title: '5. Governing Law & Dispute Resolution',
          statute: 'Jurisdiction: New Delhi, India',
          icon: Icons.gavel_rounded,
          body:
              'These Terms of Use shall be governed by, construed, and enforced in accordance with the substantive laws of India. The courts of competent jurisdiction at New Delhi shall have exclusive jurisdiction over any legal proceedings arising hereunder.',
        ),
      ],
    );
  }
}
