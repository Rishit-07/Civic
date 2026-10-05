import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class ConstitutionBnsScreen extends StatelessWidget {
  const ConstitutionBnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Initiative',
      badgeText: 'CONSTITUTIONAL & STATUTORY CODES',
      title: 'Constitution of India & The New Sanhitas',
      subtitle:
          'Understanding the fundamental constitutional hierarchy and procedural rights under BNSS & BNS 2023.',
      children: [
        DirectoryCard(
          title: 'Article 14 & 21: Equality & Personal Liberty',
          statute: 'Constitution of India · Part III (Fundamental Rights)',
          icon: Icons.account_balance_rounded,
          body:
              'Article 21 guarantees that no citizen shall be deprived of their life or personal liberty except according to procedure established by law (Maneka Gandhi v. Union of India). Any arbitrary arrest, custodial torture, or police harassment directly violates this non-derogable right.',
        ),
        DirectoryCard(
          title: 'Article 19(1)(a): Freedom of Speech & Public Recording',
          statute: 'Constitution of India · Freedom of Information',
          icon: Icons.videocam_outlined,
          body:
              'Citizens have the constitutional right to observe and video-record police officers performing public duties in public areas. Law enforcement cannot arbitrarily snatch mobile devices, force unlocking, or coerce footage deletion without a valid judicial search warrant.',
        ),
        DirectoryCard(
          title: 'Article 20(3): Protection Against Self-Incrimination',
          statute: 'Right to Silence · Selvi v. State of Karnataka',
          icon: Icons.lock_clock_outlined,
          body:
              'No accused person can be compelled to be a witness against themselves. You cannot be forced to provide biometric unlocks, device passwords, or confession statements under police coercion. Statements made to police in custody are inadmissible as direct substantive evidence under Section 23 of the Bharatiya Sakshya Adhiniyam (BSA).',
        ),
        DirectoryCard(
          title: 'Bharatiya Nyaya Sanhita (BNS) 2023 Overview',
          statute: 'Replaces IPC 1860 · Gazette Notification 2024',
          icon: Icons.menu_book_rounded,
          body:
              'BNS modernizes definitions of criminal offenses, introducing community service for minor infractions, enhanced protections against cyber extortion, and codified penalties for wrongful restraint (Section 126) and extortion (Section 308).',
        ),
        DirectoryCard(
          title: 'Bharatiya Nagarik Suraksha Sanhita (BNSS) 2023',
          statute: 'Replaces CrPC 1973 · Procedural Safeguards',
          icon: Icons.security_rounded,
          body:
              'Key citizen protections codified in BNSS include Section 173 (Statutory Zero FIR), Section 105 (Mandatory videography of search/seizure), Section 43 (No arrest of women after sunset), and Section 35 (Prior permission of DSP for arresting individuals aged 60+ or minor offenses).',
        ),
      ],
    );
  }
}
