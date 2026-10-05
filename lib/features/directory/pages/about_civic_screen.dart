import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class AboutCivicScreen extends StatelessWidget {
  const AboutCivicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Initiative',
      badgeText: 'PUBLIC INTEREST PLATFORM',
      title: 'About CIVIC: Citizen Legal First-Aid Infrastructure',
      subtitle:
          'Democratizing access to codified statutory rights across India through offline-first legal intelligence.',
      children: [
        DirectoryCard(
          title: 'The Civic Imperative',
          statute: 'Constitution of India · Article 39A (Equal Justice & Free Legal Aid)',
          icon: Icons.balance_rounded,
          body:
              'Over 80% of citizens in India experience legal confrontations—traffic checkpoints, tenant disputes, arbitrary police summons, and cyber extortion—without immediate access to counsel. CIVIC bridges this critical gap by translating the latest statutory criminal and civil codes into verified, plain-language legal first-aid.',
        ),
        DirectoryCard(
          title: 'The New Criminal Law Transition',
          statute: 'BNSS 2023 · BNS 2023 · BSA 2023',
          icon: Icons.gavel_rounded,
          body:
              'With the complete replacement of the Indian Penal Code 1860, Code of Criminal Procedure 1973, and Indian Evidence Act 1872 with the Bharatiya Nyaya Sanhita (BNS), Bharatiya Nagarik Suraksha Sanhita (BNSS), and Bharatiya Sakshya Adhiniyam (BSA), millions of citizens are unaware of modern protections such as mandatory audio-video search recording (Sec 105 BNSS) and Zero FIR statutory codification (Sec 173 BNSS). CIVIC keeps all guidance aligned with current gazetted law.',
        ),
        DirectoryCard(
          title: 'Zero Telemetry & Local Privacy Guarantee',
          statute: 'DPDP Act 2023 · Privacy by Design',
          icon: Icons.shield_outlined,
          body:
              'Accessing legal rights during a crisis should never compromise personal privacy. CIVIC employs a decentralized, local-first architecture where scenario cards, emergency helplines, and procedural checklists function 100% offline without mandatory account creation or behavioral tracking.',
        ),
        DirectoryCard(
          title: 'Pro-Bono Open Infrastructure',
          statute: 'National Legal Services Authority (NALSA) Alignment',
          icon: Icons.handshake_outlined,
          body:
              'CIVIC is built as an open public-interest platform. We collaborate with legal aid clinics, constitutional scholars, and pro-bono advocate networks to maintain accuracy, ensure impartial neutrality, and direct citizens to statutory legal aid services when court representation is necessary.',
        ),
      ],
    );
  }
}
