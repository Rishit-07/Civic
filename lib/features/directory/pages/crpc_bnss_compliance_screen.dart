import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class CrpcBnssComplianceScreen extends StatelessWidget {
  const CrpcBnssComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Legal & Trust',
      badgeText: 'COMPARATIVE LEGISLATIVE MATRIX',
      title: 'CrPC 1973 to BNSS 2023 Compliance Matrix',
      subtitle:
          'Authoritative cross-reference table mapping former CrPC sections to active Bharatiya Nagarik Suraksha Sanhita codes.',
      children: [
        DirectoryCard(
          title: 'Arrest of Persons Without Warrant',
          statute: 'Former CrPC Section 41 ➔ Active BNSS Section 35',
          icon: Icons.compare_arrows_rounded,
          body:
              'Section 35 BNSS retains the Arnesh Kumar mandatory notice protocol: for offenses punishable with less than 7 years imprisonment, police must issue a Notice of Appearance rather than effecting immediate physical arrest.',
        ),
        DirectoryCard(
          title: 'Arrest of Women Safeguards',
          statute: 'Former CrPC Section 46(4) ➔ Active BNSS Section 43',
          icon: Icons.compare_arrows_rounded,
          body:
              'Section 43 BNSS re-enacts the statutory ban on arresting women between sunset and sunrise except under exceptional circumstances with prior Judicial Magistrate sanction.',
        ),
        DirectoryCard(
          title: 'Information in Cognizable Cases (FIR & Zero FIR)',
          statute: 'Former CrPC Section 154 ➔ Active BNSS Section 173',
          icon: Icons.compare_arrows_rounded,
          body:
              'Section 173 BNSS explicitly codifies Zero FIR into the statutory text for the first time, obligating any police station to record cognizable complaints regardless of territorial jurisdiction.',
        ),
        DirectoryCard(
          title: 'Magistrate Directing Police Investigation',
          statute: 'Former CrPC Section 156(3) ➔ Active BNSS Section 175(3)',
          icon: Icons.compare_arrows_rounded,
          body:
              'Section 175(3) BNSS provides judicial remedy when police refuse to register an FIR, requiring an affidavit and proof of prior submission to the Superintendent of Police.',
        ),
        DirectoryCard(
          title: 'Mandatory Videography of Search & Seizure',
          statute: 'NEW STATUTORY MANDATE ➔ Active BNSS Section 105',
          icon: Icons.videocam_rounded,
          body:
              'Section 105 BNSS is a groundbreaking modern addition: all police searches of places or persons, and all item seizures, must be recorded via electronic video without tampering and forwarded to the Magistrate within 48 hours.',
        ),
      ],
    );
  }
}
