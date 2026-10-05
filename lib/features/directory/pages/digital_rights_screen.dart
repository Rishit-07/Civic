import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class DigitalRightsScreen extends StatelessWidget {
  const DigitalRightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Protocols',
      badgeText: 'DIGITAL PRIVACY & EVIDENCE',
      title: 'Digital Rights, Mobile Seizure & Search Rules',
      subtitle:
          'Protections against arbitrary phone confiscation, biometric compulsion, and mandatory digital search recording under BNSS 105.',
      children: [
        DirectoryCard(
          title: 'Mandatory Videography of Search & Seizure',
          statute: 'Section 105 BNSS 2023 · Digital Evidence Safeguards',
          icon: Icons.videocam_rounded,
          body:
              'Under Section 105 BNSS, all searches conducted by police of places or persons, and all seizure of items (including mobile phones and laptops), MUST be recorded through audio-video electronic means (mobile phone or camera). The officer must prepare a seizure list and forward the recording without alteration to the Magistrate within 48 hours.',
        ),
        DirectoryCard(
          title: 'Can Police Demand Your Phone Passcode?',
          statute: 'Article 20(3) Constitution · Virendra Khanna v. State of Karnataka',
          icon: Icons.password_rounded,
          body:
              'Police cannot compel citizens during casual inquiries or traffic stops to unlock their mobile phones or disclose encrypted passwords. Compulsion to unlock personal communications without a specific judicial order infringes upon the right against self-incrimination and informational privacy (Puttaswamy judgment).',
        ),
        DirectoryCard(
          title: 'Hash Value Generation on Electronic Seizure',
          statute: 'Bharatiya Sakshya Adhiniyam 2023 · Digital Forensics Protocol',
          icon: Icons.fingerprint_rounded,
          body:
              'If a digital device (phone, laptop, hard drive) is seized as evidence in an investigation, forensic guidelines require the seizing officer to generate a cryptographic hash value (SHA-256) of the device state on-site in the presence of independent witnesses, preventing subsequent tampering or evidence planting.',
        ),
        DirectoryCard(
          title: 'Right to Video-Record Public Servants',
          statute: 'Article 19(1)(a) · Public Performance of Public Duty',
          icon: Icons.camera_alt_outlined,
          body:
              'Citizens are legally permitted to record video of police officers, municipal inspectors, or traffic personnel conducting inspections in public view. Law enforcement officers cannot confiscate phones or demand video deletion under threat of obstruction charges (Section 132 BNS / Sec 353 IPC), as recording does not constitute physical obstruction.',
        ),
      ],
    );
  }
}
