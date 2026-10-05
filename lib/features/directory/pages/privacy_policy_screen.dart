import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Legal & Trust',
      badgeText: 'DPDP ACT 2023 COMPLIANCE',
      title: 'Privacy Policy & Zero-Telemetry Charter',
      subtitle:
          'Our solemn commitment to zero commercial tracking, offline anonymity, and full data sovereignty.',
      children: [
        DirectoryCard(
          title: 'Zero Tracking & Anonymous Access',
          statute: 'Digital Personal Data Protection Act, 2023 · Section 4 & 6',
          icon: Icons.visibility_off_outlined,
          body:
              'You can access all legal rights cards, procedural checklists, and emergency helpline directories completely anonymously. We do not require you to provide your legal name, telephone number, email, or Aadhaar identity to look up legal rights.',
        ),
        DirectoryCard(
          title: 'Encrypted Local Incident Vault',
          statute: 'AES-256 Client-Side Encryption',
          icon: Icons.shield_rounded,
          body:
              'Any notes, officer details, vehicle numbers, or voice recordings created in the Incident Notes vault are saved locally on your device. When synchronized with Google Cloud Firebase (optional sign-in), data is transmitted via TLS 1.3 and stored in encrypted Firestore collections bound to your authenticated user token.',
        ),
        DirectoryCard(
          title: 'No Advertising or Commercial Data Brokers',
          statute: 'Strict Non-Commercial Data Boundary',
          icon: Icons.block_flipped,
          body:
              'CIVIC never sells, licenses, or shares user inquiries, location coordinates, or search terms with commercial advertising networks, data aggregators, or credit rating agencies.',
        ),
        DirectoryCard(
          title: 'User Data Rights & Complete Erasure',
          statute: 'Section 12 · Right to Correction & Erasure under DPDP 2023',
          icon: Icons.delete_sweep_outlined,
          body:
              'You have the unqualified legal right to request complete erasure of your account and synchronized incident notes at any moment. Tapping "Sign Out" or clearing app data immediately purges localized session caches and triggers automated cloud deletion pipelines.',
        ),
      ],
    );
  }
}
