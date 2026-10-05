import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class CitizenRightsScreen extends StatelessWidget {
  const CitizenRightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Legal & Trust',
      badgeText: 'FUNDAMENTAL FREEDOMS',
      title: 'Citizen Rights & Protections Against Public Authority',
      subtitle:
          'A constitutional charter of your rights during police questioning, searches, and official encounters.',
      children: [
        DirectoryCard(
          title: 'Right to Know the Grounds of Arrest or Inquiry',
          statute: 'Article 22(1) Constitution · Section 47 BNSS 2023',
          icon: Icons.info_outline_rounded,
          body:
              'No citizen can be detained in custody without being informed, as soon as may be, of the specific legal grounds for such arrest. In bailable offenses, the officer must inform you that you are entitled to bail as a matter of right.',
        ),
        DirectoryCard(
          title: 'Right to Consult and be Defended by a Legal Practitioner',
          statute: 'Article 22(1) Constitution · Section 340 BNSS 2023',
          icon: Icons.person_search_outlined,
          body:
              'You have the fundamental right to contact and consult an advocate of your choice from the moment of detention. Under Supreme Court guidelines, an advocate is permitted to be present during police interrogation within visible distance (though not within hearing distance).',
        ),
        DirectoryCard(
          title: 'Right Against Illegal Handcuffing',
          statute: 'Prem Shankar Shukla v. Delhi Administration (Supreme Court)',
          icon: Icons.link_off_rounded,
          body:
              'Routine handcuffing of accused persons is unconstitutional and inhumane. Handcuffs can only be used under extraordinary circumstances where there is credible evidence of violent escape risk, and the reasons must be explicitly recorded in the police diary and approved by the Magistrate.',
        ),
        DirectoryCard(
          title: 'Right Against Illegal Detention & Writ of Habeas Corpus',
          statute: 'Article 32 & 226 Constitution of India',
          icon: Icons.shield_outlined,
          body:
              'If a citizen is held in unrecorded detention or illegal custody without production before a Magistrate within 24 hours, their relatives or advocates can immediately approach the High Court or Supreme Court seeking an emergency Writ of Habeas Corpus directing the police to produce the detainee.',
        ),
      ],
    );
  }
}
