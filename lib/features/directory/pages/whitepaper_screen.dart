import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class WhitepaperScreen extends StatelessWidget {
  const WhitepaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Resources',
      badgeText: 'ARCHITECTURE & JURISPRUDENCE',
      title: 'CIVIC Technical & Jurisprudential Whitepaper',
      subtitle:
          'Open specifications for deterministic, decentralized civic rights first-aid engineering.',
      children: [
        DirectoryCard(
          title: 'Executive Abstract',
          statute: 'Version 2.4 · October 2026 Edition',
          icon: Icons.article_outlined,
          body:
              'CIVIC addresses the systemic legal information asymmetry between the state apparatus and Indian citizens. By organizing complex criminal codes (BNSS 2023, BNS 2023) into deterministic state-machine cards, citizens gain split-second clarity on statutory bounds, officer rank mandates, and evidentiary protocols.',
        ),
        DirectoryCard(
          title: 'Local-First Zero-Knowledge Architecture',
          statute: 'Client-Side Execution · Offline SQLite / SharedPreferences',
          icon: Icons.memory_rounded,
          body:
              'The platform operates entirely client-side for primary lookup. All 28+ scenario graphs, triage routing rules, and emergency directories reside inside offline JSON bundles. No network handshake is required to verify statutory rights during an active police checkpoint.',
        ),
        DirectoryCard(
          title: 'Statutory Verification & Legal Proofing Methodology',
          statute: 'Gazette Alignment with Ministry of Law and Justice',
          icon: Icons.verified_outlined,
          body:
              'Every scenario protocol is cross-indexed against:\n1. Codified Central Acts (BNS, BNSS, BSA, MVA).\n2. Landmark Supreme Court Rulings (D.K. Basu, Arnesh Kumar, Lalita Kumari, Selvi).\n3. Standing Police Guidelines and Ministry Notifications.\nRules are authored in declarative JSON schemas with clear separation between mandatory rights and strategic legal advice.',
        ),
        DirectoryCard(
          title: 'Evidence Preservation & Cryptographic Integrity',
          statute: 'Section 63 · Bharatiya Sakshya Adhiniyam, 2023',
          icon: Icons.lock_outline,
          body:
              'When citizens document badge numbers, officer names, and audio transcripts within the Incident Notes Vault, local timestamps and SHA-256 integrity hashes are computed client-side. This ensures evidence admissibility under Section 63 BSA electronic records standards.',
        ),
      ],
    );
  }
}
