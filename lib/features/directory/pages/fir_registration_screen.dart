import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class FirRegistrationScreen extends StatelessWidget {
  const FirRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Protocols',
      badgeText: 'CRIMINAL PROCEDURE STATUTE',
      title: 'FIR Registration & Zero FIR Protocol',
      subtitle:
          'Statutory rights when filing a First Information Report and legal remedies when police refuse to register.',
      children: [
        DirectoryCard(
          title: 'Mandatory Registration of Cognizable Offenses',
          statute: 'Section 173 BNSS 2023 · Lalita Kumari v. Govt of UP (Supreme Court)',
          icon: Icons.post_add_rounded,
          body:
              'Registration of an FIR is mandatory under Section 173 of the Bharatiya Nagarik Suraksha Sanhita (BNSS) if the information discloses the commission of a cognizable offense. Police cannot refuse to lodge an FIR or subject cognizable complaints to indefinite informal delays.',
        ),
        DirectoryCard(
          title: 'Statutory Zero FIR Guarantee',
          statute: 'Section 173(1) BNSS 2023 · Jurisdiction Independence',
          icon: Icons.travel_explore_rounded,
          body:
              'A "Zero FIR" can be lodged at ANY police station irrespective of territorial jurisdiction or where the crime took place. The station must record the information, assign it a serial number "0", conduct initial preservation of evidence, and subsequently transfer it to the jurisdictional police station.',
        ),
        DirectoryCard(
          title: 'Remedy 1: Escalation to Superintendent of Police (SP)',
          statute: 'Section 173(4) BNSS 2023 · Formerly Section 154(3) CrPC',
          icon: Icons.send_rounded,
          body:
              'If the Station House Officer (SHO) refuses to record an FIR, the aggrieved citizen can send the substance of the complaint in writing by registered post or speed post to the Superintendent of Police (SP) or Deputy Commissioner of Police (DCP), who is empowered to investigate or direct an investigation.',
        ),
        DirectoryCard(
          title: 'Remedy 2: Private Complaint to Judicial Magistrate',
          statute: 'Section 175(3) BNSS 2023 · Formerly Section 156(3) CrPC',
          icon: Icons.gavel_rounded,
          body:
              'If the police hierarchy fails to register the FIR, an application can be filed directly before the Judicial Magistrate having jurisdiction, supported by an affidavit and proof of prior representation to the SP. The Magistrate can order the police station to register an FIR and submit a compliance report.',
        ),
        DirectoryCard(
          title: 'Right to a Free Copy of the FIR',
          statute: 'Section 173(2) BNSS 2023 · Immediate Free Copy',
          icon: Icons.receipt_long_rounded,
          body:
              'A copy of the FIR as recorded must be given forthwith, free of cost, to the informant or the victim. You should never leave a police station without an official stamped and signed copy of the registered FIR with its unique Crime Number.',
        ),
      ],
    );
  }
}
